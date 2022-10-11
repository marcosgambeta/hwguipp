#include "hwgui.ch"

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

#include "hbclass.ch"

CLASS MyDialog FROM HDialog

   DATA oLabel1
   DATA oDatePicker1
   DATA oLabel2
   DATA oDatePicker2
   DATA oLabel3
   DATA oDatePicker3
   DATA oButtonOK
   DATA oButtonCancel

   METHOD myMethod

ENDCLASS

METHOD myMethod() CLASS MyDialog

   WITH OBJECT ::oLabel1 := HStatic():new()
      :title   := "Label1"
      :nX      := 20
      :nY      := 20
      :nWidth  := 120
      :nHeight := 30
   ENDWITH

   WITH OBJECT ::oDatePicker1 := HDatePicker():new()
      :title   := "DatePicker1"
      :nX      := 120
      :nY      := 20
      :nWidth  := 120
      :nHeight := 30
      :dValue  := date() - 30
   ENDWITH

   WITH OBJECT ::oLabel2 := HStatic():new()
      :title   := "Label2"
      :nX      := 20
      :nY      := 60
      :nWidth  := 120
      :nHeight := 30
   ENDWITH

   WITH OBJECT ::oDatePicker2 := HDatePicker():new()
      :title   := "DatePicker2"
      :nX      := 120
      :nY      := 60
      :nWidth  := 120
      :nHeight := 30
      :dValue  := date()
   ENDWITH

   WITH OBJECT ::oLabel3 := HStatic():new()
      :title   := "Label3"
      :nX      := 20
      :nY      := 100
      :nWidth  := 120
      :nHeight := 30
   ENDWITH

   WITH OBJECT ::oDatePicker3 := HDatePicker():new()
      :title   := "DatePicker3"
      :nX      := 120
      :nY      := 100
      :nWidth  := 120
      :nHeight := 30
      :dValue  := date() + 30
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
