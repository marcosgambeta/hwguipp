#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oLabel
   LOCAL oTimer

   WITH OBJECT oDialog := HDialog():new()
      :title := "Test"
      :nWidth := 640
      :nHeight := 480
      :bInit := {||
         SET TIMER oTimer OF oDialog VALUE 100 ACTION {||oLabel:SetText(time())}
         }
      :bActivate := {||oDialog:center()}

      WITH OBJECT oLabel := HStatic():new()
         :title   := time()
         :nLeft   := 20
         :nTop    := 20
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      :activate()

   ENDWITH

RETURN
