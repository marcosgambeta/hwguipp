@echo off
REM build designer for OpenWatCom C compiler on Windows
REM $Id: blddeswc.bat 2858 2020-06-22 06:29:41Z df7be $
REM by DF7BE

REM before use, set environment with script:
REM ..\..\samples\dev\env\pfad_wc.bat

REM configure installation path of Harbour to your own needs
SET HRB_DIR=C:\Harbour_wc\core-master
REM
REM HRB_LIBS=%HRB_DIR%\lib\win\watcom
set HRB_EXE=%HRB_DIR%\bin\win\watcom\harbour.exe
REM configure HWGUI install (current dir is utils\designer )
set HWGUI_INSTALL=..\..

hbmk2 designer2.hbp -I%HWGUI_INSTALL%\include -L%HWGUI_INSTALL%\lib -lhwgui -lprocmisc -lhbxml -lhwgdebug -gui
