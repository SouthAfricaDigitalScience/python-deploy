#!/bin/bash -e
. /etc/profile.d/modules.sh
module load ci
module add zlib
module add bzip2
module add tcltk
module add sqlite
module add readline
module add ncurses
module add openssl/1.0.2g
module add  gcc/${GCC_VERSION}
echo "checking $NAME"
cd ${WORKSPACE}/Python-${VERSION}/build-${BUILD_NUMBER}
# Python site packages are separated out by major version numbers, so we extract that to use it later
# in the PYTHONPATH
VERSION_MAJOR=${VERSION:0:3} # Should be 2.7 or 3.4 or similar

export CFLAGS="-I${SQLITE_DIR}/include \
  -I${OPENSSL_DIR}/include \
 -I${ZLIB_DIR}/include/ \
 -I${BZIP_DIR}/include/ \
 -I${READLINE_DIR}/include/ \
 -I${TCL_DIR}/include/ \
 -I${NCURSES_DIR}/include/"

export LDFLAGS="-L${SQLITE_DIR}/lib \
-L${OPENSSL_DIR}/lib \
-L${ZLIB_DIR}/lib/ \
-L${BZLIB_DIR}/lib/ \
-L${READLINE_DIR}/lib/ \
-L${TCL_DIR}/lib/ \
-L${NCURSES_DIR}/lib/"


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

ls ${SOFT_DIR}-gcc-${GCC_VERSION}/bin
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
prepend-path CFLAGS            "-I$::env(PYTHON_DIR)/include"
prepend-path LDFLAGS           "-L$::env(PYTHON_DIR)/lib"
MODULE_FILE
) > modules/$VERSION-gcc-${GCC_VERSION}

mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION-gcc-${GCC_VERSION} $LIBRARIES_MODULES/$NAME
module add python/$VERSION-gcc-${GCC_VERSION}
echo "Our python is"
which python
python --version

### time to install setuptools
## According to http://python-packaging-user-guide.readthedocs.org/en/latest/installing/#install-pip-setuptools-and-wheel
# if you have Python 2 >=2.7.9 or Python 3 >=3.4 installed from python.org, you will already have pip and setuptools,
# but will need to upgrade to the latest version:
# pip install -U pip setuptools
echo "Setting up setuptools"
cd $WORKSPACE/Python-${VERSION}
# First, download the setuptools package and unpack it
SETUPTOOLS=setuptools-18.3.2
if [ ! -e ${SRC_DIR}/${SETUPTOOLS}.lock ] && [ ! -s ${SRC_DIR}/${SETUPTOOLS} ] ; then
  touch  ${SRC_DIR}/${SETUPTOOLS}.lock
  echo "looks like the tarball isn't there yet"
  wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/${SETUPTOOLS}.tar.gz -O ${SRC_DIR}/${SETUPTOOLS}.tar.gz
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SETUPTOOLS}.lock
elif [ -e ${SRC_DIR}/${SETUPTOOLS}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SETUPTOOLS}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
fi
tar xfz ${SRC_DIR}/${SETUPTOOLS}.tar.gz -C ${WORKSPACE}/Python-${VERSION}
cd ${WORKSPACE}/Python-${VERSION}/${SETUPTOOLS}
python setup.py install --prefix=${PYTHON_DIR}

## run some checks
echo "checking easy_install and pip"

which easy_install
which pip
