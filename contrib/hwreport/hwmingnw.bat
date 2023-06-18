@echo off
REM
REM hwmingnw.bat
REM
REM  $Id: hwmingnw.bat 2961 2021-03-14 10:25:21Z df7be $
REM
REM Created by DF7BE 2019-09-27
REM Script building hwreport
REM for HWGUI on Windows with GTK+
REM (not the native Windows calls)
REM For test purposes.
REM Created by DF7BE
REM Build HWGUI GTK+ Programs 
REM using GTK+ Version 2
REM
REM Warning:
REM For normal use on Windows it is strictly recommended to build only the WinAPI
REM edition of HWGUI and your application. The WinAPI functions are quite stable and
REM effective.
REM Take the GTK build only for test- and development purposes ! 
REM Also it is strictly recommended to check the modified GTK sources
REM on Linux or another *NIX operating system before checking in into
REM a source repository.
REM For details read instructions in file
REM samples\dev\MingW-GTK\Readme.txt
REM #######################################

REM =====================================
REM configure all installation path's
REM Modify to your own needs:
REM Example 1
REM base path auf Mingw and Harbour Compiler
REM set GTK_INSTALL=C:/GTK
REM set MINGW=c:\mingw
REM set HRB_DIR=c:\dvl\hrb
REM set HWGUI_INSTALL=..\..

REM Example 2
REM this example for using Harbour and MingW of installed MiniGUI
REM set GTK_INSTALL=C:/GTK
REM set MINGW=C:\hmg.3.3.1\MINGW
REM set HRB_DIR=C:\hmg.3.3.1\HARBOUR

REM --- active settings ---
REM using own build Harbour
set GTK_INSTALL=C:/GTK
set MINGW=C:\hmg.3.3.1\MINGW
REM set HRB_DIR=C:\hmg.3.3.1\HARBOUR
set HRB_DIR=C:\harbour\core-master
SET HRB_EXE=%HRB_DIR%\bin\win\mingw\harbour

REM Installation path of HWGUI
REM set HWGUI_INSTALL=C:\hwgui\hwgui-gtk\hwgui
REM relative path
set HWGUI_INSTALL=..\..
REM =====================================


REM GTK libs and includes
REM set GTK_INCLUDE=-I"%GTK_INSTALL%/include/glib-2.0" -I"%GTK_INSTALL%/lib/glib-2.0/include" -I"%GTK_INSTALL%/include/gtk-2.0" -I"%GTK_INSTALL%/lib/gtk-2.0/include" -I"%GTK_INSTALL%/include/atk-1.0" -I"%GTK_INSTALL%/include/pango-1.0" -I"%GTK_INSTALL%/include/libglade-2.0" -I"%GTK_INSTALL%/include/libxml2" -I"%GTK_INSTALL%/include/cairo" -I"%GTK_INSTALL%/include"

SET GTK_LIB=-L"%GTK_INSTALL%/lib"
REM SET /p GTK_INC= | pkg-config --cflags gtk+-2.0
REM SET /p GTK_LIBS= | pkg-config gtk+-2.0 --libs
REM 
REM Libraries
set HRB_LIB_DIR=%HRB_DIR%\lib\win\mingw
set HRB_LIBS=-lhbdebug -lhbvm -lhbrtl -lgtcgi -lhbdebug -lhblang -lhbrdd -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcpage -lgtwin -lgtgui
set HWGUI_LIBS=-lhbxml -lhwgdebug -lhwgui -lprocmisc -lpcre
REM Windows-DLLs
set WIN_DLLS=-lcomctl32 -lole32 -lwinspool -loleaut32 -lshell32 -luuid -lwinmm

REM Build hwreport.exe

REM hwreport.prg
%HRB_EXE% hwreport.prg -n -w -i%HRB_DIR%\include;%HWGUI_INSTALL%\include -d__GTK__ %2
gcc -I. -I%HRB_DIR%\include -Wall -c hwreport.c -ohwreport.o
del hwreport.c


REM opensave.prg
%HRB_EXE% opensave.prg -n -w -i%HRB_DIR%\include;%HWGUI_INSTALL%\include -d__GTK__ %2
gcc -I. -I%HRB_DIR%\include -Wall -c opensave.c -oopensave.o
del opensave.c


REM propert.prg
%HRB_EXE% propert.prg -n -w -i%HRB_DIR%\include;%HWGUI_INSTALL%\include -d__GTK__ %2
gcc -I. -I%HRB_DIR%\include -Wall -c propert.c -opropert.o
del propert.c


REM printrpt.prg
%HRB_EXE% printrpt.prg -n -w -i%HRB_DIR%\include;%HWGUI_INSTALL%\include -d__GTK__ %2
gcc -I. -I%HRB_DIR%\include -Wall -c printrpt.c -oprintrpt.o
del printrpt.c


REM repexec.prg
%HRB_EXE% repexec.prg -n -w -i%HRB_DIR%\include;%HWGUI_INSTALL%\include -d__GTK__ %2
gcc -I. -I%HRB_DIR%\include -Wall -c repexec.c -orepexec.o
del repexec.c


REM --- Link with GTK+ V2 =====
gcc -Wall -mwindows -ohwreport.exe hwreport.o opensave.o propert.o printrpt.o  repexec.o -L%MINGW%\lib -L%HRB_LIB_DIR% -L%HWGUI_INSTALL%\lib %GTK_LIB%  -Wl,--allow-multiple-definition -Wl,--start-group  %HWGUI_LIBS% %HRB_LIBS% -lgtk-win32-2.0 -lgdk-win32-2.0 -latk-1.0 -lgdk_pixbuf-2.0 -lpangowin32-1.0 -lgdi32 -lpango-1.0 -lcairo -lgobject-2.0 -lgmodule-2.0 -lglib-2.0 -lintl -liconv -lgio-2.0  -lgdi32 -lpangocairo-1.0  -lgthread-2.0   %WIN_DLLS% -Wl,--end-group

REM Compile and link Hwreport example program


%HRB_EXE% example.prg -n -w -i%HRB_DIR%\include;%HWGUI_INSTALL%\include -d__GTK__ %2
gcc -I. -I%HRB_DIR%\include -Wall -c example.c -oexample.o
del example.c

gcc -Wall -mwindows -oexample.exe example.o repexec.o -L%MINGW%\lib -L%HRB_LIB_DIR% -L%HWGUI_INSTALL%\lib %GTK_LIB%  -Wl,--allow-multiple-definition -Wl,--start-group  %HWGUI_LIBS% %HRB_LIBS% -lgtk-win32-2.0 -lgdk-win32-2.0 -latk-1.0 -lgdk_pixbuf-2.0 -lpangowin32-1.0 -lgdi32 -lpango-1.0 -lcairo -lgobject-2.0 -lgmodule-2.0 -lglib-2.0 -lintl -liconv -lgio-2.0  -lgdi32 -lpangocairo-1.0  -lgthread-2.0   %WIN_DLLS% -Wl,--end-group

del hwreport.o
del opensave.o
del propert.o
del printrpt.o
del repexec.o
del example.o
