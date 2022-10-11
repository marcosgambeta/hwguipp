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

   DATA oButtonOK
   DATA oButtonCancel

   METHOD myMethod

ENDCLASS

METHOD myMethod() CLASS MyDialog

   WITH OBJECT ::oButtonOK := HButton():new()
      :title  := "&OK"
      :nX     := 20
      :nY     := 20
      :bClick := {||hwg_MsgInfo("OK clicked", "Information")}
   ENDWITH

   WITH OBJECT ::oButtonCancel := HButton():new()
      :title  := "&Cancel"
      :nX     := 120
      :nY     := 20
      :bClick := {||hwg_MsgInfo("Cancel clicked", "Information")}
   ENDWITH

RETURN NIL
