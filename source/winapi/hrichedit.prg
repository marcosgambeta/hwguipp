//
// HWGUI - Harbour Win32 GUI library source code:
// HRichEdit class
//
// Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HRichEdit INHERIT HControl

#ifdef UNICODE
   CLASS VAR winclass INIT "RichEdit20W"
#else
   CLASS VAR winclass INIT "RichEdit20A"
#endif
   
   DATA lChanged INIT .F.
   DATA lSetFocus INIT .T.
   DATA lAllowTabs INIT .F.
   DATA lctrltab HIDDEN
   DATA lReadOnly INIT .F.
   DATA Col INIT 0
   DATA Line INIT 0
   DATA LinesTotal INIT 0
   DATA SelStart INIT 0
   DATA SelText INIT 0
   DATA SelLength INIT 0
   DATA bChange

   METHOD New(oWndParent, nId, vari, nStyle, nX, nY, nWidth, nHeight, ;
      oFont, bInit, bSize, bGfocus, bLfocus, ctooltip, ;
      tcolor, bcolor, bOther, lAllowTabs, bChange, lnoBorder)

   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD When()
   METHOD Valid()
   METHOD UpdatePos()
   METHOD onChange()
   METHOD ReadOnly(lreadOnly) SETGET
   METHOD Setcolor(tColor, bColor, lRedraw)

ENDCLASS

METHOD HRichEdit:New(oWndParent, nId, vari, nStyle, nX, nY, nWidth, nHeight, ;
      oFont, bInit, bSize, bGfocus, bLfocus, ctooltip, ;
      tcolor, bcolor, bOther, lAllowTabs, bChange, lnoBorder)

   nStyle := hb_bitor(iif(nStyle == NIL, 0, nStyle), WS_CHILD + WS_VISIBLE + WS_TABSTOP + ;
      iif(lNoBorder = NIL .OR. !lNoBorder, WS_BORDER, 0))

   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, ;
      bSize, NIL, ctooltip, tcolor, iif(bcolor == NIL, hwg_Getsyscolor(COLOR_BTNHIGHLIGHT), bcolor))

   ::title := vari
   ::bOther := bOther
   ::bChange := bChange
   ::lAllowTabs := iif(Empty(lAllowTabs), ::lAllowTabs, lAllowTabs)
   ::lReadOnly := hb_bitand(nStyle, ES_READONLY) != 0

   hwg_InitRichEdit()

   ::Activate()

   IF bGfocus != NIL
      ::bGetFocus := bGfocus
      ::oParent:AddEvent(EN_SETFOCUS, ::id, {|o|::When(o)})
   ENDIF
   IF bLfocus != NIL
      ::bLostFocus := bLfocus
      ::oParent:AddEvent(EN_KILLFOCUS, ::id, {|o|::Valid(o)})
   ENDIF

   RETURN Self

METHOD HRichEdit:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createrichedit(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HRichEdit:Init()

   IF !::lInit
      ::nHolder := 1
      hwg_Setwindowobject(::handle, Self)
      Hwg_InitRichProc(::handle)
      ::Super:Init()
      ::Setcolor(::tColor, ::bColor)
      IF ::bChange != NIL
         hwg_Sendmessage(::handle, EM_SETEVENTMASK, 0, ENM_SELCHANGE + ENM_CHANGE)
         ::oParent:AddEvent(EN_CHANGE, ::id, {||::onChange()})
      ENDIF
   ENDIF

   RETURN NIL

METHOD HRichEdit:onEvent(msg, wParam, lParam)

   LOCAL nDelta

   IF hb_IsBlock(::bOther)
      nDelta := Eval(::bOther, Self, msg, wParam, lParam)
      IF ValType(nDelta) != "N" .OR. nDelta > - 1
         RETURN nDelta
      ENDIF
   ENDIF
   
   // TODO: usar SWITCH
   IF msg = WM_KEYUP .OR. msg == WM_LBUTTONDOWN .OR. msg == WM_LBUTTONUP // msg = WM_NOTIFY .OR.
      ::updatePos()
   ELSEIF msg == WM_CHAR
      wParam := hwg_PtrToUlong(wParam)
      IF wParam = VK_TAB
         IF ( hwg_IsCtrlShift(.T., .F.) .OR. !::lAllowTabs )
            RETURN 0
         ENDIF
      ENDIF
      IF !hwg_IsCtrlShift(.T., .F.)
         ::lChanged := .T.
      ENDIF
   ELSEIF msg == WM_KEYDOWN
      wParam := hwg_PtrToUlong(wParam)
      IF wParam = VK_TAB .AND. ( hwg_IsCtrlShift(.T., .F.) .OR. !::lAllowTabs )
         hwg_GetSkip(::oParent, ::handle, iif(hwg_IsCtrlShift(.F., .T.), -1, 1))
         RETURN 0
      ELSEIF wParam = VK_TAB
         hwg_Re_inserttext(::handle, Chr(VK_TAB))
         RETURN 0
      ELSEIF wParam == 27 // ESC
         IF hwg_Getparent(::oParent:handle) != NIL
            hwg_Sendmessage(hwg_Getparent(::oParent:handle), WM_CLOSE, 0, 0)
         ENDIF
      ENDIF

      IF wParam == 46     // Del
         ::lChanged := .T.
      ENDIF
   ELSEIF msg == WM_MOUSEWHEEL
      nDelta := hwg_Hiword(wParam)
      nDelta := iif(nDelta > 32768, nDelta - 65535, nDelta)
      hwg_Sendmessage(::handle, EM_SCROLL, iif(nDelta > 0, SB_LINEUP, SB_LINEDOWN), 0)
      hwg_Sendmessage(::handle, EM_SCROLL, iif(nDelta > 0, SB_LINEUP, SB_LINEDOWN), 0)
   ELSEIF msg == WM_DESTROY
      ::End()
   ENDIF

   Return - 1

METHOD HRichEdit:Setcolor(tColor, bColor, lRedraw)

   IF tcolor != NIL
      hwg_re_SetDefault(::handle, tColor)
   ENDIF
   IF bColor != NIL
      hwg_Sendmessage(::Handle, EM_SETBKGNDCOLOR, 0, bColor)
   ENDIF
   ::Super:Setcolor(tColor, bColor, lRedraw)

   RETURN NIL

METHOD HRichEdit:ReadOnly(lreadOnly)

   IF lreadOnly != NIL
      IF !Empty(hwg_Sendmessage(::handle, EM_SETREADONLY, iif(lReadOnly, 1, 0), 0))
         ::lReadOnly := lReadOnly
      ENDIF
   ENDIF

   RETURN ::lReadOnly

METHOD HRichEdit:UpdatePos()

   LOCAL npos := hwg_Sendmessage(::handle, EM_GETSEL, 0, 0)
   LOCAL pos1 := hwg_Loword(npos) + 1
   LOCAL pos2 := hwg_Hiword(npos) + 1

   ::Line := hwg_Sendmessage(::Handle, EM_LINEFROMCHAR, pos1 - 1, 0) + 1
   ::LinesTotal := hwg_Sendmessage(::handle, EM_GETLINECOUNT, 0, 0)
   ::SelText := hwg_Re_gettextrange(::handle, pos1, pos2)
   ::SelStart := pos1
   ::SelLength := pos2 - pos1
   ::Col := pos1 - hwg_Sendmessage(::Handle, EM_LINEINDEX, -1, 0)

   RETURN nPos

METHOD HRichEdit:onChange()

   IF hb_IsBlock(::bChange)
      Eval(::bChange, ::gettext(), Self)
   ENDIF

   RETURN NIL

METHOD HRichEdit:When()

   ::title := ::GetText()
   Eval(::bGetFocus, ::title, Self)

   RETURN .T.

METHOD HRichEdit:Valid()

   ::title := ::GetText()
   Eval(::bLostFocus, ::title, Self)

   RETURN .T.
