[![Build Status](https://ci.sagrid.ac.za/buildStatus/icon?job=python-deploy)](https://ci.sagrid.ac.za/job/python-deploy)

# python-deploy

Build, test and deploy scripts necessary to deploy Python.

Versions:

  * ~2.6.9~
  * ~2.7.11~
  * 2.7.13
  * ~3.4.1~
  * 3.6.0

# Dependencies

  * zlib
  * bzip2
  * tcltk
  * sqlite
  * readline
  * ncurses
  * openssl/1.0.2g
  * gcc/${GCC_VERSION}

## GCC versions

  * 4.9.2
  * 5.1.0

# Configuration

```
--enable-shared \
--enable-loadable-sqlite-extensions \
--with-system-ffi \
--with-tcltk-includes=${TCL_DIR}/include \
--with-tcltk-libs=${TCL_DIR}/lib \
--with-ensurepip=upgrade
```

# Citing
