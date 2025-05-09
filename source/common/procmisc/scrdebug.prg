//
// Common procedures
// Scripts Debugger
//
// Author: Alexander S.Kresin <alex@belacy.belgorod.su>
//         www - http://kresin.belgorod.su
//

#include "hwguipp.ch"

STATIC s_oDlgDebug := NIL
STATIC s_oBrwData, s_oBrwScript, s_oSplit, s_oPanel, s_oEditExpr, s_oEditRes
STATIC s_nDebugMode := 0
STATIC s_i_scr := 0
STATIC s_oDlgFont, s_oScrFont, s_oBmpCurr, s_oBmpPoint
STATIC s_nAnimaTime
STATIC s_aBreakPoints
STATIC s_aBreaks := {}
STATIC s_aWatches := {}
STATIC s_aScriptCurr
STATIC s_nScriptSch := 0

FUNCTION hwg_scrDebug(aScript, iscr)

   LOCAL nFirst, i

   IF Len(aScript) < 3
      Return .F.
   ELSEIF Len(aScript) == 3
      Aadd(aScript, NIL)
   ENDIF
   IF Empty(aScript[4])
      s_nScriptSch ++
      aScript[4] := s_nScriptSch
   ENDIF
   IF s_aScriptCurr == NIL
      s_aScriptCurr := aScript
   ENDIF

   IF s_oDlgDebug == NIL .AND. iscr > 0

      s_oDlgFont := HFont():Add("Georgia", 0, -15, , 204)
      s_oScrFont := HFont():Add("Courier New", 0, -15, , 204)
#ifndef __GTK__
      s_oBmpCurr := HBitmap():AddStandard(OBM_RGARROWD)
      s_oBmpPoint:= HBitmap():AddStandard(OBM_CHECK)
#endif
      INIT DIALOG s_oDlgDebug TITLE ("Script Debugger - " + aScript[1]) AT 210, 10 SIZE 500, 300 ;
           FONT s_oDlgFont STYLE WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX ;
           ON EXIT {||dlgDebugClose()}

      MENU OF s_oDlgDebug
         MENUITEM "E&xit" ACTION s_oDlgDebug:Close()
         MENUITEM "&Step" ACTION (s_nDebugMode:=0,SetDebugRun())
         MENU TITLE "&Animate"
            MENUITEM "&0.5 seconds" ACTION (s_nAnimaTime:=0.5,s_nDebugMode:=1,SetDebugRun())
            MENUITEM "&1 seconds" ACTION (s_nAnimaTime:=1,s_nDebugMode:=1,SetDebugRun())
            MENUITEM "&3 seconds" ACTION (s_nAnimaTime:=3,s_nDebugMode:=1,SetDebugRun())
         ENDMENU
         MENUITEM "&Run" ACTION (s_nDebugMode:=2,SetDebugRun())
      ENDMENU

      @ 0, 0 BROWSE s_oBrwData ARRAY SIZE 500, 0 STYLE WS_BORDER + WS_VSCROLL ;
          ON SIZE {|o, x|o:Move(, , x)}

      s_oBrwData:aArray := s_aWatches
      s_oBrwData:AddColumn(HColumn():New("", {|v, o|HB_SYMBOL_UNUSED(v), o:aArray[o:nCurrent, 1]}, "C", 30, 0))
      s_oBrwData:AddColumn(HColumn():New("", {|v, o|HB_SYMBOL_UNUSED(v), o:aArray[o:nCurrent, 3]}, "C",  1, 0))
      s_oBrwData:AddColumn(HColumn():New("", {|v, o|HB_SYMBOL_UNUSED(v), o:aArray[o:nCurrent, 4]}, "C", 60, 0))
      @ 0, 4 BROWSE s_oBrwScript ARRAY SIZE 500, 236    ;
          FONT s_oScrFont STYLE WS_BORDER+WS_VSCROLL+WS_HSCROLL ;
          ON SIZE {|o,x,y|o:Move(,,x,y-s_oSplit:nTop-s_oSplit:nHeight-64)}

      @ 0, 0 SPLITTER s_oSplit SIZE 600, 3 DIVIDE {s_oBrwData} FROM {s_oBrwScript} ;
          ON SIZE {|o, x|o:Move(, , x)}

      s_oBrwScript:aArray := aScript[3]
#ifdef __GTK__
      s_oBrwScript:rowCount := 5
      s_oBrwScript:AddColumn(HColumn():New("",{|v,o|HB_SYMBOL_UNUSED(v),IIf(o:nCurrent == s_i_scr,">",IIf(s_aBreakPoints != NIL.AND.Ascan(s_aBreakPoints[2],s_oBrwScript:nCurrent)!=0,"*"," "))},"C", 1, 0))
#else
      s_oBrwScript:AddColumn(HColumn():New("",{|v,o|HB_SYMBOL_UNUSED(v),IIf(o:nCurrent == s_i_scr, 1,IIf(s_aBreakPoints != NIL.AND.Ascan(s_aBreakPoints[2],s_oBrwScript:nCurrent)!=0, 2, 0))},"N", 1, 0))
      s_oBrwScript:aColumns[1]:aBitmaps := {{{|n|n == 1},s_oBmpCurr},{{|n|n == 2},s_oBmpPoint}}
#endif
      s_oBrwScript:AddColumn(HColumn():New("",{|v,o|HB_SYMBOL_UNUSED(v),Left(o:aArray[o:nCurrent], 4)},"C", 4, 0))
      s_oBrwScript:AddColumn(HColumn():New("",{|v,o|HB_SYMBOL_UNUSED(v),Substr(o:aArray[o:nCurrent], 6)},"C", 80, 0))

      s_oBrwScript:bEnter:= {||AddBreakPoint()}

      @ 0, 240 PANEL s_oPanel OF s_oDlgDebug SIZE s_oDlgDebug:nWidth, 64 ON SIZE {|o, x, y|o:Move(, y - 64, x)}

#ifdef __GTK__
      @ 10, 10 OWNERBUTTON TEXT "Add" SIZE 100, 24 OF s_oPanel ON CLICK {||AddWatch()}
      @ 10, 36 OWNERBUTTON TEXT "Calculate" SIZE 100, 24 OF s_oPanel ON CLICK {||Calculate()}
#else
      @ 10, 10 BUTTON "Add" SIZE 100, 24 OF s_oPanel ON CLICK {||AddWatch()}
      @ 10, 36 BUTTON "Calculate" SIZE 100, 24 OF s_oPanel ON CLICK {||Calculate()}
#endif
      @ 110, 10 EDITBOX s_oEditExpr CAPTION "" SIZE 380, 24 OF s_oPanel ON SIZE {|o,x|o:Move(,,x-120)}
      @ 110, 36 EDITBOX s_oEditRes CAPTION "" SIZE 380, 24 OF s_oPanel ON SIZE {|o,x|o:Move(,,x-120)}

      ACTIVATE DIALOG s_oDlgDebug NOMODAL

      s_oDlgDebug:Move(,,, 400)
   ENDIF

   IF s_aScriptCurr[4] != aScript[4]
      IF !Empty(s_aBreakPoints)
         IF Ascan(s_aBreaks, {|a|a[1] == s_aBreakPoints[1]}) == 0
            Aadd(s_aBreaks, s_aBreakPoints)
         ENDIF
         IF (i := Ascan(s_aBreaks, {|a|a[1] == aScript[4]})) == 0
            s_aBreakPoints := NIL
         ELSE
            s_aBreakPoints := s_aBreaks[i]
         ENDIF
      ENDIF
      s_aScriptCurr := aScript
      hwg_Setwindowtext(s_oDlgDebug:handle, "Script Debugger - " + aScript[1])
   ENDIF

   s_oBrwScript:aArray := aScript[3]
   IF (s_i_scr := iscr) == 0
      s_nDebugMode := 0
      s_oBrwScript:Top()
   ELSE
      IF s_aBreakPoints != NIL .AND. Ascan(s_aBreakPoints[2],s_i_scr) != 0
         s_nDebugMode := 0
      ENDIF
      IF s_nDebugMode < 2
         FOR i := 1 TO Len(s_aWatches)
            CalcWatch(i)
         NEXT
         IF !Empty(s_aWatches)
            s_oBrwData:Refresh()
         ENDIF
         nFirst := s_oBrwScript:nCurrent - s_oBrwScript:rowPos + 1
         s_oBrwScript:nCurrent := s_i_scr
         IF s_i_scr - nFirst >= s_oBrwScript:rowCount
            s_oBrwScript:rowPos := 1
         ELSE
            s_oBrwScript:rowPos := s_oBrwScript:nCurrent - nFirst + 1
         ENDIF
         s_oBrwScript:Refresh()
         IF s_nDebugMode == 1
            nFirst := Seconds()
            DO WHILE Seconds() - nFirst < s_nAnimaTime
               hwg_ProcessMessage()
            ENDDO
            SetDebugRun()
         ENDIF
      ELSEIF s_nDebugMode == 2
         SetDebugRun()
      ENDIF
   ENDIF

Return .T.

STATIC FUNCTION dlgDebugClose()

   s_oDlgDebug := NIL
   SetDebugger(.F.)
   SetDebugRun()
   s_aBreakPoints := s_aScriptCurr := NIL
   s_aBreaks := {}
   s_aWatches := {}
   s_oScrFont:Release()
   s_oDlgFont:Release()
#ifndef __GTK__
   s_oBmpCurr:Release()
   s_oBmpPoint:Release()
#endif

Return .T.

Static Function AddBreakPoint
Local i

   IF s_aBreakPoints == NIL
      s_aBreakPoints := {s_aScriptCurr[4], {}}
   ENDIF
   IF (i := Ascan(s_aBreakPoints[2],s_oBrwScript:nCurrent)) == 0
      FOR i := 1 TO Len(s_aBreakPoints[2])
         IF s_aBreakPoints[2,i] == 0
            s_aBreakPoints[2,i] := s_oBrwScript:nCurrent
            EXIT
         ENDIF
      NEXT
      IF i > Len(s_aBreakPoints[2])
         Aadd(s_aBreakPoints[2], s_oBrwScript:nCurrent)
      ENDIF
   ELSE
      Adel(s_aBreakPoints[2], i)
      s_aBreakPoints[2,Len(s_aBreakPoints[2])] := 0
   ENDIF
   s_oBrwScript:Refresh()
Return .T.

Static Function AddWatch()
Local xRes, bCodeblock, bOldError, lRes := .T.

#ifdef __GTK__
   IF !Empty(xRes := s_oEditExpr:GetText())
#else
   IF !Empty(xRes := hwg_Getedittext(s_oEditExpr:oParent:handle, s_oEditExpr:id))
#endif
      bOldError := ERRORBLOCK({|e|MacroError(e)})
      BEGIN SEQUENCE
         bCodeblock := &("{||" + xRes + "}")
      RECOVER
         lRes := .F.
      END SEQUENCE
      ERRORBLOCK(bOldError)
   ENDIF

   IF lRes
      IF Ascan(s_aWatches, {|s|s[1] == xRes}) == 0
         Aadd(s_aWatches, {xRes, bCodeblock, NIL, NIL})
         CalcWatch(Len(s_aWatches))
      ENDIF
      IF s_oBrwData:nHeight < 20
         s_oSplit:Move(, 56)
         s_oBrwScript:Move(, 60,,s_oDlgDebug:nHeight-s_oSplit:nTop-s_oSplit:nHeight-64)
         s_oBrwData:Move(,,, 56)
         s_oDlgDebug:Move(,,,s_oDlgDebug:nHeight+4)
      ENDIF
      s_oBrwData:Refresh()
   ELSE
      s_oEditRes:SetText("Error...")
   ENDIF
Return .T.

Static Function CalcWatch(n)
Local xRes, bOldError, lRes := .T., cType

   bOldError := ERRORBLOCK({|e|MacroError(e)})
   BEGIN SEQUENCE
      xRes := Eval(s_aWatches[n, 2])
   RECOVER
      lRes := .F.
   END SEQUENCE
   ERRORBLOCK(bOldError)

   IF lRes
      IF (cType := Valtype(xRes)) == "N"
         s_aWatches[n, 4] := Ltrim(Str(xRes))
      ELSEIF cType == "D"
         s_aWatches[n, 4] := Dtoc(xRes)
      ELSEIF cType == "L"
         s_aWatches[n, 4] := IIf(xRes,".T.",".F.")
      ELSEIF cType == "C"
         s_aWatches[n, 4] := xRes
      ELSE
         s_aWatches[n, 4] := "Undefined"
      ENDIF
      s_aWatches[n, 3] := cType
   ELSE
      s_aWatches[n, 4] := "Error..."
      s_aWatches[n, 3] := "U"
   ENDIF

Return .T.

Static Function Calculate()
Local xRes, bOldError, lRes := .T., cType

#ifdef __GTK__
   IF !Empty(xRes := s_oEditExpr:GetText())
#else
   IF !Empty(xRes := hwg_Getedittext(s_oEditExpr:oParent:handle, s_oEditExpr:id))
#endif
      bOldError := ERRORBLOCK({|e|MacroError(e)})
      BEGIN SEQUENCE
         xRes := &xRes
      RECOVER
         lRes := .F.
      END SEQUENCE
      ERRORBLOCK(bOldError)
   ENDIF

   IF lRes
      IF (cType := Valtype(xRes)) == "N"
         s_oEditRes:SetText(Ltrim(Str(xRes)))
      ELSEIF cType == "D"
         s_oEditRes:SetText(Dtoc(xRes))
      ELSEIF cType == "L"
         s_oEditRes:SetText(IIf(xRes,".T.",".F."))
      ELSE
         s_oEditRes:SetText(xRes)
      ENDIF
   ELSE
      s_oEditRes:SetText("Error...")
   ENDIF

Return .T.

STATIC FUNCTION MacroError(/* e */)

   IF .T.      // compile -w3 -es2
      BREAK
   ENDIF

RETURN .T.

Function scrBreakPoint()

   s_nDebugMode := 0

Return .T.
