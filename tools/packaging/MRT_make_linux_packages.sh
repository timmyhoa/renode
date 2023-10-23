#!/usr/bin/env bash

set -e
set -u

#change dir to script location
cd "${0%/*}"
. common_make_packages.sh

if ! is_dep_available gem
then
    exit 1
fi

export PATH=`gem environment gemdir`/bin:$PATH

#expand this list if needed. bsdtar is required for arch packages.
if ! is_dep_available fpm ||\
    ! is_dep_available rpm ||\
    ! is_dep_available bsdtar
then
    exit 1
fi

DIR=renode_$VERSION
INSTALL_DIR=/opt/renode

OS_NAME=linux
SED_COMMAND="sed -i"
. common_copy_files.sh

COMMON_SCRIPT=$DIR/tests/common.sh
TEST_SCRIPT=linux/renode-test
copy_bash_tests_scripts $TEST_SCRIPT $COMMON_SCRIPT

COMMAND_SCRIPT=linux/renode
echo "#!/bin/sh" > $COMMAND_SCRIPT
echo "MONOVERSION=$MONOVERSION" >> $COMMAND_SCRIPT
echo "REQUIRED_MAJOR=$MONO_MAJOR" >> $COMMAND_SCRIPT
echo "REQUIRED_MINOR=$MONO_MINOR" >> $COMMAND_SCRIPT
# skip the first line (with the hashbang)
tail -n +2 linux/renode-template >> $COMMAND_SCRIPT
chmod +x $COMMAND_SCRIPT

PACKAGES=output/packages
OUTPUT=$BASE/$PACKAGES

GENERAL_FLAGS=(\
    -f -n renode -v $VERSION --license MIT\
    --category devel --provides renode -a native\
    -m 'Antmicro <renode@antmicro.com>'\
    --vendor 'Antmicro <renode@antmicro.com>'\
    --description 'The Renode Framework'\
    --url 'www.renode.io'\
    --after-install linux/update_icon_cache.sh\
    --after-remove linux/update_icon_cache.sh\
    --license MIT\
    $DIR/=$INSTALL_DIR\
    $TEST_SCRIPT=/usr/bin/renode-test\
    $COMMAND_SCRIPT=/usr/bin/renode\
    linux/Renode.desktop=/usr/share/applications/Renode.desktop\
    linux/icons/128x128/apps/renode.png=/usr/share/icons/hicolor/128x128/apps/renode.png
    linux/icons/16x16/apps/renode.png=/usr/share/icons/hicolor/16x16/apps/renode.png
    linux/icons/24x24/apps/renode.png=/usr/share/icons/hicolor/24x24/apps/renode.png
    linux/icons/32x32/apps/renode.png=/usr/share/icons/hicolor/32x32/apps/renode.png
    linux/icons/48x48/apps/renode.png=/usr/share/icons/hicolor/48x48/apps/renode.png
    linux/icons/64x64/apps/renode.png=/usr/share/icons/hicolor/64x64/apps/renode.png
    linux/icons/scalable/apps/renode.svg=/usr/share/icons/hicolor/scalable/apps/renode.svg
    )

### create debian package
fpm -s dir -t deb\
    -d "mono-complete >= $MONOVERSION" -d gtk-sharp2 -d screen -d policykit-1 -d libc6-dev -d gcc -d python3 -d python3-pip \
    --deb-no-default-config-files \
    "${GENERAL_FLAGS[@]}" >/dev/null

mkdir -p $OUTPUT
deb=(renode*deb)
mv $deb $OUTPUT

#cleanup unless user requests otherwise
if $REMOVE_WORKDIR
then
    rm -rf $DIR
    rm $COMMAND_SCRIPT
    rm $TEST_SCRIPT
fi
