#!/bin/bash -e
. /etc/profile.d/modules.sh
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
module add deploy
module add zlib
module add bzip2
module add tcltk
module add sqlite
module add readline
module add ncurses
module add gcc/${GCC_VERSION}
cd ${WORKSPACE}/Python-${VERSION}/build-${BUILD_NUMBER}
rm -rf *
../configure --prefix=${SOFT_DIR}-gcc-${GCC_VERSION} --enable-shared
make
# "Warning
# make install can overwrite or masquerade the python binary. make altinstall is therefore recommended instead of make install since it
# only installs exec_prefix/bin/pythonversion.
# see : https://docs.python.org/2/using/unix.html#building-python
make install

VERSION_MAJOR=${VERSION:0:3} # Should be 2.7 or 3.4 or similar
echo $?
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}
conflict python
module add gcc/${GCC_VERSION}
module-whatis   "$NAME $VERSION. compiled  for GCC ${GCC_VERSION}"
setenv       PYTHON_VERSION       $VERSION
setenv       PYTHON_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
setenv       PYTHONHOME        $::env(PYTHON_DIR)
setenv       PYTHONPATH        $::env(PYTHON_DIR)/lib/python${VERSION_MAJOR}
prepend-path PATH              $::env(PYTHON_DIR)/bin
prepend-path LD_LIBRARY_PATH   $::env(PYTHON_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(PYTHON_DIR)/include
MODULE_FILE
) > modules/$VERSION-gcc-${GCC_VERSION}

# this should probably be in $PYTHON_MODULES instead of $LIBRARY_MODULES

mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/${VERSION}-gcc-${GCC_VERSION} ${LIBRARIES_MODULES}/${NAME}
module add python/${VERSION}-gcc-${GCC_VERSION}
echo "Our python is"
which python3
python3 --version

## run some checks
echo "PYTHONHOME is $PYTHONHOME"
echo "checking easy_install and pip"

which easy_install-${VERSION_MAJOR}
which pip${VERSION_MAJOR}
