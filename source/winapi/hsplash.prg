//
// HwGUI Harbour Win32 Gui Copyright (c) Alexander Kresin
//
// HwGUI HSplash Class
//
// Copyright (c) Sandro R. R. Freire <sandrorrfreire@yahoo.com.br>
//

#include <hbclass.ch>
#include "hwguipp.ch"

// ---- Bugfixing MinGW64 by DF7BE:
// With call
// gcc -Wall -O3 -c -Iinclude -IC:\harbour64\core-master/include -o obj/hsplash.o obj/hsplash.c
// the gcc ended immediately without any error messages nor creating object output file:
// The make systems say:
// mingw32-make.exe: Interrupt/Exception caught (code = 0xc0000005, addr = 0x00007FFDD11C0BC4)
// Need to add #include "hwingui.hpp" at the BEGINNING of the generated c file.
// That not possible.
// Build HWGUI only with command:
//   hbmk2 hwgui.hbp procmisc.hbp hbxml.hbp hwgdebug.hbp

#if 0
#pragma BEGINDUMP

#include "hwingui.hpp"

#pragma ENDDUMP
#endif


CLASS HSplash

   DATA oTimer

   METHOD Create(cFile, oTime, oResource) CONSTRUCTOR
   METHOD CountSeconds(oTime, oDlg)

ENDCLASS

METHOD HSplash:Create(cFile, oTime, oResource)

   LOCAL aWidth
   LOCAL aHeigth
   LOCAL bitmap
   LOCAL oDlg

   IIf(Empty(oTime) .OR. oTime == NIL, oTime := 2000, oTime := oTime)

   IF oResource == NIL .OR. !oResource
      bitmap := HBitmap():AddFile(cFile)
   ELSE
      bitmap := HBitmap():AddResource(cFile)
   ENDIF

   aWidth := bitmap:nWidth
   aHeigth := bitmap:nHeight

   INIT DIALOG oDlg TITLE "" ;
        At 0, 0 SIZE aWidth, aHeigth  STYLE WS_POPUP + DS_CENTER + WS_VISIBLE + WS_DLGFRAME ;
        BACKGROUND bitmap bitmap ON INIT {||::CountSeconds(oTime, oDlg)}

   oDlg:Activate()
   ::oTimer:END()

   RETURN Self

METHOD HSplash:CountSeconds(oTime, oDlg)

   SET TIMER ::oTimer OF oDlg VALUE oTime  ACTION {||hwg_EndDialog(hwg_GetModalHandle())}

   RETURN NIL
