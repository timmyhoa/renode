*** Variables ***
${ACCEL}                 sysbus.i2c1.accel
${UART}                  sysbus.usart2
${ACCEL_POLLING_SAMPLE}  @https://dl.antmicro.com/projects/renode/b_l072z_lrwan1--zephyr-accel_polling.elf-s_731368-a41b79116936bdadbee51e497847273f971ed409
${ACCEL_POLLING_SAMPLE_14BIT}  @https://dl.antmicro.com/projects/renode/b_l072z_lrwan1--zephyr-accel_polling-high_performance.elf-s_731368-049f6743622eb0b8068dbc2a24742561c8fa046a
${CSV2RESD}              ${RENODETOOLS}/csv2resd/csv2resd.py

*** Keywords ***
Execute Python Script
    [Arguments]  ${path}  ${args}

    Evaluate  subprocess.run([sys.executable, "${path}", ${args}])  sys,subprocess

Create Machine
    Execute Command         using sysbus
    Execute Command         mach create
    Execute Command         machine LoadPlatformDescription @platforms/cpus/stm32l072.repl
    Execute Command         machine LoadPlatformDescriptionFromString 'accel: Sensors.LIS2DW12 @ i2c1 0x2d'
    Create Terminal Tester  ${UART}
    Create Log Tester       0
    Execute Command         logLevel -1 ${ACCEL}

Format Fixed Point Integer As Decimal
    [Arguments]  ${value}  ${places}

    ${minus}=  Set Variable  ${EMPTY}
    IF  ${value} < 0
        ${minus}=  Set Variable  -
        ${value}=  Evaluate  abs(${value})
    END

    ${divisor}=  Evaluate  10**${places}
    ${units}=  Evaluate  ${value} / ${divisor}
    ${fraction}=  Evaluate  ${value} % ${divisor}
    ${string}=  Evaluate  "${minus}%d.%0${places}d" % (${units}, ${fraction})

    [Return]  ${string}

Wait For Peripheral Reading
    [Arguments]  ${microg}  ${resolution}

    IF  ${resolution} == 12
        ${sensitivity}=  Set Variable  976
        ${shift}=  Set Variable  4
    ELSE IF  ${resolution} == 14
        ${sensitivity}=  Set Variable  244
        ${shift}=  Set Variable  2
    ELSE
        Fail               Invalid resolution ${resolution} bits
    END

    ${steps}=  Evaluate  int(${microg} / ${sensitivity})
    ${outValue}=  Evaluate  ${steps} * ${sensitivity}
    ${outStr}=  Format Fixed Point Integer As Decimal  ${outValue}  6

    ${lsbs}=  Evaluate  abs(${steps}) << ${shift}
    # Use twos-complement representation if negative
    IF  ${steps} < 0
        ${lsbs}=  Evaluate  (abs(${lsbs}) ^ 0xffff) + 1
    END
    ${lsbsStr}=  Convert To Hex  ${lsbs}  prefix=0x  length=4

    Wait For Line On Uart  lis2dw12@2d *\\[g]: *\\( *${outStr}, *${outStr}, *${outStr}\\)  treatAsRegex=true  pauseEmulation=true
    Wait For Log Entry     Conversion done with sensitivity: 0.${sensitivity}, result: ${lsbsStr}

Wait For Peripheral Reading For Set Value And Known LSBs
    [Arguments]  ${microg}  ${resolution}  ${lsbs}

    ${g}=  Format Fixed Point Integer As Decimal  ${microg}  6
    Execute Command        ${ACCEL} DefaultAccelerationX ${g}
    Execute Command        ${ACCEL} DefaultAccelerationY ${g}
    Execute Command        ${ACCEL} DefaultAccelerationZ ${g}
    # Wait for the expected LSBs value keeping the entry for use by the following keyword
    Wait For Log Entry     result: ${lsbs}  timeout=2  pauseEmulation=true  keep=true
    Wait For Peripheral Reading  ${microg}  ${resolution}

LIS2DW12 Should Return Data From RESD
    [Arguments]  ${firmware}  ${resolution}
    ${tmpDir}=    Evaluate  tempfile.mkdtemp()  tempfile
    ${resdPath}=  Set Variable  ${tmpDir}/samples.resd
    ${resdArgs}=  Catenate  SEPARATOR=,
                  ...       "--input", "${CURDIR}/LIS2DW12-samples.csv"
                  ...       "--frequency", "1"
                  ...       "--start-time", "0"
                  ...       "--map", "acceleration:x,y,z:x,y,z"
                  ...       "${resdPath}"

    Execute Python Script  ${CSV2RESD}  ${resdArgs}

    Create Machine

    Execute Command        sysbus LoadELF ${firmware}
    Wait For Line On Uart  Booting Zephyr OS  pauseEmulation=true

    Execute Command        ${ACCEL} FeedAccelerationSamplesFromRESD @${resdPath}

    Wait For Peripheral Reading  100000  ${resolution}
    Wait For Peripheral Reading  200000  ${resolution}
    Wait For Peripheral Reading  300000  ${resolution}
    Wait For Peripheral Reading  400000  ${resolution}
    Wait For Peripheral Reading  500000  ${resolution}
    Wait For Peripheral Reading  600000  ${resolution}
    Wait For Peripheral Reading  700000  ${resolution}
    Wait For Peripheral Reading  -100000  ${resolution}
    Wait For Peripheral Reading  -200000  ${resolution}

    [Teardown]             Remove Directory  ${tmpDir}  recursive=true

*** Test Cases ***
LIS2DW12 Should Return Data From RESD In 12-Bit Mode
    LIS2DW12 Should Return Data From RESD  ${ACCEL_POLLING_SAMPLE}  12

LIS2DW12 Should Return Data From RESD In 14-Bit Mode
    LIS2DW12 Should Return Data From RESD  ${ACCEL_POLLING_SAMPLE_14BIT}  14

    # Additionally verify the examples from ST AN5038. In the app note the calculated
    # mg values are rounded to integers, these are exact values.
    Wait For Peripheral Reading For Set Value And Known LSBs  -40992  14  0xFD60
    Wait For Peripheral Reading For Set Value And Known LSBs  7320  14  0x0078
    Wait For Peripheral Reading For Set Value And Known LSBs  1046028  14  0x42FC
