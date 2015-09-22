#!/bin/bash
module load ci
echo "checking $NAME"
#cd $WORKSPACE/$NAME-$VERSION
cd $WORKSPACE/Python-$VERSION
# Python site packages are separated out by major version numbers, so we extract that to use it later
# in the PYTHONPATH
VERSION_MAJOR=${VERSION:0:3} # Should be 2.7 or 3.4 or similar

echo $?

make install # DESTDIR=$SOFT_DIR

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
module-whatis   "$NAME $VERSION."
setenv       PYTHON_VERSION       $VERSION
setenv       PYTHON_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
#setenv       PYTHONHOME        $::env(PYTHON_DIR)
setenv       PYTHONPATH        $::env(PYTHON_DIR/lib/python$VERSION_MAJOR)
prepend-path PATH              $::env(PYTHON_DIR)/bin
prepend-path LD_LIBRARY_PATH   $::env(PYTHON_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(PYTHON_DIR)/include
MODULE_FILE
) > modules/$VERSION

mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION $LIBRARIES_MODULES/$NAME
module add python/$VERSION
python --version

### time to install setuptools
cd $WORKSPACE/Python-$VERSION
# First, download the setuptools package and unpack it
wget https://pypi.python.org/packages/source/s/setuptools/setuptools-18.3.2.tar.gz
tar xfz setuptools-18.3.2.tar.gz
python setup.py install --prefix=${PYTHON_DIR}

## time to install pip - this also has to go into the python path.
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py --install-option=--prefix=${PYTHON_DIR}

## run some checks

which easy_install
which pip
