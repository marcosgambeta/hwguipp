//
// HWGUI - Harbour Win32 GUI library source code:
// HStaticLink class
//

#include "gtk.ch"
#include "hbclass.ch"
#include "common.ch"
#include "hwgui.ch"

#define LBL_INIT           0
#define LBL_NORMAL         1
#define LBL_VISITED        2
#define LBL_MOUSEOVER      3

CLASS HStaticLink FROM HSTATIC

   CLASS VAR winclass INIT "STATIC"

   DATA state
   DATA m_bFireChild INIT .F.
   DATA m_hHyperCursor
   DATA m_bMouseOver INIT .F.
   DATA m_bVisited INIT .F.
   DATA m_oTextFont
   DATA m_csUrl
   DATA dc
   DATA dwFlags INIT 0
   DATA m_sHoverColor
   DATA m_sLinkColor
   DATA m_sVisitedColor

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, cLink, vColor, lColor, hColor)
   METHOD Activate()
   METHOD Init()
   METHOD onEvent( msg, wParam, lParam )
   METHOD GoToLinkUrl( csLink )
   METHOD SetLinkUrl( csUrl )
   METHOD GetLinkUrl()
   METHOD SetVisitedColor( sVisitedColor )
   METHOD SetHoverColor( cHoverColor )
   METHOD SetFireChild( lFlag ) INLINE ::m_bFireChild := lFlag
   METHOD OnClicked()
   METHOD SetLinkColor( sLinkColor )
   METHOD Paint()
   METHOD OnMouseMove( wParam )

ENDCLASS

METHOD HStaticLink:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, cLink, vColor, lColor, hColor)

   LOCAL oPrevFont
   LOCAL n

   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp)

   DEFAULT vColor TO hwg_ColorRgb2N( 5, 34, 143 )
   DEFAULT lColor TO hwg_ColorRgb2N( 0, 0, 255 )
   DEFAULT hColor TO hwg_ColorRgb2N( 255, 0, 0 )
   ::m_csUrl := cLink
   ::m_sHoverColor := hColor
   ::m_sLinkColor := lColor
   ::m_sVisitedColor := vColor
   ::m_hHyperCursor := hwg_Loadcursor( GDK_HAND2 )

   ::state := LBL_INIT
   ::title := iif(cCaption == NIL, "", cCaption)

   IF ::oFont == NIL
      IF ::oParent:oFont != NIL
         ::oFont := HFont():Add(::oParent:oFont:name, ::oParent:oFont:width, ::oParent:oFont:height, ::oParent:oFont:weight, ::oParent:oFont:charset, ::oParent:oFont:italic, 1, ::oParent:oFont:StrikeOut, NIL, .T.)
      ELSE
         ::oFont := HFont():Add( "Serif", 0, 12,,,,,,,.T. )
      ENDIF
   ELSE
      IF ::oFont:Underline  == 0
         oPrevFont := ::oFont
         ::oFont:Release()
         ::oFont := HFont():Add(oPrevFont:name, oPrevFont:width, oPrevFont:height, oPrevFont:weight, oPrevFont:charset, oPrevFont:italic, 1, oPrevFont:StrikeOut, NIL, .T.)
      ENDIF
   ENDIF

   IF (n := hb_bitand(::style, SS_TYPEMASK)) == SS_RIGHT
      ::dwFlags := hb_bitor( DT_RIGHT, DT_WORDBREAK )
   ELSEIF n == SS_CENTER
      ::dwFlags := hb_bitor( SS_CENTER, DT_WORDBREAK )
   ELSEIF n == SS_LEFTNOWORDWRAP
      ::dwFlags := DT_LEFT
   ELSE
      ::dwFlags := hb_bitor( DT_LEFT, DT_WORDBREAK )
   ENDIF

   ::Activate()

   RETURN Self


METHOD HStaticLink:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createownbtn(::oParent:handle, ::id, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

RETURN NIL

METHOD HStaticLink:Init()

   IF !::lInit
      hwg_Setwindowobject(::handle, Self)
   ENDIF

   RETURN NIL

METHOD HStaticLink:onEvent( msg, wParam, lParam )

   HB_SYMBOL_UNUSED(lParam)

   IF msg == WM_PAINT
      ::Paint()
   ELSEIF msg == WM_ERASEBKGND
      RETURN 1
   ELSEIF msg == WM_MOUSEMOVE
      hwg_SetCursor(::m_hHyperCursor, ::handle)
      ::OnMouseMove( wParam )
   ELSEIF msg == WM_LBUTTONDOWN
      hwg_SetCursor(::m_hHyperCursor, ::handle)
      ::OnClicked()
   ENDIF

   RETURN - 1

METHOD HStaticLink:GoToLinkUrl( csLink )

   RETURN hwg_Shellexecute( csLink )

METHOD HStaticLink:SetLinkUrl( csUrl )

   ::m_csUrl := csUrl

   RETURN NIL

METHOD HStaticLink:GetLinkUrl()

   RETURN ::m_csUrl

METHOD HStaticLink:SetVisitedColor( sVisitedColor )

   ::m_sVisitedColor := sVisitedColor

   RETURN NIL

METHOD HStaticLink:SetHoverColor( cHoverColor )

   ::m_sHoverColor := cHoverColor

   RETURN NIL

METHOD HStaticLink:OnClicked()

   // Variables not used
   // LOCAL nCtrlID

   ::GoToLinkUrl(::m_csUrl)

   ::m_bVisited := .T.

   ::state := LBL_NORMAL
   hwg_Invalidaterect(::handle, 0)
   hwg_Setfocus(::handle)

   RETURN NIL

METHOD HStaticLink:SetLinkColor( sLinkColor )

   ::m_sLinkColor := sLinkColor

   RETURN NIL

METHOD HStaticLink:OnMouseMove( wParam )

   LOCAL lEnter := ( hb_bitand( wParam,16 ) > 0 )

   IF ::state != LBL_INIT

      IF !lEnter

         ::state := LBL_NORMAL
         hwg_Invalidaterect(::handle, 0)
      ELSEIF ::state == LBL_NORMAL

         ::state := LBL_MOUSEOVER
         hwg_Invalidaterect(::handle, 0)
      ENDIF

   ENDIF

   RETURN 0

METHOD HStaticLink:Paint()

   LOCAL pps
   LOCAL hDC
   LOCAL aCoors

   IF ::state == LBL_INIT
      ::State := LBL_NORMAL
   ENDIF

   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint(::handle, pps)
   aCoors := hwg_Getclientrect(::handle)

   hwg_Selectobject(hDC, ::oFont:handle)
   hwg_Settextcolor(hDC, Iif(::state == LBL_NORMAL, Iif(::m_bVisited, ::m_sVisitedColor, ::m_sLinkColor), ::m_sHoverColor))

   hwg_Drawtext(hDC, ::Title, aCoors[1], aCoors[2], aCoors[3], aCoors[4], ::dwFlags)

   hwg_Endpaint(::handle, pps)

   RETURN 0
