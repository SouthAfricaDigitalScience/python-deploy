#!/bin/bash -e
. /etc/profile.d/modules.sh
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
module add deploy
module add zlib
module add gcc/${GCC_VERSION}
cd ${WORKSPACE}/Python-${VERSION}/build-${BUILD_NUMBER}
make distclean
./configure --prefix=${SOFT_DIR}-gcc-${GCC_VERSION} --enable-shared
make

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
#setenv       PYTHONHOME        $::env(PYTHON_DIR)
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
which python
python --version

### time to install setuptools
echo "Setting up setuptools"
cd $WORKSPACE/Python-${VERSION}
# First, download the setuptools package and unpack it
python setup.py install --prefix=${PYTHON_DIR}

## time to install pip - this also has to go into the python path.
echo "Setting up pip"
python get-pip.py --install-option=--prefix=${PYTHON_DIR}

## run some checks
echo "checking easy_install and pip"

which easy_install
which pip
