#!/bin/bash
# build.sh
#
# $Id: build.sh 2828 2020-04-14 13:47:16Z df7be $
#
# Building contrib libraries of HWGUI

CLEAN()
{
   rm -f ../lib/libhwg_misc.a
   rm -f ../lib/libhwg_qhtm.a
   rm -f ../lib/libhwg_extctrl.a
#   rm -f ../lib/libhbactivex.a
   rm -f ../lib/*.bak
   rm -f obj/*.o
   rm -f obj/*.c
}

if [ "$1" == "clean" ]; then
 CLEAN
 exit
fi



if [ ! -d "../lib" ]; then
   mkdir ../lib
fi

if [ ! -d obj ]; then
 mkdir obj
fi

# BUILD

   make -f makefile.linux


# EXIT

