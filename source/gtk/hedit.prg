//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HEdit class
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hblang.ch"
#include "hwguipp.ch"

#ifndef DLGC_WANTARROWS
#define DLGC_WANTARROWS     1      /* Control wants arrow keys         */
#define DLGC_WANTTAB        2      /* Control wants tab keys           */
#define DLGC_WANTCHARS    128      /* Want WM_CHAR messages            */
#endif

STATIC s_lColorinFocus := .F.
STATIC s_tColorinFocus := 0
STATIC s_bColorinFocus := 16777164

CLASS HEdit INHERIT HControl

   CLASS VAR winclass INIT "EDIT"

   DATA lMultiLine INIT .F.
   DATA cType INIT "C"
   DATA bSetGet
   DATA bValid
   DATA bAnyEvent
   DATA cPicFunc
   DATA cPicMask
   DATA lPicComplex INIT .F.
   DATA lFirst INIT .T.
   DATA lChanged INIT .F.
   DATA nMaxLength  // INIT NIL
   DATA nLastKey INIT 0
   DATA lMouse INIT .F.
   DATA aColorOld INIT {0, 0}
   DATA bColorBlock

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bGfocus, bLfocus, ctoolt, tcolor, bcolor, cPicture, lNoBorder, nMaxLength, lPassword)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD SetGet(value) INLINE Eval(::bSetGet, value, self)
   METHOD Refresh()
   METHOD Value(xValue) SETGET
   METHOD SetText(value) INLINE hwg_edit_SetText(::handle, ::title := value)
   METHOD GetText() INLINE hwg_edit_GetText(::handle)
   METHOD ParsePict(cPicture, vari)

ENDCLASS

/* Added: lPassword */
METHOD HEdit:New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bGfocus, bLfocus, ctoolt, tcolor, bcolor, cPicture, lNoBorder, nMaxLength, lPassword)

   nStyle := hb_bitor(IIf(nStyle == NIL, 0, nStyle), WS_TABSTOP + IIf(lNoBorder == NIL .OR. !lNoBorder, WS_BORDER, 0) + IIf(lPassword == NIL .OR. !lPassword, 0, ES_PASSWORD))

   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize,, ctoolt, IIf(tcolor == NIL, 0, tcolor), IIf(bcolor == NIL, 0xffffff, bcolor))

   IF vari != NIL
      ::cType := ValType(vari)
   ENDIF
   IF bSetGet == NIL
      ::title := vari
   ENDIF
   ::bSetGet := bSetGet

   IF hb_bitand(nStyle, ES_MULTILINE) != 0
      ::style := hb_bitor(::style, ES_WANTRETURN)
      ::lMultiLine := .T.
   ENDIF

   ::ParsePict(cPicture, vari)
   IF Empty(::nMaxLength) .AND. !Empty(::bSetGet) .AND. hb_IsChar(vari)
      ::nMaxLength := Len(vari)
   ENDIF
   IF nMaxLength != NIL
      ::nMaxLength := nMaxLength
   ENDIF

   ::Activate()

   ::bGetFocus := bGFocus
   ::bLostFocus := bLFocus
   hwg_SetEvent(::handle, "focus_in_event", WM_SETFOCUS, 0, 0)
   hwg_SetEvent(::handle, "focus_out_event", WM_KILLFOCUS, 0, 0)
   hwg_SetEvent(::handle, "key_press_event", 0, 0, 0)
   IF ::bSetGet != NIL
      hwg_SetSignal(::handle, "paste-clipboard", WM_PASTE, 0, 0)
      hwg_SetSignal(::handle, "copy-clipboard", WM_COPY, 0, 0)
   ENDIF
   
//   ::aColorOld[1] := IIf(tcolor == NIL, 0, ::tcolor)
//   ::aColorOld[2] := ::bcolor

   RETURN Self

METHOD HEdit:Activate()
  
   IF !Empty(::oParent:handle)
      ::handle := hwg_Createedit(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      hwg_Setwindowobject(::handle, Self)
      ::Init()
   ENDIF
   
   RETURN NIL

METHOD HEdit:onEvent(msg, wParam, lParam)
   
   LOCAL oParent
   LOCAL nPos

   // hwg_WriteLog("Edit: "+Str(msg, 10)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10))
   
   IF hb_IsBlock(::bAnyEvent) .AND. Eval(::bAnyEvent, Self, msg, wParam, lParam) != 0
      RETURN 0
   ENDIF

   IF msg == WM_SETFOCUS   // msg == 7
      oParent := hwg_getParentForm(Self)

      // hwg_WriteLog("Edit: " + hwg_StrDebLog(s_lColorinFocus) + " " + ;
      //   Str(oParent:tColorinFocus, 10) + " " + Str(oParent:bColorinFocus, 10) + " " + ;
      //   hwg_StrDebNIL(::bColorBlock) ) 

      IF s_lColorinFocus .OR. oParent:tColorinFocus >= 0 .OR. oParent:bColorinFocus >= 0 .OR. ::bColorBlock != NIL
         ::aColorOld[1] := ::tcolor
         ::aColorOld[2] := ::bcolor
         IF hb_IsBlock(::bColorBlock)
            Eval(::bColorBlock, Self)
         ELSE
            ::Setcolor(IIf(oParent:tColorinFocus >= 0, oParent:tColorinFocus, s_tColorinFocus), IIf(oParent:bColorinFocus >= 0, oParent:bColorinFocus, s_bColorinFocus), .T.)
         ENDIF
      ENDIF
      IF ::lMouse
         ::lFirst := .F.
         ::lMouse := .F.
      ENDIF
      hwg_edit_set_Overmode(::handle, !Set(_SET_INSERT))
      IF ::bSetGet == NIL
         IF hb_IsBlock(::bGetFocus)
            Eval(::bGetFocus, hwg_Edit_GetText(::handle), Self)
         ENDIF
      ELSE
         __When(Self)
      ENDIF
   ELSEIF msg == WM_KILLFOCUS
      oParent := hwg_getParentForm(Self)
      IF s_lColorinFocus .OR. oParent:tColorinFocus >= 0 .OR. oParent:bColorinFocus >= 0 .OR. ::bColorBlock != NIL
         ::Setcolor(::aColorOld[1], ::aColorOld[2], .T.)
      ENDIF
      IF ::bSetGet == NIL
         IF hb_IsBlock(::bLostFocus)
            Eval(::bLostFocus, hwg_Edit_GetText(::handle), Self)
         ENDIF
      ELSE
         __Valid(Self)
      ENDIF
   ELSEIF msg == WM_LBUTTONDOWN .OR. msg == WM_RBUTTONDOWN
      ::lMouse := .T.
   ELSEIF msg == WM_DESTROY
      ::End()
   ELSEIF msg == WM_PASTE
      DoPaste(Self)
      Eval(::bSetGet, ::title, Self)
      RETURN 1
   ELSEIF msg == WM_COPY
      DoCopy(Self)
      RETURN 1
   ENDIF

   IF ::bSetGet == NIL
      ::Title := hwg_Edit_GetText(::handle)
      RETURN 0
   ENDIF

   oParent := ::oParent
   IF !::lMultiLine
      IF msg == WM_KEYDOWN
         ::nLastKey := wParam
         IF wParam == GDK_BackSpace
            ::lFirst := .F.
            hwg_SetGetUpdated(Self)
            IF ::lPicComplex
               DeleteChar(Self, .T.)
               RETURN 1
            ENDIF
            RETURN 0
         ELSEIF wParam == GDK_Down     // KeyDown
            IF lParam == 0
               hwg_GetSkip(oParent, ::handle, 1)
               RETURN 1
            ENDIF
         ELSEIF wParam == GDK_Up     // KeyUp
            IF lParam == 0
               hwg_GetSkip(oParent, ::handle, - 1)
               RETURN 1
            ENDIF
         ELSEIF wParam == GDK_Right     // KeyRight
            IF lParam == 0
               ::lFirst := .F.
               RETURN KeyRight(Self)
            ENDIF
         ELSEIF wParam == GDK_Left     // KeyLeft
            IF lParam == 0
               ::lFirst := .F.
               RETURN KeyLeft(Self)
            ENDIF
         ELSEIF wParam == GDK_Home     // Home
            IF lParam == 0
               ::lFirst := .F.
               __setInitPos(Self)
               RETURN 1
            ENDIF
         ELSEIF wParam == GDK_End     // End
            IF lParam == 0
               ::lFirst := .F.
               IF ::cType == "C"
                  nPos := Len(Trim(::title))
                  hwg_edit_SetPos(::handle, nPos)
                  RETURN 1
               ENDIF
            ENDIF
         ELSEIF wParam == GDK_Delete     // Del
            ::lFirst := .F.
            hwg_SetGetUpdated(Self)
            IF ::lPicComplex
               DeleteChar(Self, .F.)
               RETURN 1
            ENDIF
         ELSEIF wParam == GDK_Tab     // Tab
            IF hwg_Checkbit(lParam, 1)
               hwg_GetSkip(oParent, ::handle, - 1)
            ELSE
               hwg_GetSkip(oParent, ::handle, 1)
            ENDIF
            RETURN 1
         ELSEIF wParam == GDK_ISO_Left_Tab
            IF hwg_Checkbit(lParam, 1)
               hwg_GetSkip(oParent, ::handle, - 1)
            ENDIF
            RETURN 1
         ELSEIF wParam == GDK_Return .OR. wParam == GDK_KP_Enter  // Enter
            IF !hwg_GetSkip(oParent, ::handle, 1, .T.) .AND. ::bSetGet != NIL
               __Valid(Self)
            ENDIF
            RETURN 1
         ELSEIF (hwg_checkBit(lParam, 1) .AND. wParam == GDK_Insert) .OR. ;
               (hwg_checkBit(lParam, 2) .AND. (wParam == 86 .OR. wParam == 118))
            // Paste
            IF ::bSetGet != NIL
               DoPaste(Self)
               RETURN 1
            ENDIF
         ELSEIF hwg_checkBit(lParam, 2) .AND. wParam == GDK_Insert .OR. ;
               (hwg_checkBit(lParam, 2) .AND. (wParam == 67 .OR. wParam == 99))
            // Copy
            IF ::bSetGet != NIL
               DoCopy(Self)
               RETURN 1
            ENDIF
         ELSEIF wParam == GDK_Insert     // Insert
            IF lParam == 0
               SET(_SET_INSERT, !Set(_SET_INSERT))
            ENDIF
         ELSEIF ((wParam >= 32 .AND. wParam < 65000) .OR. (wParam >= GDK_KP_0 .AND. wParam <= GDK_KP_9)) ;
               .AND. !hwg_Checkbit(lParam, 2)
            IF wParam >=  GDK_KP_0
               wParam -= (GDK_KP_0 - 48)
            ENDIF
            RETURN GetApplyKey(Self, hwg_Chr(wParam))
         ELSE
            RETURN 0
         ENDIF
      ENDIF

/*
   ELSE

 
      IF msg == WM_MOUSEWHEEL
         nPos := hwg_Hiword(wParam)
         nPos := IIf(nPos > 32768, nPos - 65535, nPos)
      ENDIF
*/
   ENDIF

   RETURN 0

METHOD HEdit:Init()

   IF !::lInit
      ::Super:Init()

      ::Refresh()
   ENDIF

   RETURN NIL

METHOD HEdit:Refresh()
   
   LOCAL vari

   IF hb_IsBlock(::bSetGet)
      vari := Eval(::bSetGet, NIL, self)

      IF !Empty(::cPicFunc) .OR. !Empty(::cPicMask)
         vari := Transform(vari, ::cPicFunc + IIf(Empty(::cPicFunc), "", " ") + ::cPicMask)
      ELSE
         vari := IIf(::cType == "D", Dtoc(vari), IIf(::cType == "N", Str(vari ), IIf(::cType == "C", vari, "")))
      ENDIF
      ::title := vari
      hwg_Edit_SetText(::handle, vari)
   ELSE
      hwg_Edit_SetText(::handle, ::title)
   ENDIF
   IF hb_IsBlock(::bColorBlock) .AND. hwg_Isptreq(::handle, hwg_Getfocus())
      Eval(::bColorBlock, Self)
   ENDIF

   RETURN NIL

METHOD HEdit:Value(xValue)

   LOCAL vari

   IF xValue != NIL
      IF !Empty(::cPicFunc) .OR. !Empty(::cPicMask)
         ::title := Transform(xValue, ::cPicFunc + IIf(Empty(::cPicFunc), "", " ") + ::cPicMask)
      ELSE
         ::title := xValue
      ENDIF
      hwg_Edit_SetText(::handle, ::title)
      IF hb_IsBlock(::bSetGet)
         Eval(::bSetGet, xValue, Self)
      ENDIF
      RETURN xValue
   ENDIF

   vari := IIf(Empty(::handle), ::title, hwg_Edit_GetText(::handle))
   IF !Empty(::cPicFunc) .OR. !Empty(::cPicMask)
      vari := UnTransform(Self, vari)
   ENDIF
   IF ::cType == "D"
      vari := CToD(vari)
   ELSEIF ::cType == "N"
      vari := Val(LTrim(vari))
   ELSEIF ::cType == "C" .AND. !Empty(::nMaxLength)
      vari := PadR(vari, ::nMaxLength)
   ENDIF

   RETURN vari

METHOD HEdit:ParsePict(cPicture, vari)
   
   LOCAL nAt
   LOCAL i
   LOCAL masklen
   LOCAL cChar

   IF ::bSetGet == NIL
      RETURN NIL
   ENDIF
   ::cPicFunc := ::cPicMask := ""
   IF cPicture != NIL
      IF Left(cPicture, 1) == "@"
         nAt := At(" ", cPicture)
         IF nAt == 0
            ::cPicFunc := Upper(cPicture)
            ::cPicMask := ""
         ELSE
            ::cPicFunc := Upper(SubStr(cPicture, 1, nAt - 1))
            ::cPicMask := SubStr(cPicture, nAt + 1)
         ENDIF
         IF ::cPicFunc == "@"
            ::cPicFunc := ""
         ENDIF
      ELSE
         ::cPicFunc := ""
         ::cPicMask := cPicture
      ENDIF
      IF Empty(::nMaxLength) .AND. !Empty(::cPicMask) .AND. !(::cPicFunc == "@R")
         ::nMaxLength := Len(::cPicMask)
      ENDIF
   ENDIF

   IF Empty(::cPicMask)
      IF ::cType == "D"
         ::cPicMask := StrTran(Dtoc(CToD(Space(8))), " ", "9")
      ELSEIF ::cType == "N"
         vari := Str(vari)
         IF (nAt := At(".", vari)) > 0
            ::cPicMask := Replicate("9", nAt - 1) + "." + Replicate("9", Len(vari) - nAt)
         ELSE
            ::cPicMask := Replicate("9", Len(vari))
         ENDIF
      ENDIF
   ENDIF

   IF !Empty(::cPicMask)
      masklen := Len(::cPicMask)
      FOR i := 1 TO masklen
         cChar := SubStr(::cPicMask, i, 1)
         IF !cChar $ "!ANX9#"
            ::lPicComplex := .T.
            EXIT
         ENDIF
      NEXT
   ENDIF

   //                                         ------------ added by Maurizio la Cecilia

   IF !Empty(::nMaxLength) .AND. Len(::cPicMask) < ::nMaxLength
      ::cPicMask := PadR(::cPicMask, ::nMaxLength, "X")
   ENDIF

   //                                         ------------- end of added code

   RETURN NIL

STATIC FUNCTION IsEditable(oEdit, nPos)
   
   LOCAL cChar

   IF Empty(oEdit:cPicMask)
      RETURN .T.
   ENDIF
   IF nPos > Len(oEdit:cPicMask)
      RETURN .F.
   ENDIF

   cChar := SubStr(oEdit:cPicMask, nPos, 1)

   IF oEdit:cType == "C"
      RETURN cChar $ "!ANX9#"
   ELSEIF oEdit:cType == "N"
      RETURN cChar $ "9#$*"
   ELSEIF oEdit:cType == "D"
      RETURN cChar == "9"
   ELSEIF oEdit:cType == "L"
      RETURN cChar $ "TFYN"
   ENDIF

   RETURN .F.

STATIC FUNCTION KeyRight(oEdit, nPos)
   
   LOCAL masklen
   LOCAL newpos
   // Variables not used
   // i , vari

   IF oEdit == NIL
      RETURN 0
   ENDIF
   IF nPos == NIL
      nPos := hwg_edit_Getpos(oEdit:handle) + 1
   ENDIF
   IF oEdit:cPicMask == NIL .OR. Empty(oEdit:cPicMask)
      hwg_edit_Setpos(oEdit:handle, nPos)
   ELSE
      masklen := Len(oEdit:cPicMask)
      DO WHILE nPos <= masklen
         IF IsEditable(oEdit, ++ nPos)
            // hwg_WriteLog("KeyRight-2 "+str(nPos))
            hwg_edit_Setpos(oEdit:handle, nPos - 1)
            EXIT
         ENDIF
      ENDDO
   ENDIF

   //Added By Sandro Freire

   IF !Empty(oEdit:cPicMask)
      newPos := Len(oEdit:cPicMask)
      //hwg_WriteLog("KeyRight-2 "+str(nPos) + " " +str(newPos))
      IF nPos > newPos .AND. !Empty(Trim(oEdit:Title))
         hwg_edit_Setpos(oEdit:handle, newPos)
      ENDIF
   ENDIF

   RETURN 1

STATIC FUNCTION KeyLeft(oEdit, nPos)
   
   // Variables not used
   // LOCAL i

   IF oEdit == NIL
      RETURN 0
   ENDIF
   IF nPos == NIL
      nPos := hwg_edit_Getpos(oEdit:handle) + 1
   ENDIF
   IF oEdit:cPicMask == NIL .OR. Empty(oEdit:cPicMask)
      hwg_edit_Setpos(oEdit:handle, nPos - 2)
   ELSE
      DO WHILE nPos >= 1
         IF IsEditable(oEdit, --nPos)
            hwg_edit_Setpos(oEdit:handle, nPos - 1)
            EXIT
         ENDIF
      ENDDO
   ENDIF

   RETURN 1

STATIC FUNCTION DeleteChar(oEdit, lBack)
   
   LOCAL nPos := hwg_edit_Getpos(oEdit:handle) + IIf(!lBack, 1, 0)
   LOCAL nGetLen := Len(oEdit:cPicMask)
   LOCAL nLen

   FOR nLen := 0 TO nGetLen
      IF !IsEditable(oEdit, nPos + nLen)
         EXIT
      ENDIF
   NEXT
   IF nLen == 0
      DO WHILE nPos >= 1
         nPos --
         nLen ++
         IF IsEditable(oEdit, nPos)
            EXIT
         ENDIF
      ENDDO
   ENDIF
   IF nPos > 0
      oEdit:title := PadR(Left(oEdit:title, nPos - 1) + ;
         SubStr(oEdit:title, nPos + 1, nLen - 1) + " " + ;
         SubStr(oEdit:title, nPos + nLen), nGetLen)
      hwg_edit_Settext(oEdit:handle, oEdit:title)
      hwg_edit_Setpos(oEdit:handle, nPos - 1)
   ENDIF

   RETURN NIL

STATIC FUNCTION INPUT(oEdit, cChar, nPos)
   
   LOCAL cPic

   IF !Empty(oEdit:cPicMask) .AND. nPos > Len(oEdit:cPicMask)
      RETURN NIL
   ENDIF
   IF oEdit:cType == "N"
      IF cChar == "-"
         IF nPos != 1
            RETURN NIL
         ENDIF
         // ::minus := .T.
      ELSEIF !(cChar $ "0123456789")
         RETURN NIL
      ENDIF

   ELSEIF oEdit:cType == "D"

      IF !(cChar $ "0123456789")
         RETURN NIL
      ENDIF

   ELSEIF oEdit:cType == "L"

      IF !(Upper(cChar) $ "YNTF")
         RETURN NIL
      ENDIF

   ENDIF

   IF !Empty(oEdit:cPicFunc)
      cChar := Transform(cChar, oEdit:cPicFunc)
   ENDIF

   IF !Empty(oEdit:cPicMask)
      cPic := SubStr(oEdit:cPicMask, nPos, 1)

      cChar := Transform(cChar, cPic)
      IF cPic == "A"
         IF !IsAlpha(cChar)
            cChar := NIL
         ENDIF
      ELSEIF cPic == "N"
         IF !IsAlpha(cChar) .AND. !IsDigit(cChar)
            cChar := NIL
         ENDIF
      ELSEIF cPic == "9"
         IF !IsDigit(cChar) .AND. cChar != "-"
            cChar := NIL
         ENDIF
      ELSEIF cPic == "#"
         IF !IsDigit(cChar) .AND. !(cChar == " ") .AND. !(cChar $ "+-")
            cChar := NIL
         ENDIF
      ENDIF
   ENDIF

   RETURN cChar

STATIC FUNCTION GetApplyKey(oEdit, cKey)
   
   LOCAL nPos
   LOCAL nGetLen
   LOCAL nLen
   LOCAL vari
   LOCAL i
   LOCAL newPos

   // hwg_WriteLog("GetApplyKey "+str(asc(ckey)))
   IF oEdit:lFirst
      __setInitPos(oEdit)
   ENDIF
   oEdit:title := hwg_edit_Gettext(oEdit:handle)
   IF oEdit:cType == "N" .AND. cKey $ ".," .AND. ;
         (nPos := At(".", oEdit:cPicMask)) != 0
      IF oEdit:lFirst
         vari := 0
      ELSE
         vari := Trim(oEdit:title)
         FOR i := 2 TO Len(vari)
            IF !IsDigit(SubStr(vari, i, 1))
               vari := Left(vari, i - 1) + SubStr(vari, i + 1)
            ENDIF
         NEXT
         vari := Val(vari)
      ENDIF
      IF !Empty(oEdit:cPicFunc) .OR. !Empty(oEdit:cPicMask)
         oEdit:title := Transform(vari, oEdit:cPicFunc + IIf(Empty(oEdit:cPicFunc), "", " ") + oEdit:cPicMask)
      ENDIF
      hwg_edit_Settext(oEdit:handle, oEdit:title)
      KeyRight(oEdit, nPos - 1)
   ELSE

      IF oEdit:cType == "N" .AND. oEdit:lFirst
         nGetLen := Len(oEdit:cPicMask)
         IF (nPos := At(".", oEdit:cPicMask)) == 0
            oEdit:title := Space(nGetLen)
         ELSE
            oEdit:title := Space(nPos - 1) + "." + Space(nGetLen - nPos)
         ENDIF
         nPos := 1
      ELSE
         nPos := hwg_edit_Getpos(oEdit:handle) + 1
      ENDIF
      cKey := Input(oEdit, cKey, nPos)
      IF cKey != NIL
         hwg_SetGetUpdated(oEdit)
         IF SET(_SET_INSERT) // .OR. hwg_Hiword(x) != hwg_Loword(x)
            IF oEdit:lPicComplex
               nGetLen := Len(oEdit:cPicMask)
               FOR nLen := 0 TO nGetLen
                  IF !IsEditable(oEdit, nPos + nLen)
                     EXIT
                  ENDIF
               NEXT
               oEdit:title := hwg_Left(oEdit:title, nPos - 1) + cKey + ;
                  hwg_SubStr(oEdit:title, nPos, nLen - 1) + hwg_SubStr(oEdit:title, nPos + nLen)
            ELSE
               oEdit:title := hwg_Left(oEdit:title, nPos - 1) + cKey + ;
                  hwg_SubStr(oEdit:title, nPos)
            ENDIF

            IF !Empty(oEdit:cPicMask) .AND. Len(oEdit:cPicMask) < hwg_Len(oEdit:title)
               oEdit:title := hwg_Left(oEdit:title, nPos - 1) + cKey + hwg_SubStr(oEdit:title, nPos + 1)
            ENDIF
         ELSE
            oEdit:title := hwg_Left(oEdit:title, nPos - 1) + cKey + hwg_SubStr(oEdit:title, nPos + 1)
         ENDIF
         IF !Empty(oEdit:nMaxLength)
            i := Len(oEdit:cPicMask)
            i := IIf(!Empty(i) .AND. i > oEdit:nMaxLength, i, oEdit:nMaxLength)
            IF i > (nLen := hwg_Len(oEdit:title))
               oEdit:title += Space(i - nLen)
            ENDIF
         ENDIF
         hwg_edit_Settext(oEdit:handle, oEdit:title)
         // hwg_WriteLog("GetApplyKey "+oEdit:title+str(nPos-1))
         KeyRight(oEdit, nPos)
         //Added By Sandro Freire
         IF oEdit:cType == "N"
            IF !Empty(oEdit:cPicMask)
               newPos := Len(oEdit:cPicMask) - 3
               IF "E" $ oEdit:cPicFunc .AND. nPos == newPos
                  GetApplyKey(oEdit, ",")
               ENDIF
            ENDIF
         ENDIF

      ENDIF
   ENDIF
   oEdit:lFirst := .F.

   RETURN 1

STATIC FUNCTION __setInitPos(oCtrl)
   
   LOCAL n := 1

   IF !Empty(oCtrl:cPicMask)
      DO WHILE !(SubStr(oCtrl:cPicMask, n, 1) $ "ANX9#LY!$*.,")
         n ++
      ENDDO
   ENDIF
   hwg_edit_Setpos(oCtrl:handle, n - 1)

   RETURN NIL

STATIC FUNCTION __When(oCtrl)
   
   LOCAL res := .T.

   oCtrl:Refresh()
   //oCtrl:lFirst := .T.
   IF hb_IsBlock(oCtrl:bGetFocus)
      res := Eval(oCtrl:bGetFocus, oCtrl:title, oCtrl)
      IF !res
         hwg_GetSkip(oCtrl:oParent, oCtrl:handle, 1)
      ENDIF
   ENDIF

   RETURN res

STATIC FUNCTION __valid(oCtrl)

   LOCAL vari
   LOCAL oDlg

   IF oCtrl:bSetGet != NIL
      IF (oDlg := hwg_getParentForm(oCtrl)) == NIL .OR. oDlg:nLastKey != 27
         vari := UnTransform(oCtrl, hwg_Edit_GetText(oCtrl:handle))
         oCtrl:title := vari
         IF oCtrl:cType == "D"
            IF IsBadDate(vari)
               hwg_Setfocus(oCtrl:handle)
               hwg_edit_SetPos(oCtrl:handle, 0)
               RETURN .F.
            ENDIF
            vari := CToD(vari)
         ELSEIF oCtrl:cType == "N"
            vari := Val(LTrim(vari))
            oCtrl:title := Transform(vari, oCtrl:cPicFunc + IIf(Empty(oCtrl:cPicFunc), "", " ") + oCtrl:cPicMask)
            hwg_edit_Settext(oCtrl:handle, oCtrl:title)
         ELSEIF oCtrl:cType == "C" .AND. !Empty(oCtrl:nMaxLength)
            oCtrl:title := vari := PadR(vari, oCtrl:nMaxLength)
         ENDIF
         Eval(oCtrl:bSetGet, vari, oCtrl)

         IF oDlg != NIL
            oDlg:nLastKey := 27
         ENDIF
         IF hb_IsBlock(oCtrl:bLostFocus) .AND. !Eval(oCtrl:bLostFocus, vari, oCtrl)
            hwg_Setfocus(oCtrl:handle)
            hwg_edit_SetPos(oCtrl:handle, 0)
            IF oDlg != NIL
               oDlg:nLastKey := 0
            ENDIF
            RETURN .F.
         ENDIF
         IF oDlg != NIL
            oDlg:nLastKey := 0
         ENDIF
      ENDIF
   ENDIF

   RETURN .T.

STATIC FUNCTION Untransform(oEdit, cBuffer)
   
   LOCAL xValue
   LOCAL cChar
   LOCAL nFor
   LOCAL minus

   IF oEdit:cType == "C"

      IF "R" $ oEdit:cPicFunc
         FOR nFor := 1 TO Len(oEdit:cPicMask)
            cChar := SubStr(oEdit:cPicMask, nFor, 1)
            IF !cChar $ "ANX9#!"
               cBuffer := SubStr(cBuffer, 1, nFor - 1) + Chr(1) + SubStr(cBuffer, nFor + 1)
            ENDIF
         NEXT
         cBuffer := StrTran(cBuffer, Chr(1), "")
      ENDIF

      xValue := cBuffer

   ELSEIF oEdit:cType == "N"
      minus := (Left(LTrim(cBuffer), 1) == "-")
      cBuffer := Space(FirstEditable(oEdit) - 1) + SubStr(cBuffer, FirstEditable(oEdit), LastEditable(oEdit) - FirstEditable(oEdit) + 1)

      IF "D" $ oEdit:cPicFunc
         FOR nFor := FirstEditable(oEdit) TO LastEditable(oEdit)
            IF !IsEditable(oEdit, nFor)
               cBuffer := Left(cBuffer, nFor - 1) + Chr(1) + SubStr(cBuffer, nFor + 1)
            ENDIF
         NEXT
      ELSE
         IF "E" $ oEdit:cPicFunc
            cBuffer := Left(cBuffer, FirstEditable(oEdit) - 1) + ;
               StrTran(SubStr(cBuffer, FirstEditable(oEdit), LastEditable(oEdit) - FirstEditable(oEdit) + 1), ".", " ") + ;
               SubStr(cBuffer, LastEditable(oEdit) + 1)
            cBuffer := Left(cBuffer, FirstEditable(oEdit) - 1) + ;
               StrTran(SubStr(cBuffer, FirstEditable(oEdit), LastEditable(oEdit) - FirstEditable(oEdit) + 1), ",", "." ) + ;
               SubStr(cBuffer, LastEditable(oEdit) + 1)
         ELSE
            cBuffer := Left(cBuffer, FirstEditable(oEdit) - 1) + ;
               StrTran(SubStr(cBuffer, FirstEditable(oEdit), LastEditable(oEdit) - FirstEditable(oEdit) + 1), ",", " ") + ;
               SubStr(cBuffer, LastEditable(oEdit) + 1)
         ENDIF

         FOR nFor := FirstEditable(oEdit) TO LastEditable(oEdit)
            IF !IsEditable(oEdit, nFor) .AND. SubStr(cBuffer, nFor, 1) != "."
               cBuffer := Left(cBuffer, nFor - 1) + Chr(1) + SubStr(cBuffer, nFor + 1)
            ENDIF
         NEXT
      ENDIF

      cBuffer := StrTran(cBuffer, Chr(1), "")

      cBuffer := StrTran(cBuffer, "$", " ")
      cBuffer := StrTran(cBuffer, "*", " ")
      cBuffer := StrTran(cBuffer, "-", " ")
      cBuffer := StrTran(cBuffer, "(", " ")
      cBuffer := StrTran(cBuffer, ")", " ")

      cBuffer := PadL(StrTran(cBuffer, " ", ""), Len(cBuffer))

      IF minus
         FOR nFor := 1 TO Len(cBuffer)
            IF IsDigit(SubStr(cBuffer, nFor, 1))
               EXIT
            ENDIF
         NEXT
         nFor --
         IF nFor > 0
            cBuffer := Left(cBuffer, nFor - 1) + "-" + SubStr(cBuffer, nFor + 1)
         ELSE
            cBuffer := "-" + cBuffer
         ENDIF
      ENDIF

      xValue := cBuffer

   ELSEIF oEdit:cType == "L"

      cBuffer := Upper(cBuffer)
      xValue := "T" $ cBuffer .OR. "Y" $ cBuffer .OR. hb_langmessage(HB_LANG_ITEM_BASE_TEXT + 1) $ cBuffer

   ELSEIF oEdit:cType == "D"

      IF "E" $ oEdit:cPicFunc
         cBuffer := SubStr(cBuffer, 4, 3) + SubStr(cBuffer, 1, 3) + SubStr(cBuffer, 7)
      ENDIF
      xValue := cBuffer

   ENDIF

   RETURN xValue

STATIC FUNCTION FirstEditable(oEdit)
   
   LOCAL nFor
   LOCAL nMaxLen := Len(oEdit:cPicMask)

   IF IsEditable(oEdit, 1)
      RETURN 1
   ENDIF

   FOR nFor := 2 TO nMaxLen
      IF IsEditable(oEdit, nFor)
         RETURN nFor
      ENDIF
   NEXT

   RETURN 0

STATIC FUNCTION  LastEditable(oEdit)
   
   LOCAL nFor
   LOCAL nMaxLen := Len(oEdit:cPicMask)

   FOR nFor := nMaxLen TO 1 step - 1
      IF IsEditable(oEdit, nFor)
         RETURN nFor
      ENDIF
   NEXT

   RETURN 0

STATIC FUNCTION IsBadDate(cBuffer)
   
   LOCAL i
   LOCAL nLen

   IF !Empty(CToD(cBuffer))
      RETURN .F.
   ENDIF
   nLen := Len(cBuffer)
   FOR i := 1 TO nLen
      IF IsDigit(SubStr(cBuffer, i, 1))
         RETURN .T.
      ENDIF
   NEXT

   RETURN .F.

STATIC FUNCTION DoCopy(oEdit)

   LOCAL cClipboardText := hwg_Edit_GetText(oEdit:handle)
   LOCAL aPos := hwg_Edit_GetSelPos(oEdit:handle)

   IF aPos != NIL .AND. aPos[2] > aPos[1] .AND.aPos[2] - aPos[1] < hwg_Len(cClipboardText)
      hwg_Copystringtoclipboard(hwg_SubStr(cClipboardText, aPos[1] + 1, aPos[2] - aPos[1]))
   ELSE
      hwg_Copystringtoclipboard(UnTransform(oEdit, cClipboardText))
   ENDIF
   RETURN NIL

STATIC FUNCTION DoPaste(oEdit)

   LOCAL cClipboardText := hwg_Getclipboardtext()
   LOCAL nPos

   IF !Empty(cClipboardText)
      FOR nPos := 1 TO hwg_Len(cClipboardText)
         GetApplyKey(oEdit, hwg_SubStr(cClipboardText, nPos, 1))
      NEXT
      oEdit:title := UnTransform(oEdit, hwg_Edit_GetText(oEdit:handle))
   ENDIF

   RETURN NIL

FUNCTION hwg_CreateGetList(oDlg)

   LOCAL i
   LOCAL j
   LOCAL aLen1 := Len(oDlg:aControls)
   LOCAL aLen2

   FOR i := 1 TO aLen1
      IF __ObjHasMsg(oDlg:aControls[i], "BSETGET") .AND. oDlg:aControls[i]:bSetGet != NIL
         AAdd(oDlg:GetList, oDlg:aControls[i])
      ELSEIF !Empty(oDlg:aControls[i]:aControls)
         aLen2 := Len(oDlg:aControls[i]:aControls)
         FOR j := 1 TO aLen2
            IF __ObjHasMsg(oDlg:aControls[i]:aControls[j], "BSETGET") .AND. oDlg:aControls[i]:aControls[j]:bSetGet != NIL
               AAdd(oDlg:GetList, oDlg:aControls[i]:aControls[j])
            ENDIF
         NEXT
      ENDIF
   NEXT

   RETURN NIL

FUNCTION hwg_GetSkip(oParent, hCtrl, nSkip, lClipper)

   LOCAL i
   LOCAL aLen

   DO WHILE oParent != NIL .AND. !__ObjHasMsg(oParent, "GETLIST")
      oParent := oParent:oParent
   ENDDO
   IF oParent == NIL .OR. (lClipper != NIL .AND. lClipper .AND. !oParent:lClipper)
      RETURN .F.
   ENDIF
   IF hCtrl == NIL
      i := 0
   ENDIF
   IF hCtrl == NIL .OR. (i := Ascan(oParent:Getlist,{|o|o:handle == hCtrl})) != 0
      IF (aLen := Len(oParent:Getlist)) > 1
         IF nSkip > 0
            DO WHILE (i := i + nSkip) <= aLen
               IF !oParent:Getlist[i]:lHide .AND. hwg_Iswindowenabled(oParent:Getlist[i]:Handle) // Now tab and enter goes trhow the check, combo, etc...
                  IF oParent:Getlist[i]:winclass == "EDIT"
                     oParent:Getlist[i]:lFirst := .T.
                  ENDIF
                  hwg_Setfocus(oParent:Getlist[i]:handle)
                  RETURN .T.
               ENDIF
            ENDDO
         ELSE
            DO WHILE (i := i + nSkip) > 0
               IF !oParent:Getlist[i]:lHide .AND. hwg_Iswindowenabled(oParent:Getlist[i]:Handle)
                  IF oParent:Getlist[i]:winclass == "EDIT"
                     oParent:Getlist[i]:lFirst := .T.
                  ENDIF
                  hwg_Setfocus(oParent:Getlist[i]:handle)
                  RETURN .T.
               ENDIF
            ENDDO
         ENDIF
      ENDIF
   ENDIF

   RETURN .F.

FUNCTION hwg_SetGetUpdated(o)

   o:lChanged := .T.
   IF (o := hwg_getParentForm(o)) != NIL
      o:lUpdated := .T.
   ENDIF

   RETURN NIL

FUNCTION hwg_SetColorinFocus(lDef, tColor, bColor)

   IF hb_IsObject(lDef)
      IF tColor != NIL
         lDef:tColorinFocus := tColor
      ENDIF
      IF bColor != NIL
         lDef:bColorinFocus := bColor
      ENDIF
   ELSEIF hb_IsLogical(lDef)
      s_lColorinFocus := lDef
      IF tColor != NIL
         s_tColorinFocus := tColor
      ENDIF
      IF bColor != NIL
         s_bColorinFocus := bColor
      ENDIF
   ENDIF

   RETURN .T.

FUNCTION hwg_Chr(nCode)
   RETURN IIf(hb_cdpSelect() == "UTF8", hwg_keyToUtf8(nCode), Chr(nCode))

FUNCTION hwg_Substr(cString, nPos, nLen)
   RETURN IIf(hb_cdpSelect() == "UTF8", ;
      IIf(nLen == NIL, hb_utf8Substr(cString, nPos), hb_utf8Substr(cString, nPos, nLen)), ;
      IIf(nLen == NIL, Substr(cString, nPos), Substr(cString, nPos, nLen)))

FUNCTION hwg_Left(cString, nLen)
   RETURN IIf(hb_cdpSelect() == "UTF8", hb_utf8Left(cString, nLen), Left(cString, nLen))

FUNCTION hwg_Len(cString)
   RETURN IIf(hb_cdpSelect() == "UTF8", hb_utf8Len(cString), Len(cString))


FUNCTION hwg_GET_Helper(cp_get,nlen)
 
   LOCAL c_get

  c_get := cp_get

#ifdef __GTK__  
  IF Empty(c_get)
    c_get := ""
  ELSE
   IF nlen == NIL
    c_get := RTRIM(c_get)
   ELSE
    c_get := PADR(c_get,nlen)
   ENDIF
  ENDIF
#endif

RETURN c_get
