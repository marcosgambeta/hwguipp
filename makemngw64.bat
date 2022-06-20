REM
REM makemngw64.bat
REM
REM Build HWGUI libraries with MinGW 64 bit (x86_64)
REM
REM $Id: makemngw64.bat 2852 2020-06-08 07:31:17Z df7be $
REM
REM > libhwgui.a
hbmk2 hwgui.hbm hwgui.hbp
REM > libhbxml.a
hbmk2 hbxml.hbp
REM > libhwgdebug.a
hbmk2 hwgdebug.hbp
REM > libprocmisc.a
hbmk2 procmisc.hbp
REM
REM ======================== EOF of makemngw64.bat ========================