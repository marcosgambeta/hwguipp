#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oMonthCalendar

   WITH OBJECT oDialog := HDialog():new()

      :title   := "Test"
      :nWidth  := 640
      :nHeight := 480

      WITH OBJECT oMonthCalendar := HMonthCalendar():new()
         :nX      := 20
         :nY      := 20
         :nWidth  := 200
         :nHeight := 200
      ENDWITH

      :activate()

   ENDWITH

RETURN
