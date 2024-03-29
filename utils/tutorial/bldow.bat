@echo off
REM build HWGUI tutor for OpenWatCom C on Windows
REM by DF7BE
REM 2020-06-30

REM before use, set environment with script:
REM ..\..\samples\dev\env\pfad_wc.bat

REM Ignore warning:
REM Warning! W1008: cannot open hbactivex.lib : No such file or directory

REM configure installation path of Harbour to your own needs
SET HRB_DIR=C:\Harbour_wc\core-master
REM
REM HRB_LIBS=%HRB_DIR%\lib\win\watcom
set HRB_LIB_DIR=%HB_PATH%\lib\win\watcom
set HRB_EXE=%HRB_DIR%\bin\win\watcom\harbour.exe
REM configure HWGUI install (current dir is utils\tutorial )
set HWGUI_INSTALL=..\..
SET HWG_LIBS=-lhwgui -lprocmisc -lhbxml -lhwgdebug


hbmk2 tutor.hbp -I%HWGUI_INSTALL%\include -L%HWGUI_INSTALL%\lib %HWG_LIBS% -gui
hbmk2 hwgrun.hbp -I%HWGUI_INSTALL%\include -L%HWGUI_INSTALL%\lib %HWG_LIBS% -gui
