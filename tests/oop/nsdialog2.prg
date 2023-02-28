#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog

   WITH OBJECT oDialog := MyDialog():new()
      :title   := "My dialog window"
      :nWidth  := 640
      :nHeight := 480
      :myMethod()
      :activate()
   ENDWITH

RETURN

#include "hbclass.ch"

CLASS MyDialog FROM HDialog

   METHOD myMethod

ENDCLASS

METHOD myMethod() CLASS MyDialog

   hwg_MsgInfo("Executing MyMethod from MyDialog", "Information")

RETURN NIL
