#!/bin/bash
if [ "$#" -ne 1 ]
then
    echo "Illegal number of parameters"
    exit 1
fi


export C_INCLUDE_PATH=/project/melt/Software/ext-libs/usr/local/include
export LIBRARY_PATH=/project/melt/Software/ext-libs/usr/local/lib

SOURCE_FILENAME=$1
BASE_FILENAME=${SOURCE_FILENAME%\.xc}
C_FILENAME="$BASE_FILENAME.pp_out.c"

echo "Translating $SOURCE_FILENAME" &&
java -jar ableC.jar $SOURCE_FILENAME -Iinclude &&
echo "Compiling $C_FILENAME" &&
gcc -o $BASE_FILENAME $C_FILENAME -lgc &&
echo "Executable $BASE_FILENAME generated"