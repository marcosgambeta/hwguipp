//
// HWGUI - Harbour Win32 GUI library source code:
// HStaticLink class
//

#include <hbclass.ch>
#include <common.ch>
#include "hwguipp.ch"

#define _HYPERLINK_EVENT   WM_USER + 101
#define LBL_INIT           0
#define LBL_NORMAL         1
#define LBL_VISITED        2
#define LBL_MOUSEOVER      3
#define TRANSPARENT        1


CLASS HStaticLink FROM HSTATIC

   DATA state
   DATA m_bFireChild INIT .F.

   DATA m_hHyperCursor INIT hwg_Loadcursor(32649)

   DATA m_bMouseOver INIT .F.
   DATA m_bVisited INIT .F.

   DATA m_csUrl
   DATA dwFlags INIT 0

   DATA m_sHoverColor
   DATA m_sLinkColor
   DATA m_sVisitedColor

   CLASS VAR winclass INIT "STATIC"

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, cLink, vColor, lColor, hColor)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, cLink, vColor, lColor, hColor)
   METHOD Activate()
   METHOD Init()
   METHOD onEvent(msg, wParam, lParam)
   METHOD GoToLinkUrl(csLink)
   METHOD SetLinkUrl(csUrl)
   METHOD GetLinkUrl()
   METHOD SetVisitedColor(sVisitedColor)
   METHOD SetHoverColor(cHoverColor)
   METHOD SetFireChild(lFlag) INLINE ::m_bFireChild := lFlag
   METHOD OnClicked()
   METHOD SetLinkColor(sLinkColor)
   METHOD Paint()
   METHOD OnMouseMove(nFlags, lParam)  // point

ENDCLASS

METHOD HStaticLink:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, cLink, vColor, lColor, hColor)

   LOCAL oPrevFont
   LOCAL n

   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp)

   DEFAULT vColor TO hwg_ColorRgb2N(5, 34, 143)
   DEFAULT lColor TO hwg_ColorRgb2N(0, 0, 255)
   DEFAULT hColor TO hwg_ColorRgb2N(255, 0, 0)
   ::m_csUrl := cLink
   ::m_sHoverColor := hColor
   ::m_sLinkColor := lColor
   ::m_sVisitedColor := vColor

   ::state := LBL_INIT
   ::title := IIf(cCaption == NIL, "", cCaption)

   // Test The Font the underline must be 1
   IF ::oFont == NIL
      IF ::oParent:oFont != NIL
         ::oFont := HFONT():Add(::oParent:oFont:name, ::oParent:oFont:width, ::oParent:oFont:height, ::oParent:oFont:weight, ::oParent:oFont:charset, ::oParent:oFont:italic, 1, ::oParent:oFont:StrikeOut)
      ELSE
         ::oFont := HFONT():Add("Arial", 0, -12, , , , 1)
      ENDIF
   ELSE
      IF ::oFont:Underline  == 0
         oPrevFont := ::oFont
         ::oFont:Release()
         ::oFont := HFONT():Add(oPrevFont:name, oPrevFont:width, oPrevFont:height, oPrevFont:weight, oPrevFont:charset, oPrevFont:italic, 1, oPrevFont:StrikeOut)
      ENDIF
   ENDIF

   IF lTransp != NIL .AND. lTransp
      ::extStyle += WS_EX_TRANSPARENT
   ENDIF

   IF (n := hb_bitand(::style, SS_TYPEMASK)) == SS_RIGHT
      ::dwFlags := hb_bitor(DT_RIGHT, DT_WORDBREAK)
   ELSEIF n == SS_CENTER
      ::dwFlags := hb_bitor(SS_CENTER, DT_WORDBREAK)
   ELSEIF n == SS_LEFTNOWORDWRAP
      ::dwFlags := DT_LEFT
   ELSE
      ::dwFlags := hb_bitOr(DT_LEFT, DT_WORDBREAK)
   ENDIF
   ::dwFlags  += (DT_VCENTER + DT_END_ELLIPSIS)

   hwg_RegOwnBtn()
   ::Activate()

   RETURN Self

/* added: cCaption */
METHOD HStaticLink:Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, cLink, vColor, lColor, hColor)

   LOCAL oPrevFont

   HB_SYMBOL_UNUSED(lTransp)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)

   DEFAULT vColor TO hwg_ColorRgb2N(5, 34, 143)
   DEFAULT lColor TO hwg_ColorRgb2N(0, 0, 255)
   DEFAULT hColor TO hwg_ColorRgb2N(255, 0, 0)
   ::state := LBL_INIT
   ::m_csUrl := cLink
   ::m_sHoverColor := hColor
   ::m_sLinkColor := lColor
   ::m_sVisitedColor := vColor

   IF ::oFont == NIL
      IF ::oParent:oFont != NIL
         ::oFont := HFONT():Add(::oParent:oFont:name, ::oParent:oFont:width, ::oParent:oFont:height, ::oParent:oFont:weight, ::oParent:oFont:charset, ::oParent:oFont:italic, 1, ::oParent:oFont:StrikeOut)
      ENDIF
   ELSE
      IF ::oFont:Underline  == 0
         oPrevFont := ::oFont
         ::oFont:Release()
         ::oFont := HFONT():Add(oPrevFont:name, oPrevFont:width, oPrevFont:height, oPrevFont:weight, oPrevFont:charset, oPrevFont:italic, 1, oPrevFont:StrikeOut)
      ENDIF
   ENDIF

   ::title := cCaption
   ::style := ::nX := ::nY := ::nWidth := ::nHeight := 0

   hwg_RegOwnBtn()

   RETURN Self

METHOD HStaticLink:Activate()
   IF !Empty(::oParent:handle)
      ::handle := hwg_Createownbtn(::oParent:handle, ::id, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF
RETURN NIL

METHOD HStaticLink:Init()

   IF !::lInit
      ::nHolder := 1
      hwg_Setwindowobject(::handle, Self)
      Hwg_InitWinCtrl(::handle)
   ENDIF

   RETURN NIL

METHOD HStaticLink:onEvent(msg, wParam, lParam)

   SWITCH msg
   CASE WM_PAINT
      ::Paint()
      EXIT
   CASE WM_ERASEBKGND
      RETURN 1
   CASE WM_MOUSEMOVE
      hwg_SetCursor(::m_hHyperCursor)
      ::OnMouseMove(wParam, lParam)
      EXIT
   CASE WM_SETCURSOR
      hwg_SetCursor(::m_hHyperCursor)
      EXIT
   CASE WM_LBUTTONDOWN
      hwg_SetCursor(::m_hHyperCursor)
      EXIT
   CASE WM_LBUTTONUP
      ::OnClicked()
      EXIT
   CASE WM_KILLFOCUS
      IF ::state == LBL_MOUSEOVER
         ::state := LBL_NORMAL
         hwg_Releasecapture()
         hwg_Invalidaterect(::handle, 0)
      ENDIF
   ENDSWITCH

   RETURN -1

METHOD HStaticLink:GoToLinkUrl(csLink)

   LOCAL hInstance := hwg_Shellexecute(csLink, "open", NIL, NIL, 2)

   IF hInstance < 33
      RETURN .F.
   ENDIF

   RETURN .T.

METHOD HStaticLink:SetLinkUrl(csUrl)

   ::m_csUrl := csUrl

   RETURN NIL

METHOD HStaticLink:GetLinkUrl()

   RETURN ::m_csUrl

METHOD HStaticLink:SetVisitedColor(sVisitedColor)

   ::m_sVisitedColor := sVisitedColor

   RETURN NIL

METHOD HStaticLink:SetHoverColor(cHoverColor)

   ::m_sHoverColor := cHoverColor

   RETURN NIL

METHOD HStaticLink:OnClicked()

   LOCAL nCtrlID

   IF (::m_bFireChild)
      nCtrlID := ::id
      ::Sendmessage(::oparent:Handle, _HYPERLINK_EVENT, nCtrlID, 0)
   ELSE
      ::GoToLinkUrl(::m_csUrl)
   ENDIF

   ::m_bVisited := .T.
   hwg_Releasecapture()

   ::state := LBL_NORMAL
   hwg_Invalidaterect(::handle, 0)
   hwg_Setfocus(::handle)
   //hwg_Postmessage(::handle, WM_PAINT, 0, 0)

   RETURN NIL

METHOD HStaticLink:SetLinkColor(sLinkColor)

   ::m_sLinkColor := sLinkColor

   RETURN NIL

METHOD HStaticLink:OnMouseMove(nFlags, lParam)

   HB_SYMBOL_UNUSED(nFlags)

   //hwg_writelog(str(hwg_Loword(lParam)) + " " + str(hwg_Hiword(lParam)))
   IF ::state != LBL_INIT

      IF hwg_Loword(lParam) > ::nWidth .OR. hwg_Hiword(lParam) > ::nHeight

         //hwg_writelog("release")
         hwg_Releasecapture()
         ::state := LBL_NORMAL
         hwg_Invalidaterect(::handle, 0)
         //hwg_Postmessage(::handle, WM_PAINT, 0, 0)
      ELSEIF ::state == LBL_NORMAL

         ::state := LBL_MOUSEOVER
         hwg_Invalidaterect(::handle, 0)
         //hwg_Postmessage(::handle, WM_PAINT, 0, 0)
         //HWG_SETFOREGROUNDWINDOW(::handle)
         hwg_Setcapture(::handle)
      ENDIF

   ENDIF

   RETURN 0

METHOD HStaticLink:Paint()

   LOCAL pps
   LOCAL hDC
   LOCAL aCoors

   IF ::state == LBL_INIT
      ::state := LBL_NORMAL
   ENDIF

   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint(::handle, pps)
   aCoors := hwg_Getclientrect(::handle)

   hwg_Setbkmode(hDC, TRANSPARENT)
   hwg_Selectobject(hDC, ::oFont:handle)
   hwg_Settextcolor(hDC, IIf(::state == LBL_NORMAL, IIf(::m_bVisited, ::m_sVisitedColor, ::m_sLinkColor), ::m_sHoverColor))

   hwg_Drawtext(hDC, ::Title, aCoors[1], aCoors[2], aCoors[3], aCoors[4], ::dwFlags)

   hwg_Endpaint(::handle, pps)

   RETURN 0
