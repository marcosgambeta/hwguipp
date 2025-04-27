#include "hwguipp.ch"

FUNCTION Main()

   LOCAL oDialog
   LOCAL oButtonOk
   LOCAL oButtonCancel

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   @ (320 - 100) / 2, 280 BUTTON oButtonOk CAPTION "&Ok" OF oDialog ID IDOK SIZE 100, 32 CLASS MyButton

   @ (320 - 100) / 2 + 320, 280 BUTTON oButtonCancel CAPTION "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32 CLASS MyButton

   ACTIVATE DIALOG oDialog

   hwg_MsgInfo("oButtonOk:ClassName() = " + oButtonOk:ClassName(), "Info")
   hwg_MsgInfo("oButtonCancel:ClassName() = " + oButtonCancel:ClassName(), "Info")

   IF oDialog:lResult
      hwg_MsgInfo("OK", "Info")
   ELSE
      hwg_MsgInfo("CANCEL", "Info")
   ENDIF

RETURN NIL

#include <hbclass.ch>

CLASS MyButton FROM HButton
END CLASS
