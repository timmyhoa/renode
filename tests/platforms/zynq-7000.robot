*** Variables ***
${UART}                             sysbus.uart0
${PROMPT}                           \#${SPACE}
${I2C_ECHO_ADDRESS}                 0x10
${I2C_SENSOR_ADDRESS}               0x31
${FLASH_MOUNT}                      /mnt/spi_flash
${SAMPLE_FILENAME}                  data.bin
${MTD0_DEV}                         /dev/mtd0
${MTD0_BLOCK_DEV}                   /dev/mtdblock0
${MTD1_DEV}                         /dev/mtd1
${MTD1_BLOCK_DEV}                   /dev/mtdblock1
${CADENCE_XSPI_BIN}                 @https://dl.antmicro.com/projects/renode/zynq--cadence-xspi-vmlinux-s_14143972-449b7a25d689a4b6e2adc9ae4c3abbf375ccc70c
${CADENCE_XSPI_ROOTFS}              @https://dl.antmicro.com/projects/renode/zynq--cadence-xspi-rootfs.ext2-s_16777216-d1dabbf627ba4846963c97db8d27f5d4f454e72b
${CADENCE_XSPI_DTB}                 @https://dl.antmicro.com/projects/renode/zynq--cadence-xspi.dtb-s_11045-f5e1772bb1d19234ce6f0b8ec77c2f970660c7bb
${CADENCE_XSPI_AUTOCOMMAND_BIN}     @https://dl.antmicro.com/projects/renode/zynq--cadence-xspi-vmlinux-s_14386012-ff7f3dfd09804979deca966c66127df7495c5318
${CADENCE_XSPI_AUTOCOMMAND_ROOTFS}  @https://dl.antmicro.com/projects/renode/zynq--cadence-xspi-rootfs.ext2-s_16777216-a05d6421ce699832c6f372f2001aaa13b054c02b
${CADENCE_XSPI_AUTOCOMMAND_DTB}     @https://dl.antmicro.com/projects/renode/zynq--cadence-xspi.dtb-s_11045-f5e1772bb1d19234ce6f0b8ec77c2f970660c7bb
${ZYNQ_UFS_BIN}                     @https://dl.antmicro.com/projects/renode/zynq--linux-ufs.elf-s_14602408-e730ddd43bc5bd78d3295f4816a80f2a43832388
${ZYNQ_UFS_ROOTFS}                  @https://dl.antmicro.com/projects/renode/zynq--linux-ufs-rootfs.ext2-s_16777216-6f4122f4b1dd932df6636d83503b4f0ca60aac86
${ZYNQ_UFS_DTB}                     @https://dl.antmicro.com/projects/renode/zynq--linux-ufs.dtb-s_12720-0dfc729e7c8db7b51c5eb4dfd990cee186de1442
${ZYNQ_UFS_TEST_DISK_IMG}           @https://dl.antmicro.com/projects/renode/test-fs-ext2.img-s_524288-67f5bc210d7be8905b4de4ae5d70a8a142459110
${CADENCE_XSPI_PERIPHERAL}          SEPARATOR=\n
...                                 """
...                                 xspi: SPI.Cadence_xSPI @ {
...                                 sysbus 0xE0102000;
...                                 sysbus new Bus.BusMultiRegistration {
...                                 address: 0xe0104000; size: 0x100; region: "auxiliary"
...                                 };
...                                 sysbus new Bus.BusMultiRegistration {
...                                 address: 0xe0200000; size: 0x1000; region: "dma"
...                                 }
...                                 }
...                                 ${SPACE*4}IRQ -> gic@63
...
...                                 xspiFlash0: SPI.Micron_MT25Q @ xspi 0 {
...                                 underlyingMemory: xspiFlashMemory0;
...                                 extendedDeviceId: 0x44
...                                 }
...
...                                 xspiFlashMemory0: Memory.MappedMemory {
...                                 size:  0x2000000
...                                 }
...                                 """

${UFS_HOST_TX_REQUEST_SLOTS}        32
${UFS_HOST_RTT_REQUESTS}            16
${UFS_HOST_TASK_MGMT_SLOTS}         8

${UFS_DEVICE_LOGICAL_UNITS}         4
${UFS_DEVICE_LOGICAL_BLOCK_SIZE}    4096
${UFS_DEVICE_BLOCK_COUNT}           65536

${UFS_DEVICE_MANUFACTURER_NAME}     "Antmicro"
${UFS_DEVICE_PRODUCT_NAME}          "RenodeUFSStorage"
${UFS_DEVICE_SERIAL_NUMBER}         "0123456789ABCDEF"
${UFS_DEVICE_OEM_ID}                "000011112222"
${UFS_DEVICE_PRODUCT_REV_LEVEL}     "0000"

@{UFS_STRING_DESCRIPTORS}=          ${UFS_DEVICE_MANUFACTURER_NAME}
...                                 ${UFS_DEVICE_PRODUCT_NAME}
...                                 ${UFS_DEVICE_SERIAL_NUMBER}
...                                 ${UFS_DEVICE_OEM_ID}
...                                 ${UFS_DEVICE_PRODUCT_REV_LEVEL}

${DEVICE_DESCR_TYPE}                0x00
${CONFIG_DESCR_TYPE}                0x01
${UNIT_DESCR_TYPE}                  0x02
${INTERCONNECT_DESCR_TYPE}          0x04
${STRING_DESCR_TYPE}                0x05
${GEOMETRY_DESCR_TYPE}              0x07
${POWER_DESCR_TYPE}                 0x08
${DEVICE_HEALTH_DESCR_TYPE}         0x09

@{UFS_DESCR_SINGLETON_TYPES}=       ${DEVICE_DESCR_TYPE}  
...                                 ${CONFIG_DESCR_TYPE}
...                                 ${UNIT_DESCR_TYPE}
...                                 ${INTERCONNECT_DESCR_TYPE}
...                                 ${GEOMETRY_DESCR_TYPE}
...                                 ${DEVICE_HEALTH_DESCR_TYPE}

${UFS_HOST_CONTROLLER_PERIPHERAL}   SEPARATOR=\n
...                                 """
...                                 ufs: Storage.UFSHostController @ sysbus 0xe0102000
...                                 ${SPACE*4}IRQ -> gic@29
...                                 ${SPACE*4}transferRequestSlots: ${UFS_HOST_TX_REQUEST_SLOTS}
...                                 ${SPACE*4}readyToTransferRequests: ${UFS_HOST_RTT_REQUESTS}
...                                 ${SPACE*4}taskManagementRequestSlots: ${UFS_HOST_TASK_MGMT_SLOTS}
...                                 """
${UFS_DEVICE_PERIPHERAL}            SEPARATOR=\n
...                                 """
...                                 ufsStorage: Storage.UFSDevice @ ufs
...                                 ${SPACE*4}logicalUnits: ${UFS_DEVICE_LOGICAL_UNITS}
...                                 ${SPACE*4}logicalBlockSize: ${UFS_DEVICE_LOGICAL_BLOCK_SIZE}
...                                 ${SPACE*4}blockCount: ${UFS_DEVICE_BLOCK_COUNT}
...                                 ${SPACE*4}manufacturerName: ${UFS_DEVICE_MANUFACTURER_NAME}
...                                 ${SPACE*4}productName: ${UFS_DEVICE_PRODUCT_NAME}
...                                 ${SPACE*4}serialNumber: ${UFS_DEVICE_SERIAL_NUMBER}
...                                 ${SPACE*4}oemID: ${UFS_DEVICE_OEM_ID}
...                                 ${SPACE*4}productRevisionLevel: ${UFS_DEVICE_PRODUCT_REV_LEVEL}
...                                 """

*** Keywords ***
Create Machine
    Execute Command                 include @scripts/single-node/zynq-7000.resc
    Execute Command                 machine LoadPlatformDescriptionFromString "i2cEcho: Mocks.EchoI2CDevice @ i2c0 ${I2C_ECHO_ADDRESS}"
    Execute Command                 machine LoadPlatformDescriptionFromString "i2cSensor: Sensors.MAX30208 @ i2c0 ${I2C_SENSOR_ADDRESS}"
    Execute Command                 machine LoadPlatformDescriptionFromString "spiFlash0: SPI.Micron_MT25Q @ spi0 0 { underlyingMemory: spi0FlashMemory; extendedDeviceId: 0x44 }; spi0FlashMemory: Memory.MappedMemory { size: 0x2000000 }"
    Execute Command                 machine LoadPlatformDescriptionFromString "spiFlash1: SPI.Cypress_S25H @ spi0 1 { underlyingMemory: spi1FlashMemory }; spi1FlashMemory: Memory.MappedMemory { size: 0x4000000 }"
    Create Terminal Tester          ${UART}

Boot And Login
    Wait For Line On Uart           Booting Linux on physical CPU 0x0
    Wait For Prompt On Uart         buildroot login:  timeout=25
    Write Line To Uart              root
    Wait For Prompt On Uart         ${PROMPT}

Check Exit Code
    Write Line To Uart              echo $?
    Wait For Line On Uart           0
    Wait For Prompt On Uart         ${PROMPT}

Execute Linux Command
    [Arguments]                     ${command}  ${timeout}=5
    Write Line To Uart              ${command}
    Wait For Prompt On Uart         ${PROMPT}  timeout=${timeout}
    Check Exit Code

Get Linux Elapsed Seconds
    Write Line To Uart              date +%s
    ${date}=                        Wait For Line On Uart  ^([0-9]+)$  treatAsRegex=true
    Wait For Prompt On Uart         ${PROMPT}
    Check Exit Code
    ${seconds}=                     Convert To Integer  ${date.line}
    [return]                        ${seconds}

Generate Random File
    [Arguments]                     ${filename}  ${size_kilobytes}
    Execute Linux Command           dd if=/dev/urandom of=./${filename} bs=1024 count=${size_kilobytes}

Should Mount Flash Memory And Write File
    [Arguments]                     ${mtd_dev}  ${mtd_block_dev}  ${mount_path}  ${random_filename}
    Execute Linux Command           flash_erase --jffs2 -N ${mtd_dev} 0 0
    Execute Linux Command           mkdir ${mount_path}
    Execute Linux Command           mount -t jffs2 ${mtd_block_dev} ${mount_path}
    Execute Linux Command           cp ./${random_filename} ${mount_path}

    Write Line To Uart              ls --color=never -1 ${mount_path}
    Wait For Line On Uart           ${random_filename}
    Wait For Prompt On Uart         ${PROMPT}
    Check Exit Code
    Execute Linux Command           umount ${mount_path}

Should Mount Flash Memory And Compare Files
    [Arguments]                     ${mtd_block_dev}  ${mount_path}  ${random_filename}
    Execute Linux Command           mount -t jffs2 ${mtd_block_dev} ${mount_path}
    Execute Linux Command           cmp ${mount_path}/${random_filename} ./${random_filename}
    Execute Linux Command           umount ${mount_path}

Should Erase Flash Memory
    [Arguments]                     ${mtd_dev}  ${mtd_block_dev}  ${mount_path}
    Execute Linux Command           flash_erase --jffs2 -N ${mtd_dev} 0 0
    Execute Linux Command           mount -t jffs2 ${mtd_block_dev} ${mount_path}
    Write Line To Uart              ls -1 ${mount_path} | wc -l
    Wait For Line On Uart           0
    Wait For Prompt On Uart         ${PROMPT}
    Check Exit Code
    Execute Linux Command           umount ${mount_path}

Should Access SPI Flash Memory Via Additional Cadence xSPI 
    Create Machine
    Execute Command                 machine LoadPlatformDescriptionFromString ${CADENCE_XSPI_PERIPHERAL}
    Start Emulation

    Boot And Login
    # Suppress messages from the kernel space
    Execute Linux Command           echo 0 > /proc/sys/kernel/printk

    Write Line To Uart              ls --color=never -1 /dev/
    Wait For Line On Uart           mtd0
    Wait For Prompt On Uart         ${PROMPT}
    Check Exit Code

    Generate Random File            ${SAMPLE_FILENAME}  5

    Should Mount Flash Memory And Write File  ${MTD0_DEV}  ${MTD0_BLOCK_DEV}  ${FLASH_MOUNT}  ${SAMPLE_FILENAME}
    Should Mount Flash Memory And Compare Files  ${MTD0_BLOCK_DEV}  ${FLASH_MOUNT}  ${SAMPLE_FILENAME}
    Should Erase Flash Memory       ${MTD0_DEV}  ${MTD0_BLOCK_DEV}  ${FLASH_MOUNT}

# String descriptor can be read by `ufs-utils` tool only as a raw byte array, so for the purpose of comparison
# value passed to UFS device constructor is converted to that form using custom keyword.
Get Raw String Descriptor
    [Arguments]                     ${string}
    ${length}=                      Evaluate    '0x\{:02x\}'.format(len("${string}".encode('utf-16le')) + 2)
    ${raw}=                         Evaluate    ' '.join(r'0x{:02x}'.format(chr) for chr in bytes("${string}", 'utf-16le'))
    ${descr}=                       Catenate    ${length} ${STRING_DESCR_TYPE} ${raw}
    [return]                        ${descr}

Map Index To Disk Letter
    [Arguments]                     ${index}
    ${letter}=                      Evaluate    chr(97 + ${index})
    [return]                        ${letter}

*** Test Cases ***
Should Boot And Login
    Create Machine
    Start Emulation

    Boot And Login
    # Suppress messages from the kernel space
    Execute Linux Command           echo 0 > /proc/sys/kernel/printk

    Provides                        logged-in

Should List Expected Devices
    Requires                        logged-in

    Write Line To Uart              ls --color=never -1 /dev/
    Wait For Line On Uart           i2c-0
    Wait For Line On Uart           mtd0
    Wait For Line On Uart           mtd1
    Wait For Line On Uart           ttyPS0
    Wait For Prompt On Uart         ${PROMPT}
    Check Exit Code

Should Detect I2C Peripherals
    Requires                        logged-in

    Write Line To Uart              i2cdetect -yar 0
    Wait For Line On Uart           10: 10 --
    Wait For Line On Uart           30: -- 31 --
    Wait For Prompt On Uart         ${PROMPT}
    Check Exit Code

    Write Line To Uart              i2cget -y 0 0x41
    Wait For Line On Uart           No such device
    Wait For Prompt On Uart         ${PROMPT}

Should Communicate With I2C Echo Peripheral
    Requires                        logged-in

    Write Line To Uart              i2ctransfer -ya 0 w3@${I2C_ECHO_ADDRESS} 0x01 0x23 0x45 r2
    Wait For Line On Uart           0x01 0x23
    Wait For Prompt On Uart         ${PROMPT}
    Check Exit Code

    # Very long commands are splited into many lines due to the terminal width (number of columns), which confused waitForEcho feature
    Write Line To Uart              i2ctransfer -ya 0 w20@${I2C_ECHO_ADDRESS} 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f 0x10 0x11 0x12 0x13 0x14 r21  waitForEcho=false
    Wait For Line On Uart           0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f 0x10 0x11 0x12 0x13 0x14 0x00
    Wait For Prompt On Uart         ${PROMPT}
    Check Exit Code

    # Check target monitor feature
    Execute Linux Command           i2ctransfer -ya 0 w0@${I2C_ECHO_ADDRESS}

Should Communicate With MAX30208 Peripheral
    Requires                        logged-in

    # Write and read one register
    Execute Linux Command           i2cset -y 0 ${I2C_SENSOR_ADDRESS} 0x10 0xbe
    Write Line To Uart              i2cget -y 0 ${I2C_SENSOR_ADDRESS} 0x10
    Wait For Line On Uart           0xbe
    Wait For Prompt On Uart         ${PROMPT}
    Check Exit Code

    # Read more bytes than I2C peripheral provides
    Write Line To Uart              i2ctransfer -ya 0 w0@${I2C_SENSOR_ADDRESS} r2
    Wait For Line On Uart           0x00 0x00
    Wait For Prompt On Uart         ${PROMPT}
    Check Exit Code

    # Read weird number of bytes to check is FinishTransmission calling works properly
    Write Line To Uart              i2ctransfer -ya 0 w19@${I2C_SENSOR_ADDRESS} 0xff 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 r18  waitForEcho=false
    Wait For Line On Uart           0x30 0x30 0x30 0x30 0x30 0x30 0x30 0x30 0x30 0x30 0x30 0x30 0x30 0x30 0x30 0x30 0x30
    Wait For Prompt On Uart         ${PROMPT}
    Check Exit Code

Should Access Micron SPI Flash Memory
    Requires                        logged-in
    Generate Random File            ${SAMPLE_FILENAME}  5

    Should Mount Flash Memory And Write File  ${MTD0_DEV}  ${MTD0_BLOCK_DEV}  ${FLASH_MOUNT}  ${SAMPLE_FILENAME}
    Should Mount Flash Memory And Compare Files  ${MTD0_BLOCK_DEV}  ${FLASH_MOUNT}  ${SAMPLE_FILENAME}
    Should Erase Flash Memory       ${MTD0_DEV}  ${MTD0_BLOCK_DEV}  ${FLASH_MOUNT}

Should Access Cypress SPI Flash Memory
    Requires                        logged-in
    Generate Random File            ${SAMPLE_FILENAME}  5

    Should Mount Flash Memory And Write File  ${MTD1_DEV}  ${MTD1_BLOCK_DEV}  ${FLASH_MOUNT}  ${SAMPLE_FILENAME}
    Should Mount Flash Memory And Compare Files  ${MTD1_BLOCK_DEV}  ${FLASH_MOUNT}  ${SAMPLE_FILENAME}
    Should Erase Flash Memory       ${MTD1_DEV}  ${MTD1_BLOCK_DEV}  ${FLASH_MOUNT}

Time Should Elapse
    Requires                        logged-in

    ${seconds_before}=              Get Linux Elapsed Seconds
    Execute Linux Command           sleep 2
    ${seconds}=                     Get Linux Elapsed Seconds
    Should Be True                  ${seconds_before} < ${seconds}

Should Access SPI Flash Memory Via Additional Cadence xSPI IP
    Execute Command                 $bin=${CADENCE_XSPI_BIN}
    Execute Command                 $rootfs=${CADENCE_XSPI_ROOTFS}
    Execute Command                 $dtb=${CADENCE_XSPI_DTB}

    Should Access SPI Flash Memory Via Additional Cadence xSPI 

Should Access SPI Flash Memory Via Additional Cadence xSPI IP With The Auto Command Patch
    Execute Command                 $bin=${CADENCE_XSPI_AUTOCOMMAND_BIN}
    Execute Command                 $rootfs=${CADENCE_XSPI_AUTOCOMMAND_ROOTFS}
    Execute Command                 $dtb=${CADENCE_XSPI_AUTOCOMMAND_DTB}

    Should Access SPI Flash Memory Via Additional Cadence xSPI 

Should Boot And Login With UFS
    Execute Command                 $bin=${ZYNQ_UFS_BIN}
    Execute Command                 $rootfs=${ZYNQ_UFS_ROOTFS}
    Execute Command                 $dtb=${ZYNQ_UFS_DTB}

    Create Machine
    Execute Command                 machine LoadPlatformDescriptionFromString ${UFS_HOST_CONTROLLER_PERIPHERAL}
    Execute Command                 machine LoadPlatformDescriptionFromString ${UFS_DEVICE_PERIPHERAL}
    
    Boot And Login
    # Suppress messages from the kernel space
    Execute Linux Command           echo 0 > /proc/sys/kernel/printk
    Provides                        ufs-logged-in

Should Access UFS Storage
    Requires                        ufs-logged-in

    ${MOUNT_POINT}=                 Set Variable  /mnt
    ${OUTPUT_LIST}=                 Create List
    
    # Create filesystem and write some text to file on it
    FOR  ${i}  IN RANGE  0  ${UFS_DEVICE_LOGICAL_UNITS}
        ${DISK_LETTER}=                 Map Index To Disk Letter    ${i}
        ${DISK_DEVICE}=                 Set Variable  /dev/sd${DISK_LETTER}
        ${FILE_PATH}=                   Set Variable  ${MOUNT_POINT}/file${DISK_LETTER}
        Execute Linux Command           mke2fs -b ${UFS_DEVICE_LOGICAL_BLOCK_SIZE} ${DISK_DEVICE}
        Execute Linux Command           mount ${DISK_DEVICE} ${MOUNT_POINT}
        ${RANDOM_STRING}=               Generate Random String  40
        Append To List                  ${OUTPUT_LIST}   ${RANDOM_STRING}
        Execute Linux Command           echo "${RANDOM_STRING}" > ${FILE_PATH}
        Execute Linux Command           umount ${MOUNT_POINT}
    END

    # Verify if data persists after umount/mount cycle
    FOR  ${i}  IN RANGE  0  ${UFS_DEVICE_LOGICAL_UNITS}
        ${DISK_LETTER}=                 Map Index To Disk Letter    ${i}
        ${DISK_DEVICE}=                 Set Variable  /dev/sd${DISK_LETTER}
        ${FILE_PATH}=                   Set Variable  ${MOUNT_POINT}/file${DISK_LETTER}
        Execute Linux Command           mount ${DISK_DEVICE} ${MOUNT_POINT}
        Write Line To Uart              cat ${FILE_PATH}
        Wait For Line On Uart           ${OUTPUT_LIST}[${i}]
        Execute Linux Command           umount ${MOUNT_POINT}
    END

Should Load Disk Image For UFS Storage From File
    Requires                        ufs-logged-in

    ${MOUNT_POINT}=                 Set Variable  /mnt
    ${LOGICAL_UNIT_INDEX}=          Set Variable  0
    
    ${DISK_LETTER}=                 Map Index To Disk Letter    ${LOGICAL_UNIT_INDEX}
    ${DISK_DEVICE}=                 Set Variable  /dev/sd${DISK_LETTER}

    Execute Command                 ufs.ufsStorage LoadFromFile ${LOGICAL_UNIT_INDEX} ${ZYNQ_UFS_TEST_DISK_IMG} False
    Execute Linux Command           mount ${DISK_DEVICE} ${MOUNT_POINT}  # Mounting should be successful as disk image contains valid filesystem
    Execute Linux Command           umount ${MOUNT_POINT}

# ufs-utils: https://github.com/westerndigitalcorporation/ufs-utils/tree/faf0fe153547f5d02315fa82159f925f0c9daef8
# was added to rootfs through buildroot's BR2_ROOTFS_OVERLAY configuration and is used for testing.
Should Handle Native UFS commands
    Requires                        ufs-logged-in

    Write Line To Uart              ufs-utils list_bsg
    Wait For Line On Uart           /dev/bsg/ufs-bsg0
    Wait For Prompt On Uart         ${PROMPT}

    Write Line To Uart              ufs-utils spec_version -p /dev/bsg/ufs-bsg0
    Wait For Line On Uart           4.0
    Wait For Prompt On Uart         ${PROMPT}

    # Unit Descriptors
    FOR  ${i}  IN RANGE  0  ${UFS_DEVICE_LOGICAL_UNITS}
        ${DESCR_TYPE_IDN}=              Convert To Integer  ${UNIT_DESCR_TYPE}
        Write Line To Uart              ufs-utils desc -t 2 -i ${i} --output_mode json -p /dev/bsg/ufs-bsg0
        Wait For Line On Uart           "bLength":45,
        Wait For Line On Uart           "bDescriptorType":${DESCR_TYPE_IDN},
        Wait For Line On Uart           "bUnitIndex":${i},
        Wait For Prompt On Uart         ${PROMPT}
    END

    FOR  ${desc_type}  IN  @{UFS_DESCR_SINGLETON_TYPES}
        ${DESCR_TYPE_IDN}=              Convert To Integer  ${desc_type}
        Write Line To Uart              ufs-utils desc -t ${DESCR_TYPE_IDN} --output_mode json -p /dev/bsg/ufs-bsg0
        Wait For Line On Uart           "bDescriptorType.*":${DESCR_TYPE_IDN},    treatAsRegex=true
        Wait For Prompt On Uart         ${PROMPT}
    END

    # String Descriptors
    ${cnt}=                             Get length    ${UFS_STRING_DESCRIPTORS}
    ${DESCR_TYPE_IDN}=                  Convert To Integer  ${STRING_DESCR_TYPE}
    FOR  ${i}  IN RANGE  0  ${cnt}
        ${DESCRIPTOR}=                  Get Raw String Descriptor    "${UFS_STRING_DESCRIPTORS}[${i}]"
        Write Line To Uart              ufs-utils desc -t ${DESCR_TYPE_IDN} -i ${i} --output_mode raw -p /dev/bsg/ufs-bsg0
        Wait For Line On Uart           ${DESCRIPTOR}
        Wait For Prompt On Uart         ${PROMPT}
    END