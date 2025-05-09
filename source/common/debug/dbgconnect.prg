//
// HWGUI - Harbour Win32 GUI library source code:
// The Debugger
//
// Copyright 2013 Alexander Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

// $BEGIN_LICENSE$
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version, with one exception:
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this software; see the file COPYING.  If not, write to
// the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
// Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
//
// As a special exception, the Harbour Project gives permission for
// additional uses of the text contained in its release of Harbour.
//
// The exception is that, if you link the Harbour libraries with other
// files to produce an executable, this does not by itself cause the
// resulting executable to be covered by the GNU General Public License.
// Your use of that executable is in no way restricted on account of
// linking the Harbour library code into it.
//
// This exception does not however invalidate any other reasons why
// the executable file might be covered by the GNU General Public License.
//
// This exception applies only to the code released by the Harbour
// Project under the name Harbour.  If you copy code from other
// Harbour Project or Free Software Foundation releases into a copy of
// Harbour, as the General Public License permits, the exception does
// not apply to the code that you add in this way.  To avoid misleading
// anyone as to the status of such modified files, you must delete
// this exception notice from them.
//
// If you write modifications of your own for Harbour, it is your choice
// whether to permit this exception to apply to your modifications.
// If you do not wish that, delete this exception notice.
// $END_LICENSE$

#include <fileio.ch>

#define DEBUG_PROTO_VERSION     3

#define CMD_GO                  1
#define CMD_STEP                2
#define CMD_TRACE               3
#define CMD_NEXTR               4
#define CMD_TOCURS              5
#define CMD_QUIT                6
#define CMD_EXIT                7
#define CMD_BADD                8
#define CMD_BDEL                9
#define CMD_CALC               10
#define CMD_STACK              11
#define CMD_LOCAL              12
#define CMD_PRIVATE            13
#define CMD_PUBLIC             14
#define CMD_STATIC             15
#define CMD_WATCH              16
#define CMD_WADD               17
#define CMD_WDEL               18
#define CMD_AREAS              19
#define CMD_REC                20
#define CMD_OBJECT             21
#define CMD_ARRAY              22

STATIC s_lDebugRun := .F.
STATIC s_handl1
STATIC s_handl2
STATIC s_cBuffer
STATIC s_nId1 := -1
STATIC s_nId2 := 0

FUNCTION hwg_dbg_New()

   LOCAL i
   LOCAL nPos
   LOCAL arr
   LOCAL cCmd
   LOCAL cDir
   LOCAL cFile := hb_Progname()
   LOCAL cDebugger := "hwgdebug"
   LOCAL cExe
   LOCAL lRun
   LOCAL hProcess

   s_cBuffer := Space(1024)

   IF File(cDebugger+".info") .AND. (s_handl1 := FOpen(cDebugger + ".info", FO_READ)) != -1
      i := FRead(s_handl1, @s_cBuffer, Len(s_cBuffer))
      IF i > 0
         arr := hb_aTokens(Left(s_cBuffer, i), ;
               IIf(hb_At(Chr(13), s_cBuffer, 1, i) > 0, Chr(13)+Chr(10), Chr(10)))
         FOR i := 1 TO Len(arr)
            IF (nPos := At("=", arr[i])) > 0
               cCmd := Lower(Trim(Left(arr[i], nPos - 1)))
               IF cCmd == "dir"
                  cDir := Ltrim(Substr(arr[i], nPos + 1))
               ELSEIF cCmd == "debugger"
                  cExe := Ltrim(Substr(arr[i], nPos + 1))
               ELSEIF cCmd == "runatstart"
                  __Dbg():lRunAtStartup := (Lower(Alltrim(Substr(arr[i], nPos + 1))) == "on")
               ENDIF
            ENDIF
         NEXT
      ENDIF
      FClose(s_handl1)
   ENDIF

   IF File(cFile + ".d1") .AND. File(cFile + ".d2")

      IF (s_handl1 := FOpen(cFile + ".d1", FO_READ + FO_SHARED)) != -1
         i := FRead(s_handl1, @s_cBuffer, Len(s_cBuffer))
         IF (i > 0) .AND. ;
               Left(s_cBuffer, 4) == "init"
            s_handl2 := FOpen(cFile + ".d2", FO_READWRITE + FO_SHARED)
            IF s_handl2 != -1
               s_lDebugRun := .T.
               RETURN NIL
            ENDIF
         ENDIF
         FClose(s_handl1)
      ENDIF

   ENDIF

   IF !Empty(cDir)
      cDir += IIf(Right(cDir, 1) $ "\/", "", hb_PS())
      IF File(cDir + cDebugger + ".d1") .AND. File(cDir + cDebugger + ".d2")
         IF (s_handl1 := FOpen(cDir + cDebugger + ".d1", FO_READ + FO_SHARED)) != -1
            i := FRead(s_handl1, @s_cBuffer, Len(s_cBuffer))
            IF (i  > 0) .AND. ;
                  Left(s_cBuffer, 4) == "init"
               s_handl2 := FOpen(cDir + cDebugger + ".d2", FO_READWRITE + FO_SHARED)
               IF s_handl2 != -1
                  s_lDebugRun := .T.
                  RETURN NIL
               ENDIF
            ENDIF
            FClose(s_handl1)
         ENDIF
      ENDIF
   ENDIF

   cFile := IIf(!Empty(cDir), cDir, hb_dirTemp()) + ;
         IIf((i := Rat("\", cFile)) == 0, ;
         IIf((i := Rat("/", cFile)) == 0, cFile, Substr(cFile, i + 1)), ;
         Substr(cFile, i + 1))

   Ferase(cFile + ".d1")
   Ferase(cFile + ".d2")

   s_handl1 := FCreate(cFile + ".d1")
   FClose(s_handl1)
   s_handl2 := FCreate(cFile + ".d2")
   FClose(s_handl2)

#ifndef __PLATFORM__WINDOWS
   IF Empty(cExe)
      cExe := IIf(File(cDebugger), "./", "") + cDebugger
   ENDIF
   // lRun := __dbgProcessRun(cExe, "-c" + cFile)
   hProcess := hb_processOpen(cExe + " -c" + cFile)
   lRun := (hProcess != -1 .AND. hb_processValue(hProcess, .F.) == -1)
#else
   IF Empty(cExe)
      cExe := cDebugger
   ENDIF
   hProcess := hb_processOpen(cExe + ' -c"' + cFile + '"')
   lRun := (hProcess > 0)
#endif
   IF !lRun
      hwg_dbg_Alert(cExe + " isn't available...")
   ELSE
      s_handl1 := FOpen(cFile + ".d1", FO_READ + FO_SHARED)
      s_handl2 := FOpen(cFile + ".d2", FO_READWRITE + FO_SHARED)
      IF s_handl1 != -1 .AND. s_handl2 != -1
         s_lDebugRun := .T.
      ELSE
         hwg_dbg_Alert("Can't open connection...")
      ENDIF
   ENDIF

RETURN NIL

STATIC FUNCTION hwg_dbg_Read()

   LOCAL n
   LOCAL s := ""
   LOCAL arr

   FSeek(s_handl1, 0, 0)
   DO WHILE (n := Fread(s_handl1, @s_cBuffer, Len(s_cBuffer))) > 0
      s += Left(s_cBuffer, n)
      IF (n := At(",!", s)) > 0
         IF (arr := hb_aTokens(Left(s, n + 1), ",")) != NIL .AND. Len(arr) > 2 .AND. arr[1] == arr[Len(arr)-1]
            RETURN arr
         ELSE
            EXIT
         ENDIF
      ENDIF
   ENDDO

RETURN NIL

STATIC FUNCTION hwg_dbg_Send(...)

   LOCAL arr := hb_aParams()
   LOCAL i
   LOCAL s := ""

   FSeek(s_handl2, 0, 0)
   FOR i := 2 TO Len(arr)
      s += arr[i] + ","
   NEXT
   IF Len(s) > 800
      FWrite(s_handl2, "!," + Space(Len(arr[1]) - 1) + s + arr[1] + ",!")
      FSeek(s_handl2, 0, 0)
      FWrite(s_handl2, arr[1] + ",")
   ELSE
      FWrite(s_handl2, arr[1] + "," + s + arr[1] + ",!")
   ENDIF

RETURN NIL

FUNCTION hwg_dbg_SetActiveLine(cPrgName, nLine, aStack, aVars, aWatch, nVarType)

   LOCAL i
   LOCAL s := cPrgName + "," + Ltrim(Str(nLine))
   LOCAL nLen

   IF !s_lDebugRun
      RETURN NIL
   ENDIF

   IF s_nId2 == 0
      s += ",ver," + Ltrim(Str(DEBUG_PROTO_VERSION))
   ENDIF
   IF aStack != NIL
      s += ",stack"
      nLen := Len(aStack)
      FOR i := 1 TO nLen
         s += "," + aStack[i]
      NEXT
   ENDIF
   IF aVars != NIL
      s += IIf(nVarType == 1, ",valuelocal,", ;
            IIf(nVarType == 2, ",valuepriv,", IIf(nVarType == 3, ",valuepubl,", ",valuestatic,"))) + aVars[1]
      nLen := Len(aVars)
      FOR i := 2 TO nLen
         s += "," + Str2Hex(aVars[i])
      NEXT
   ENDIF
   IF aWatch != NIL
      s += ",valuewatch," + aWatch[1]
      nLen := Len(aWatch)
      FOR i := 2 TO nLen
         s += "," + Str2Hex(aWatch[i])
      NEXT
   ENDIF

   hwg_dbg_Send("a"+Ltrim(Str(++s_nId2)), s)

RETURN NIL

FUNCTION hwg_dbg_Wait(nWait)

   HB_SYMBOL_UNUSED(nWait)

   IF !s_lDebugRun
      RETURN NIL
   ENDIF

RETURN NIL

FUNCTION hwg_dbg_Input(p1, p2, p3)

   LOCAL n
   LOCAL cmd
   LOCAL arr

   IF !s_lDebugRun
      RETURN CMD_GO
   ENDIF

   DO WHILE .T.

      IF !Empty(arr := hwg_dbg_Read())
         IF (n := Val(arr[1])) > s_nId1 .AND. arr[Len(arr)] == "!"
            s_nId1 := n
            SWITCH arr[2]
            CASE "cmd"
               cmd := arr[3]
               SWITCH cmd
               CASE "go"
                  RETURN CMD_GO
               CASE "step"
                  RETURN CMD_STEP
               CASE "trace"
                  RETURN CMD_TRACE
               CASE "nextr"
                  RETURN CMD_NEXTR
               CASE "to"
                  p1 := arr[4]
                  p2 := Val(arr[5])
                  RETURN CMD_TOCURS
               CASE "quit"
                  RETURN CMD_QUIT
               CASE "exit"
                  s_lDebugRun := .F.
                  RETURN CMD_EXIT
               ENDSWITCH
               EXIT
            CASE "brp"
               SWITCH arr[3]
               CASE "add"
                  p1 := arr[4]
                  p2 := Val(arr[5])
                  RETURN CMD_BADD
               CASE "del"
                  p1 := arr[4]
                  p2 := Val(arr[5])
                  RETURN CMD_BDEL
               ENDSWITCH
               EXIT
            CASE "watch"
               SWITCH arr[3]
               CASE "add"
                  p1 := Hex2Str(arr[4])
                  RETURN CMD_WADD
               CASE "del"
                  p1 := Val(arr[4])
                  RETURN CMD_WDEL
               ENDSWITCH
               EXIT
            CASE "exp"
               p1 := Hex2Str(arr[3])
               RETURN CMD_CALC
            CASE "view"
               SWITCH arr[3]
               CASE "stack"
                  p1 := arr[4]
                  RETURN CMD_STACK
               CASE "local"
                  p1 := arr[4]
                  RETURN CMD_LOCAL
               CASE "priv"
                  p1 := arr[4]
                  RETURN CMD_PRIVATE
               CASE "publ"
                  p1 := arr[4]
                  RETURN CMD_PUBLIC
               CASE "static"
                  p1 := arr[4]
                  RETURN CMD_STATIC
               CASE "watch"
                  p1 := arr[4]
                  RETURN CMD_WATCH
               CASE "areas"
                  RETURN CMD_AREAS
               ENDSWITCH
               EXIT
            CASE "insp"
               SWITCH arr[3]
               CASE "rec"
                  p1 := arr[4]
                  RETURN CMD_REC
               CASE "obj"
                  p1 := arr[4]
                  RETURN CMD_OBJECT
               CASE "arr"
                  p1 := arr[4]
                  p2 := arr[5]
                  p3 := arr[6]
                  RETURN CMD_ARRAY
               ENDSWITCH
               EXIT
            ENDSWITCH
            hwg_dbg_Send("e"+Ltrim(Str(++s_nId2)))
         ENDIF
      ENDIF
      hb_ReleaseCpu()

   ENDDO

RETURN 0

FUNCTION hwg_dbg_Answer(...)

   LOCAL arr := hb_aParams()
   LOCAL i
   LOCAL j
   LOCAL s := ""
   LOCAL lConvert

   IF !s_lDebugRun
      RETURN NIL
   ENDIF

   FOR i := 1 TO Len(arr)
      IF HB_ISARRAY(arr[i])
         lConvert := (i > 1 .AND. HB_ISCHAR(arr[i-1]) .AND. Left(arr[i - 1], 5) == "value")
         FOR j := 1 TO Len(arr[i])
            s += IIf(j>1.AND.lConvert, Str2Hex(arr[i,j]), arr[i,j]) + ","
         NEXT
      ELSE
         IF arr[i] == "value" .AND. i < Len(arr)
            s += arr[i] + "," + Str2Hex(arr[++i]) + ","
         ELSE
            s += arr[i] + ","
         ENDIF
      ENDIF
   NEXT
   hwg_dbg_Send("b"+Ltrim(Str(s_nId1)), Left(s, Len(s) - 1))

RETURN NIL

FUNCTION hwg_dbg_Msg(cMessage)

   HB_SYMBOL_UNUSED(cMessage)

   IF !s_lDebugRun
      RETURN NIL
   ENDIF

RETURN NIL

FUNCTION hwg_dbg_Alert(cMessage)

   LOCAL bCode := &(IIf(Type("hwg_MsgInfo()") == "UI", "{|s|hwg_MsgInfo(s)}", ;
      IIf(Type("MsgInfo()") == "UI", "{|s|MsgInfo(s)}", "{|s|Alert(s)}")))

   Eval(bCode, cMessage)

RETURN NIL

FUNCTION hwg_dbg_Quit()

   LOCAL cCode
   LOCAL bCode

   IF Type("hwg_endwindow()") == "UI"
      cCode := "{||hwg_endwindow()"
      IF Type("hwg_Postquitmessage()") == "UI"
         cCode += ",hwg_Postquitmessage(),__Quit()}"
      ELSEIF Type("hwg_gtk_exit()") == "UI"
         cCode += ",hwg_gtk_exit(),__Quit()}"
      ELSE
         cCode += ",__Quit()}"
      ENDIF
   ELSEIF Type("ReleaseAllWindows()") == "UI"
      cCode := "{||ReleaseAllWindows()}"
   ELSE
      cCode := "{||__Quit()}"
   ENDIF

   bCode := &(cCode)

RETURN Eval(bCode)

STATIC FUNCTION Hex2Int(stroka)

   LOCAL i := ASC(stroka)
   LOCAL res

   IF i > 64 .AND. i < 71
      res := (i - 55) * 16
   ELSEIF i > 47 .AND. i < 58
      res := (i - 48) * 16
   ELSE
      RETURN 0
   ENDIF

   i := ASC(SubStr(stroka, 2, 1))
   IF i > 64 .AND. i < 71
      res += i - 55
   ELSEIF i > 47 .AND. i < 58
      res += i - 48
   ENDIF

RETURN res

STATIC FUNCTION Int2Hex(n)

   LOCAL n1 := Int(n/16)
   LOCAL n2 := n % 16

   IF n > 255
      RETURN "XX"
   ENDIF

RETURN Chr(IIf(n1 < 10, n1 + 48, n1 + 55)) + Chr(IIf(n2 < 10, n2 + 48, n2 + 55))

STATIC FUNCTION Str2Hex(stroka)

   LOCAL cRes := ""
   LOCAL i
   LOCAL nLen := Len(stroka)

   FOR i := 1 to nLen
      cRes += Int2Hex(Asc(Substr(stroka,i, 1)))
   NEXT

RETURN cRes

STATIC FUNCTION Hex2Str(stroka)

   LOCAL cRes := ""
   LOCAL i := 1
   LOCAL nLen := Len(stroka)

   DO WHILE i <= nLen
      cRes += Chr(Hex2Int(Substr(stroka, i, 2)))
      i += 2
   ENDDO

RETURN cRes

EXIT PROCEDURE hwg_dbg_exit

   hwg_dbg_Send("quit")
   FClose(s_handl1)
   FClose(s_handl2)

RETURN
