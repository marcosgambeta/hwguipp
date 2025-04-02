#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oDialog

   WITH OBJECT oDialog := MyDialog():new()
      :title   := "My dialog window"
      :nWidth  := 320
      :nHeight := 240
      :myMethod()
      :activate()
   ENDWITH

RETURN

#include <hbclass.ch>

CLASS MyDialog FROM HDialog

   DATA oLabelId
   DATA oEditId
   DATA oLabelName
   DATA oEditName
   DATA oLabelPhone
   DATA oEditPhone
   DATA oButtonOK
   DATA oButtonCancel

   METHOD myMethod

ENDCLASS

METHOD myMethod() CLASS MyDialog

   WITH OBJECT ::oLabelId := HStatic():new()
      :title   := "Id"
      :nX      := 20
      :nY      := 20
      :nWidth  := 120
      :nHeight := 30
   ENDWITH

   WITH OBJECT ::oEditId := HEdit():new()
      :title   := "Id"
      :nX      := 120
      :nY      := 20
      :nWidth  := 120
      :nHeight := 30
   ENDWITH

   WITH OBJECT ::oLabelName := HStatic():new()
      :title   := "Name"
      :nX      := 20
      :nY      := 60
      :nWidth  := 120
      :nHeight := 30
   ENDWITH

   WITH OBJECT ::oEditName := HEdit():new()
      :title   := "Name"
      :nX      := 120
      :nY      := 60
      :nWidth  := 120
      :nHeight := 30
   ENDWITH

   WITH OBJECT ::oLabelPhone := HStatic():new()
      :title   := "Phone"
      :nX      := 20
      :nY      := 100
      :nWidth  := 120
      :nHeight := 30
   ENDWITH

   WITH OBJECT ::oEditPhone := HEdit():new()
      :title   := "Phone"
      :nX      := 120
      :nY      := 100
      :nWidth  := 120
      :nHeight := 30
   ENDWITH

   WITH OBJECT ::oButtonOK := HButton():new()
      :title  := "&OK"
      :nX     := 20
      :nY     := 140
      :bClick := {||hwg_MsgInfo("OK clicked", "Information")}
   ENDWITH

   WITH OBJECT ::oButtonCancel := HButton():new()
      :title  := "&Cancel"
      :nX     := 120
      :nY     := 140
      :bClick := {||hwg_MsgInfo("Cancel clicked", "Information")}
   ENDWITH

RETURN NIL
