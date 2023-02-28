#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oBrowse

   WITH OBJECT oDialog := HDialog():new()

      :title   := "Test"
      :nWidth  := 640
      :nHeight := 480

      WITH OBJECT oBrowse := HBrowse():new()
         :nX      := 20
         :nY      := 20
         :nWidth  := 640 - 40
         :nHeight := 480 - 40
      ENDWITH

      :activate()

   ENDWITH

RETURN
