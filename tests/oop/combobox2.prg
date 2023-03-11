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

#include "hbclass.ch"

CLASS MyDialog FROM HDialog

   DATA oLabel1
   DATA oComboBox1
   DATA oLabel2
   DATA oComboBox2
   DATA oLabel3
   DATA oComboBox3
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

   WITH OBJECT ::oComboBox1 := HComboBox():new()
      :title   := "ComboBox1"
      :nX      := 120
      :nY      := 20
      :nWidth  := 120
      :nHeight := 30 * 5
   ENDWITH

   WITH OBJECT ::oLabel2 := HStatic():new()
      :title   := "Label2"
      :nX      := 20
      :nY      := 60
      :nWidth  := 120
      :nHeight := 30
   ENDWITH

   WITH OBJECT ::oComboBox2 := HComboBox():new()
      :title   := "ComboBox2"
      :nX      := 120
      :nY      := 60
      :nWidth  := 120
      :nHeight := 30 * 5
      :aItems  := {"Item1", "Item2", "Item3", "Item4", "Item5"}
   ENDWITH

   WITH OBJECT ::oLabel3 := HStatic():new()
      :title   := "Label3"
      :nX      := 20
      :nY      := 100
      :nWidth  := 120
      :nHeight := 30
   ENDWITH

   WITH OBJECT ::oComboBox3 := HComboBox():new()
      :title   := "ComboBox3"
      :nX      := 120
      :nY      := 100
      :nWidth  := 120
      :nHeight := 30 * 5
      :aItems  := {"Item1", "Item2", "Item3", "Item4", "Item5"}
      :SetItem(3)
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
