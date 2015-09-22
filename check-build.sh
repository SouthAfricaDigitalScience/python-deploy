#!/bin/bash
module load ci
echo "checking $NAME"
#cd $WORKSPACE/$NAME-$VERSION
cd $WORKSPACE/Python-$VERSION



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
setenv       PYTHONHOME       $::env(PYTHON_DIR)
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
