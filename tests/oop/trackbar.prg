#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oTrackBar
   LOCAL oLabelValue
   LOCAL oButtonGet
   LOCAL oButtonSet

   WITH OBJECT oDialog := HDialog():new()

      :title   := "Test"
      :nWidth  := 640
      :nHeight := 480

      WITH OBJECT oTrackBar := HTrackBar():new()
         :nX      := 20
         :nY      := 20
         :nWidth  := 300
         :nHeight := 50
         :nLow    := 0
         :nHigh   := 10
         :nValue  := 5
         :bChange := {||oLabelValue:SetText(AllTrim(Str(oTrackBar:Value)))}
      ENDWITH

      WITH OBJECT oLabelValue := HStatic():new()
         :title   := "5"
         :nX      := 100
         :nY      := 100
         :nWidth  := 40
         :nHeight := 40
      ENDWITH

      WITH OBJECT oButtonGet := HButton():new()
         :title   := "&Get value"
         :nX      := 300
         :nY      := 200
         :nWidth  := 100
         :nHeight := 40
         :bClick  := {||hwg_Msginfo(AllTrim(Str(oTrackBar:Value)))}
      ENDWITH

      WITH OBJECT oButtonSet := HButton():new()
         :title   := "&Set value"
         :nX      := 300
         :nY      := 300
         :nWidth  := 100
         :nHeight := 40
         :bClick  := {||oTrackBar:Value := 5, oLabelValue:SetText(AllTrim(Str(oTrackBar:Value)))}
      ENDWITH

      :activate()

   ENDWITH

RETURN
