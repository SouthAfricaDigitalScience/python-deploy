#!/bin/bash -e
. /etc/profile.d/modules.sh
module load ci
module add zlib
module add bzlib
module add tcltk
module add sqlite
module add readline
module add ncurses
module add  gcc/${GCC_VERSION}
echo "checking $NAME"
cd ${WORKSPACE}/Python-${VERSION}/build-${BUILD_NUMBER}
# Python site packages are separated out by major version numbers, so we extract that to use it later
# in the PYTHONPATH
VERSION_MAJOR=${VERSION:0:3} # Should be 2.7 or 3.4 or similar
if make test 2> tests.out
then : tests have passed
else : tests have failed see test.out
fi
echo $?
# "Warning
# make install can overwrite or masquerade the python binary. make altinstall is therefore recommended instead of make install since it
# only installs exec_prefix/bin/pythonversion.
# see : https://docs.python.org/2/using/unix.html#building-python
make install
# alt install seemd to have not installed the binaries.
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
setenv       PYTHON_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
setenv       PYTHONHOME        $::env(PYTHON_DIR)
setenv       PYTHONPATH        $::env(PYTHON_DIR)/lib/python${VERSION_MAJOR}
prepend-path PATH              $::env(PYTHON_DIR)/bin
prepend-path LD_LIBRARY_PATH   $::env(PYTHON_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(PYTHON_DIR)/include
MODULE_FILE
) > modules/$VERSION-gcc-${GCC_VERSION}

mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION-gcc-${GCC_VERSION} $LIBRARIES_MODULES/$NAME
module add python/$VERSION-gcc-${GCC_VERSION}
echo "Our python is"
which python
python --version

### time to install setuptools
echo "Setting up setuptools"
cd $WORKSPACE/Python-${VERSION}
# First, download the setuptools package and unpack it
wget https://pypi.python.org/packages/source/s/setuptools/setuptools-18.3.2.tar.gz
tar xfz setuptools-18.3.2.tar.gz
python setup.py install --prefix=${PYTHON_DIR}

## time to install pip - this also has to go into the python path.

# checkif PIP is there.
echo "Getting pip"
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py --install-option=--prefix=${PYTHON_DIR}

## run some checks
echo "checking easy_install and pip"

which easy_install
which pip
