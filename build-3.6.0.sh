#!/bin/bash -e
. /etc/profile.d/modules.sh
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
module add ci
module add bzip2
module add tcltk
module add sqlite
module add readline
module add ncurses
module add openssl/1.0.2j
module add gcc/${GCC_VERSION}

echo ${SOFT_DIR}
echo ${WORKSPACE}
echo ${SRC_DIR}
mkdir -p ${SOFT_DIR}-gcc-${GCC_VERSION}
mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "looks like the tarball isn't there yet"
  wget --no-check-certificate https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tgz -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
fi
tar -xz --keep-newer-files -f ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE}
# echo $NAME | tr '[:upper:]' '[:lower:]'
# Again with the frikkin naming conventions
cd ${WORKSPACE}/Python-${VERSION}
mkdir build-${BUILD_NUMBER}
cd build-${BUILD_NUMBER}

export CFLAGS="-I${SQLITE_DIR}/include \
  -I${BZLIB_DIR}/include/ \
  -I${READLINE_DIR}/include/ \
  -I${NCURSES_DIR}/include/"

 export CPPFLAGS="-I${SQLITE_DIR}/include \
  -I${BZLIB_DIR}/include/ \
  -I${READLINE_DIR}/include/ \
  -I${NCURSES_DIR}/include/"

export LDFLAGS="-L${SQLITE_DIR}/lib \
 -L${BZLIB_DIR}/lib/ \
 -L${READLINE_DIR}/lib/ \
 -L${OPENSSL_DIR}/lib \
 -L${NCURSES_DIR}/lib/"

../configure --prefix=${SOFT_DIR}-gcc-${GCC_VERSION} \
--build=x86_64-unknown-linux-gnu \
--with-system-zlib \
--disable-ipv6 \
--enable-shared \
--enable-loadable-sqlite-extensions \
--with-system-ffi \
--with-libs="-lbz2 -lreadline -lncurses -lhistory -lsqlite3 -lssl" \
--with-ensurepip=upgrade
make
