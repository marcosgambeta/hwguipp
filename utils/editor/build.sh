#!/bin/bash
#
# build.sh
#
# Script buildung HWGUI editor utility for LINUX/GTK
#
# Configure path to Harbour to your own needs
#export HB_ROOT=../../..
export HB_ROOT=$HOME/Harbour/core-master

if [ "x$HB_ROOT" = x ]; then
export HRB_BIN=/usr/local/bin
export HRB_INC=/usr/local/include/harbour
# 32 bit
export HRB_LIB=/usr/local/lib/harbour
# 64 bit
# export HRB_LIB=/usr/local/lib64/harbour
else
export HRB_BIN=$HB_ROOT/bin/linux/gcc
export HRB_INC=$HB_ROOT/include
export HRB_LIB=$HB_ROOT/lib/linux/gcc
fi

export SYSTEM_LIBS="-lm -lrt -lpcre"

export HARBOUR_LIBS="-lhbdebug -lhbvmmt -lhbrtl -lgtcgi -lhblang -lhbrdd -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcpage -lhbct"
export HWGUI_LIBS="-lhwgui -lprocmisc -lhbxml -lhwgdebug"
export HWGUI_INC=../../include
export HWGUI_LIB=../../lib

$HRB_BIN/harbour editor -n -i$HRB_INC -i$HWGUI_INC -w2 -d__LINUX__ -d__GTK__ 2>bldh.log
$HRB_BIN/harbour hcediext -n -i$HRB_INC -i$HWGUI_INC -w2 -d__LINUX__ -d__GTK__ 2>>bldh.log
$HRB_BIN/harbour calc -n -i$HRB_INC -i$HWGUI_INC -w2 -d__LINUX__ -d__GTK__ 2>>bldh.log

gcc editor.c hcediext.c calc.c -oeditor -I $HRB_INC -I $HWGUI_INC -I ../../../source/gtk -L $HRB_LIB -L $HWGUI_LIB -Wl,--start-group $HWGUI_LIBS $HARBOUR_LIBS -Wl,--end-group `pkg-config --cflags gtk+-2.0` `pkg-config gtk+-2.0 --libs` $SYSTEM_LIBS >bld.log 2>bld.log

rm *.c 2>/dev/null
rm *.o 2>/dev/null
