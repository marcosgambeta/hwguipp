//
// Common procedures
// Scripts
//
// Author: Alexander S.Kresin <alex@belacy.belgorod.su>
//         www - http://kresin.belgorod.su
//

#include <fileio.ch>

// #define __WINDOWS__

#ifndef __PLATFORM__WINDOWS
   #define DEF_SEP      "/"
   #define DEF_CH_SEP   "\"
#else
   #define DEF_SEP      "\"
   #define DEF_CH_SEP   "/"
#endif

Memvar iscr

STATIC s_nLastError, s_numlin
STATIC s_lDebugInfo := .F.
STATIC s_lDebugger := .F.
STATIC s_lDebugRun := .F.

#ifndef __PLATFORM__WINDOWS      // __WINDOWS__
STATIC s_y__size := 0, s_x__size := 0
#endif
#define STR_BUFLEN  1024

REQUEST __PP_STDRULES
REQUEST OS
REQUEST HB_COMPILER
REQUEST HB_VERSION

FUNCTION OpenScript(fname, scrkod)

LOCAL han, stroka, scom, aScr, rejim := 0, i
LOCAL strbuf := Space(STR_BUFLEN), poz := STR_BUFLEN+1
LOCAL aFormCode, aFormName

   scrkod := IIf(scrkod == NIL, "000", Upper(scrkod))
   IF DEF_CH_SEP $ fname
      fname := StrTran(fname, DEF_CH_SEP, DEF_SEP)
   ENDIF
   han := FOPEN(fname, FO_READ + FO_SHARED)
   IF han != - 1
      DO WHILE .T.
         stroka := RDSTR(han, @strbuf, @poz, STR_BUFLEN)
         IF LEN(stroka) == 0
            EXIT
         ELSEIF rejim == 0 .AND. Left(stroka, 1) == "#"
            IF Upper(Left(stroka, 7)) == "#SCRIPT"
               scom := Upper(Ltrim(Substr(stroka, 9)))
               IF scom == scrkod
                  aScr := RdScript(han, @strbuf, @poz,,fname+","+scrkod)
                  EXIT
               ENDIF
            ELSEIF Left(stroka, 6) == "#BLOCK"
               scom := Upper(Ltrim(Substr(stroka, 8)))
               IF scom == scrkod
                  rejim := - 1
                  aFormCode := {}
                  aFormName := {}
               ENDIF
            ENDIF
         ELSEIF rejim == -1 .AND. Left(stroka, 1) == "@"
            i := AT(" ", stroka)
            Aadd(aFormCode, SUBSTR(stroka, 2, i - 2))
            Aadd(aFormName, SUBSTR(stroka, i + 1))
         ELSEIF rejim == -1 .AND. Left(stroka, 9) == "#ENDBLOCK"
#ifdef __PLATFORM__WINDOWS  // __WINDOWS__
            i := hwg_WChoice(aFormName)
#else
            i := FCHOICE(aFormName)
#endif
            IF i == 0
               FCLOSE(han)
               RETURN NIL
            ENDIF
            rejim := 0
            scrkod := aFormCode[i]
         ENDIF
      ENDDO
      FCLOSE(han)
   ELSE
#ifdef __PLATFORM__WINDOWS   // __WINDOWS__
      hwg_MsgStop(fname + " can't be opened ")
#else
      ALERT(fname + " can't be opened ")
#endif
      RETURN NIL
   ENDIF
RETURN aScr

FUNCTION RdScript(scrSource, strbuf, poz, lppNoInit, cTitle)

LOCAL han
LOCAL rezArray := IIf(s_lDebugInfo, { "", {}, {} }, { "", {} })

   IF lppNoInit == NIL
      lppNoInit := .F.
   ENDIF
   IF poz == NIL
      poz := 1
   ENDIF
   IF cTitle != NIL
      rezArray[1] := cTitle
   ENDIF
   s_nLastError := 0
   IF scrSource == NIL
      han := NIL
      poz := 1
   ELSEIF HB_ISCHAR(scrSource)
      strbuf := Space(STR_BUFLEN)
      poz := STR_BUFLEN + 1
      IF DEF_CH_SEP $ scrSource
         scrSource := StrTran(scrSource, DEF_CH_SEP, DEF_SEP)
      ENDIF
      han := Fopen(scrSource, FO_READ + FO_SHARED)
   ELSE
      han := scrSource
   ENDIF
   IF han == NIL .OR. han != - 1
      IF !lppNoInit
         ppScript(,.T.)
      ENDIF
      IF HB_ISCHAR(scrSource)
         WndOut("Compiling ...")
         WndOut("")
      ENDIF
      s_numlin := 0
      IF !CompileScr(han, @strbuf, @poz, rezArray, scrSource)
         rezArray := NIL
      ENDIF
      IF scrSource != NIL .AND. HB_ISCHAR(scrSource)
         WndOut()
         Fclose(han)
      ENDIF
      IF !lppNoInit
         ppScript(,.F.)
      ENDIF
   ELSE
#ifdef __PLATFORM__WINDOWS  // __WINDOWS__
      hwg_MsgStop("Can't open " + scrSource)
#else
      WndOut("Can't open " + scrSource)
      WAIT ""
      WndOut()
#endif
      s_nLastError := - 1
      RETURN NIL
   ENDIF
RETURN rezArray

FUNCTION ppScript(stroka, lNew)
STATIC s_pp

   IF lNew != NIL
      s_pp := IIf(lNew, __pp_init(), NIL)
      RETURN NIL
   ENDIF
RETURN __pp_process(s_pp, stroka)

FUNCTION scr_GetFuncsList(strbuf)
   LOCAL arr := {}, poz := 1, cLine, poz1, scom

   DO WHILE .T.
      cLine := RDSTR(, @strbuf, @poz, STR_BUFLEN)
      IF Len(cLine) == 0
         EXIT
      ENDIF
      cLine := AllTrim(cLine)
      IF (poz1 := AT(" ", cLine)) > 0
         scom := Upper(Left(cLine, poz1 - 1))
         IF scom == "FUNCTION"
            cLine := Ltrim(Substr(cLine, poz1 + 1))
            poz1 := At("(", cLine)
            AAdd(arr, Upper(Left(cLine, IIf(poz1 != 0, poz1 - 1, 999))))
         ENDIF
      ENDIF
   ENDDO

   RETURN arr

STATIC FUNCTION COMPILESCR(han, strbuf, poz, rezArray, scrSource)

LOCAL scom, poz1, stroka, strfull := "", bOldError, i, tmpArray := {}
Local cLine, lDebug := (Len(rezArray) >= 3)

   DO WHILE .T.
      cLine := RDSTR(han, @strbuf, @poz, STR_BUFLEN)
      IF LEN(cLine) == 0
         EXIT
      ENDIF
      s_numlin ++
      IF Right(cLine, 1) == ";"
         strfull += Left(cLine, Len(cLine) - 1)
         LOOP
      ELSE
         IF !Empty(strfull)
            cLine := strfull + cLine
         ENDIF
         strfull := ""
      ENDIF
      stroka := AllTrim(cLine)
      IF RIGHT(stroka, 1) == CHR(26)
         stroka := Left(stroka, LEN(stroka) - 1)
      ENDIF
      IF !Empty(stroka) .AND. Left(stroka, 2) != "//"

         IF Left(stroka, 1) == "#"
            IF UPPER(Left(stroka, 7)) == "#ENDSCR"
               Return .T.
            ELSEIF UPPER(Left(stroka, 6)) == "#DEBUG"
               IF !lDebug .AND. Len(rezArray[2]) == 0
                  lDebug := .T.
                  Aadd(rezArray, {})
                  IF SUBSTR(stroka, 7, 3) == "GER"
                     AADD(rezArray[2], stroka)
                     AADD(tmpArray, "")
                     Aadd(rezArray[3], Str(s_numlin, 4) + ":" + cLine)
                  ENDIF
               ENDIF
               LOOP
#ifdef __HARBOUR__
            ELSE
               ppScript(stroka)
               LOOP
#endif
            ENDIF
#ifdef __HARBOUR__
         ELSE
            stroka := ppScript(stroka)
#endif
         ENDIF

         poz1 := AT(" ", stroka)
         scom := UPPER(SUBSTR(stroka, 1, IIf(poz1 != 0, poz1 - 1, 999)))
         DO CASE
         CASE scom == "PRIVATE" .OR. scom == "PARAMETERS" .OR. scom == "LOCAL"
            IF LEN(rezArray[2]) == 0 .OR. (i := VALTYPE(ATAIL(rezArray[2]))) == "C" ;
                    .OR. i == "A"
               IF Left(scom, 2) == "LO"
                  AADD(rezArray[2], " " + ALLTRIM(SUBSTR(stroka, 7)))
               ELSEIF Left(scom, 2) == "PR"
                  AADD(rezArray[2], " " + ALLTRIM(SUBSTR(stroka, 9)))
               ELSE
                  AADD(rezArray[2], "/" + ALLTRIM(SUBSTR(stroka, 12)))
               ENDIF
               AADD(tmpArray, "")
            ELSE
               s_nLastError := 1
               RETURN .F.
            ENDIF
         CASE (scom == "DO" .AND. UPPER(SUBSTR(stroka, 4, 5)) == "WHILE") ;
                .OR. scom == "WHILE"
            AADD(tmpArray, stroka)
            AADD(rezArray[2], .F.)
         CASE scom == "ENDDO"
            IF !Fou_Do(rezArray[2], tmpArray)
               s_nLastError := 2
               RETURN .F.
            ENDIF
         CASE scom == "EXIT"
            AADD(tmpArray, "EXIT")
            AADD(rezArray[2], .F.)
         CASE scom == "LOOP"
            AADD(tmpArray, "LOOP")
            AADD(rezArray[2], .F.)
         CASE scom == "IF"
            AADD(tmpArray, stroka)
            AADD(rezArray[2], .F.)
         CASE scom == "ELSEIF"
            IF !Fou_If(rezArray, tmpArray, .T.)
               s_nLastError := 3
               RETURN .F.
            ENDIF
            AADD(tmpArray, SUBSTR(stroka, 5))
            AADD(rezArray[2], .F.)
         CASE scom == "ELSE"
            IF !Fou_If(rezArray, tmpArray, .T.)
               s_nLastError := 1
               RETURN .F.
            ENDIF
            AADD(tmpArray, "IF .T.")
            AADD(rezArray[2], .F.)
         CASE scom == "ENDIF"
            IF !Fou_If(rezArray, tmpArray, .F.)
               s_nLastError := 1
               RETURN .F.
            ENDIF
         CASE scom == "RETURN"
            bOldError := ERRORBLOCK({|e|MacroError(1, e, stroka)})
            BEGIN SEQUENCE
               AADD(rezArray[2], &("{||EndScript(" + Ltrim(Substr(stroka, 7)) + ")}"))
            RECOVER
               IF scrSource != NIL .AND. HB_ISCHAR(scrSource)
                  WndOut()
                  FCLOSE(han)
               ENDIF
               ERRORBLOCK(bOldError)
               RETURN .F.
            END SEQUENCE
            ERRORBLOCK(bOldError)
            AADD(tmpArray, "")
         CASE scom == "FUNCTION"
            stroka := Ltrim(Substr(stroka, poz1 + 1))
            poz1 := At("(", stroka)
            scom := UPPER(Left(stroka, IIf(poz1 != 0, poz1 - 1, 999)))
            AADD(rezArray[2], IIf(lDebug, {scom, {}, {}}, {scom, {}}))
            AADD(tmpArray, "")
            IF !CompileScr(han, @strbuf, @poz, rezArray[2,Len(rezArray[2])])
               RETURN .F.
            ENDIF
         CASE scom == "#ENDSCRIPT" .OR. Left(scom, 7) == "ENDFUNC"
            RETURN .T.
         OTHERWISE
            bOldError := ERRORBLOCK({|e|MacroError(1, e, stroka)})
            BEGIN SEQUENCE
               AADD(rezArray[2], &("{||" + ALLTRIM(stroka) + "}"))
            RECOVER
               IF scrSource != NIL .AND. HB_ISCHAR(scrSource)
                  WndOut()
                  FCLOSE(han)
               ENDIF
               ERRORBLOCK(bOldError)
               RETURN .F.
            END SEQUENCE
            ERRORBLOCK(bOldError)
            AADD(tmpArray, "")
         ENDCASE
         IF lDebug .AND. Len(rezArray[3]) < Len(rezArray[2])
            Aadd(rezArray[3], Str(s_numlin, 4) + ":" + cLine)
         ENDIF
      ENDIF
   ENDDO
RETURN .T.


STATIC FUNCTION MacroError(nm, e, stroka)

Local n

#ifdef __PLATFORM__WINDOWS  // __WINDOWS__

   LOCAL cTitle
   IF nm == 1
      stroka := hwg_ErrMsg(e) + Chr(10)+Chr(13) + "in" + Chr(10)+Chr(13) + ;
                      AllTrim(stroka)
      cTitle := "Script compiling error"
   ELSEIF nm == 2
      stroka := hwg_ErrMsg(e)
      cTitle := "Script variables error"
   ELSEIF nm == 3
      n := 2
      WHILE !Empty(ProcName(n))
        stroka += Chr(13)+Chr(10) + "Called from " + ProcName(n) + "(" + AllTrim(Str(ProcLine(n++))) + ")"
      ENDDO
      stroka := hwg_ErrMsg(e)+ Chr(10)+Chr(13) + stroka
      cTitle := "Script execution error"
   ENDIF
   stroka += Chr(13)+Chr(10) + Chr(13)+Chr(10) + "Continue ?"
   IF !hwg_MsgYesNo(stroka, cTitle)
      hwg_EndWindow()
      QUIT
   ENDIF
#else
   IF nm == 1
      ALERT("Error in;" + AllTrim(stroka))
   ELSEIF nm == 2
      Alert("Script variables error")
   ELSEIF nm == 3
      stroka += ";" + hwg_ErrMsg(e)
      n := 2
      WHILE !Empty(ProcName(n))
        stroka += ";Called from " + ProcName(n) + "(" + AllTrim(Str(ProcLine(n++))) + ")"
      ENDDO
      Alert("Script execution error:;"+stroka)
   ENDIF
#endif
//   BREAK
   // Warning W0028  Unreachable code
RETURN .T.

STATIC FUNCTION Fou_If(rezArray, tmpArray, prju)

LOCAL i, j, bOldError

   IF prju
      AADD(tmpArray, "JUMP")
      AADD(rezArray[2], .F.)
      IF Len(rezArray) >= 3
         Aadd(rezArray[3], Str(s_numlin, 4) + ":JUMP")
      ENDIF
   ENDIF
   j := LEN(rezArray[2])
   FOR i := j TO 1 STEP - 1
      IF UPPER(Left(tmpArray[i], 2)) == "IF"
         bOldError := ERRORBLOCK({|e|MacroError(1, e, tmpArray[i])})
         BEGIN SEQUENCE
            rezArray[2, i] := &("{||IIf(" + ALLTRIM(SUBSTR(tmpArray[i], 4)) + ;
                 ",.T.,iscr:=" + LTRIM(STR(j, 5)) + ")}")
         RECOVER
            ERRORBLOCK(bOldError)
            RETURN .F.
         END SEQUENCE
         ERRORBLOCK(bOldError)
         tmpArray[i] := ""
         i --
         IF i > 0 .AND. tmpArray[i] == "JUMP"
            rezArray[2, i] := &("{||iscr:=" + LTRIM(STR(IIf(prju, j - 1, j), 5)) + "}")
            tmpArray[i] := ""
         ENDIF
         RETURN .T.
      ENDIF
   NEXT
RETURN .F.

STATIC FUNCTION Fou_Do(rezArray, tmpArray)

LOCAL i, j, iloop := 0, bOldError

* Variables not used
* iPos

   j := LEN(rezArray)
   FOR i := j TO 1 STEP - 1
      IF !Empty(tmpArray[i]) .AND. Left(tmpArray[i], 4) == "EXIT"
         rezArray[i] = &("{||iscr:=" + LTRIM(STR(j + 1, 5)) + "}")
         tmpArray[i] := ""
      ENDIF
      IF !Empty(tmpArray[i]) .AND. Left(tmpArray[i], 4) == "LOOP"
         iloop := i
      ENDIF
      IF !Empty(tmpArray[i]) .AND. (UPPER(Left(tmpArray[i], 8)) = "DO WHILE" .OR. UPPER(Left(tmpArray[i], 5)) = "WHILE")
         bOldError := ERRORBLOCK({|e|MacroError(1, e, tmpArray[i])})
         BEGIN SEQUENCE
            rezArray[i] = &("{||IIf(" + ALLTRIM(SUBSTR(tmpArray[i], ;
                 IIf(UPPER(Left(tmpArray[i], 1)) == "D", 10, 7))) + ;
                 ",.T.,iscr:=" + LTRIM(STR(j + 1, 5)) + ")}")
         RECOVER
            ERRORBLOCK(bOldError)
            RETURN .F.
         END SEQUENCE
         ERRORBLOCK(bOldError)
         tmpArray[i] := ""
         AADD(rezArray, &("{||iscr:=" + LTRIM(STR(i - 1, 5)) + "}"))
         AADD(tmpArray, "")
         IF iloop > 0
            rezArray[iloop] = &("{||iscr:=" + LTRIM(STR(i - 1, 5)) + "}")
            tmpArray[iloop] := ""
         ENDIF
         RETURN .T.
      ENDIF
   NEXT
RETURN .F.

FUNCTION DoScript(aScript, aParams)

LOCAL arlen, stroka, varName, varValue, lDebug, lParam, j
 // Variables not used
#ifdef __PLATFORM__WINDOWS
LOCAL lSetDebugger := .F.
#endif
MEMVAR iscr, bOldError, aScriptt, doscr_RetValue
PRIVATE iscr := 1, bOldError, doscr_RetValue := NIL

   IF Type("aScriptt") != "A"
      PRIVATE aScriptt := aScript
   ENDIF
   IF aScript == NIL .OR. (arlen := Len(aScript[2])) == 0
      RETURN .T.
   ENDIF
   lDebug := (Len(aScript) >= 3)
   DO WHILE !hb_IsBlock(aScript[2, iscr])
      IF HB_ISCHAR(aScript[2, iscr])
         IF Left(aScript[2, iscr], 1) == "#"
            IF !s_lDebugger
               // lSetDebugger := .T.
               SetDebugger()
            ENDIF
         ELSE
            stroka := Substr(aScript[2, iscr], 2)
            lParam := (Left(aScript[2, iscr], 1) == "/")
            bOldError := Errorblock({|e|MacroError(2, e)})
            BEGIN SEQUENCE
               j := 1
               DO WHILE !Empty(varName := getNextVar(@stroka, @varValue))
                  PRIVATE &varName
                  IF varvalue != NIL
                     &varName := &varValue
                  ENDIF
                  IF lParam .AND. aParams != NIL .AND. Len(aParams) >= j
                     &varname := aParams[j]
                  ENDIF
                  j ++
               ENDDO
            RECOVER
               WndOut()
               Errorblock(bOldError)
               RETURN .F.
            END SEQUENCE
            Errorblock(bOldError)
         ENDIF
      ENDIF
      iscr ++
   ENDDO
   IF lDebug
      bOldError := Errorblock({|e|MacroError(3, e, aScript[3, iscr])})
   ELSE
      bOldError := Errorblock({|e|MacroError(3, e, LTrim(Str(iscr)))})
   ENDIF
   BEGIN SEQUENCE
      IF lDebug .AND. s_lDebugger
         DO WHILE iscr > 0 .AND. iscr <= arlen
#ifdef __PLATFORM__WINDOWS // __WINDOWS__
            IF s_lDebugger
               s_lDebugRun := .F.
               hwg_scrDebug(aScript, iscr)
               DO WHILE !s_lDebugRun
                  hwg_ProcessMessage()
               ENDDO
            ENDIF
#endif
            Eval(aScript[2, iscr])
            iscr ++
         ENDDO
#ifdef __PLATFORM__WINDOWS // __WINDOWS__
         hwg_scrDebug(aScript, 0)
         IF lSetDebugger
            SetDebugger(.F.)
         ENDIF
#endif
      ELSE
         DO WHILE iscr > 0 .AND. iscr <= arlen
            Eval(aScript[2, iscr])
            iscr ++
         ENDDO
      ENDIF
   RECOVER
      WndOut()
      Errorblock(bOldError)
#ifdef __PLATFORM__WINDOWS // __WINDOWS__
      IF lDebug .AND. s_lDebugger
         hwg_scrDebug(aScript, 0)
      ENDIF
#endif
      RETURN .F.
   END SEQUENCE
   Errorblock(bOldError)
   WndOut()

RETURN m->doscr_RetValue

FUNCTION CallFunc(cProc, aParams, aScript)

LOCAL i := 1, RetValue := NIL

   IF aScript == NIL
      aScript := m->aScriptt
   ENDIF
   cProc := Upper(cProc)
   DO WHILE i <= Len(aScript[2]) .AND. HB_ISARRAY(aScript[2, i])
      IF aScript[2, i, 1] == cProc
         RetValue := DoScript(aScript[2, i], aParams)
         EXIT
      ENDIF
      i ++
   ENDDO

RETURN RetValue

FUNCTION EndScript(xRetValue)

   m->doscr_RetValue := xRetValue
   iscr := - 99
RETURN NIL

FUNCTION CompileErr(nLine)

   nLine := s_numlin
RETURN s_nLastError

FUNCTION Codeblock(string)

   IF Left(string, 2) == "{|"
      Return &(string)
   ENDIF
RETURN &("{||"+string+"}")

FUNCTION SetDebugInfo(lDebug)

   s_lDebugInfo := IIf(lDebug == NIL, .T., lDebug)
RETURN .T.

FUNCTION SetDebugger(lDebug)

   s_lDebugger := IIf(lDebug == NIL, .T., lDebug)
RETURN .T.

FUNCTION SetDebugRun()

   s_lDebugRun := .T.
RETURN .T.

Function RunScript(fname, scrname, args)
Local scr := OpenScript(fname, scrname)
Return IIf(scr == NIL, NIL, DoScript(scr, args))

#ifdef __PLATFORM__WINDOWS  // __WINDOWS__

STATIC FUNCTION WndOut()

   RETURN NIL

#else

FUNCTION WndOut(sout, noscroll, prnew)

LOCAL y1, x1, y2, x2, oldc, ly__size := (s_y__size != 0)
STATIC w__buf
   IF sout == NIL .AND. !ly__size
      Return NIL
   ENDIF
   IF s_y__size == 0
      s_y__size := 5
      s_x__size := 30
      prnew := .T.
   ELSEIF prnew == NIL
      prnew := .F.
   ENDIF
   y1 := 13 - INT(s_y__size / 2)
   x1 := 41 - INT(s_x__size / 2)
   y2 := y1 + s_y__size
   x2 := x1 + s_x__size
   IF sout == NIL
      RESTSCREEN(y1, x1, y2, x2, w__buf)
      s_y__size := 0
   ELSE
      oldc := SETCOLOR("N/W")
      IF prnew
         w__buf := SAVESCREEN(y1, x1, y2, x2)
/*
 Invalid characters in BOX:

 0x22 = "
 0xda = 218
 0xc4 = 196
 0xbf = 191
 0xb3 = 179
 0xd9 = 217
 0xc4 = 196
 0xc0 = 192
 0xb3 = 179
 0x20 = 32
 0x22 = "
*/
         @ y1, x1, y2, x2 BOX ;
         CHR(218) + CHR(196) + CHR(191) + CHR(179) + CHR(217) + CHR(196) + CHR(192) + CHR(179) + CHR(32)
      ELSEIF noscroll == NIL
         SCROLL(y1 + 1, x1 + 1, y2 - 1, x2 - 1, 1)
      ENDIF
      @ y2 - 1, x1 + 2 SAY sout
      SETCOLOR(oldc)
   ENDIF
RETURN NIL

FUNCTION WndGet(sout, varget, spict)

LOCAL y1, x1, y2, x2, oldc
LOCAL GetList := {}
   WndOut(sout)
   y1 := 13 - INT(s_y__size / 2)
   x1 := 41 - INT(s_x__size / 2)
   y2 := y1 + s_y__size
   x2 := x1 + s_x__size
   oldc := SETCOLOR("N/W")
   IF LEN(sout) + IIf(spict = "@D", 8, LEN(spict)) > s_x__size - 3
      SCROLL(y1 + 1, x1 + 1, y2 - 1, x2 - 1, 1)
   ELSE
      x1 += LEN(sout) + 1
   ENDIF
   @ y2 - 1, x1 + 2 GET varget PICTURE spict
   READ
   SETCOLOR(oldc)
RETURN IIf(LASTKEY() == 27, NIL, varget)

FUNCTION WndOpen(ysize, xsize)

   s_y__size := ysize
   s_x__size := xsize
   WndOut("",, .T.)
RETURN NIL
#endif
