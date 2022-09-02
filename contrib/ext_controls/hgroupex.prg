/*
 * $Id: hctrlex.prg 2641 2018-01-20 19:56:09Z lculik $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HStaticEx, HButtonEx, HGroupEx
 *
 * Copyright 2007 Luiz Rafael Culik Guimaraes <luiz at xharbour.com.br >
 * www - http://sites.uol.com.br/culikr/
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#translate :hBitmap       => :m_csbitmaps\[1\]
#translate :dwWidth       => :m_csbitmaps\[2\]
#translate :dwHeight      => :m_csbitmaps\[3\]
#translate :hMask         => :m_csbitmaps\[4\]
#translate :crTransparent => :m_csbitmaps\[5\]

#define TRANSPARENT 1
#define BTNST_COLOR_BK_IN     1            // Background color when mouse is INside
#define BTNST_COLOR_FG_IN     2            // Text color when mouse is INside
#define BTNST_COLOR_BK_OUT    3             // Background color when mouse is OUTside
#define BTNST_COLOR_FG_OUT    4             // Text color when mouse is OUTside
#define BTNST_COLOR_BK_FOCUS  5           // Background color when the button is focused
#define BTNST_COLOR_FG_FOCUS  6            // Text color when the button is focused
#define BTNST_MAX_COLORS      6
#define WM_SYSCOLORCHANGE               0x0015
#define BS_TYPEMASK SS_TYPEMASK
#define OFS_X 10 // distance from left/right side to beginning/end of text
#define RT_MANIFEST  24

CLASS HGroupEx INHERIT HGroup

   DATA oRGroup
   DATA oBrush
   DATA BackStyle       INIT OPAQUE
   DATA lTransparent HIDDEN

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, tcolor, bColor, lTransp, oRGroup)
   METHOD Init()
   METHOD Paint( lpDis )

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, tcolor, bColor, lTransp, oRGroup) CLASS HGroupEx

   ::oRGroup := oRGroup
   ::oBrush := iif( bColor != NIL, ::brush, NIL )
   ::lTransparent := iif( lTransp != NIL, lTransp, .F. )
   ::backStyle := iif( ( lTransp != NIL .AND. lTransp ) .OR. ::bColor != NIL , TRANSPARENT, OPAQUE )
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, tcolor, bColor)

   RETURN Self

METHOD Init() CLASS HGroupEx
   LOCAL nbs

   IF ! ::lInit
      ::Super:Init()
      IF ::oBrush != NIL .OR. ::backStyle = TRANSPARENT
         nbs := HWG_GETWINDOWSTYLE( ::handle )
         nbs := hwg_Modstyle( nbs, BS_TYPEMASK , BS_OWNERDRAW + WS_DISABLED )
         HWG_SETWINDOWSTYLE ( ::handle, nbs )
         ::bPaint   := { | o, p | o:paint( p ) }
      ENDIF
      IF ::oRGroup != NIL
         ::oRGroup:Handle := ::handle
         ::oRGroup:id := ::id
         ::oFont := ::oRGroup:oFont
         ::oRGroup:lInit := .F.
         ::oRGroup:Init()
      ELSE
         IF ::oBrush != NIL
            hwg_Setwindowpos( ::Handle, NIL, 0, 0, 0, 0, SWP_NOSIZE + SWP_NOMOVE + SWP_NOACTIVATE )
         ELSE
            hwg_Setwindowpos( ::Handle, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOSIZE + SWP_NOMOVE + SWP_NOACTIVATE + SWP_NOSENDCHANGING )
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

METHOD PAINT( lpdis ) CLASS HGroupEx
   LOCAL drawInfo := hwg_Getdrawiteminfo( lpdis )
   LOCAL DC := drawInfo[3]
   LOCAL ppnOldPen, pnFrmDark,   pnFrmLight, iUpDist
   LOCAL szText, aSize, dwStyle
   LOCAL rc  := hwg_Copyrect( { drawInfo[4], drawInfo[5], drawInfo[6] - 1, drawInfo[7] - 1 } )
   LOCAL rcText

   // determine text length
   szText := ::Title
   aSize := hwg_TxtRect( iif( Empty(szText), "A", szText ), Self )
   // distance from window top to group rect
   iUpDist := ( aSize[2] / 2 )
   dwStyle := ::Style //HWG_GETWINDOWSTYLE( ::handle ) //GetStyle();
   rcText := { 0, rc[2] + iUpDist , 0, rc[2] + iUpDist  }
   IF Empty(szText)
   ELSEIF hb_BitAnd( dwStyle, BS_CENTER ) == BS_RIGHT // right aligned
      rcText[3] := rc[3] + 2 - OFS_X
      rcText[1] := rcText[3] - aSize[1]
   ELSEIF hb_BitAnd( dwStyle, BS_CENTER ) == BS_CENTER  // text centered
      rcText[1] := ( rc[3] - rc[1]  - aSize[1]  ) / 2
      rcText[3] := rcText[1] + aSize[1]
   ELSE //((!(dwStyle & BS_CENTER)) || ((dwStyle & BS_CENTER) == BS_LEFT))// left aligned   / default
      rcText[1] := rc[1] + OFS_X
      rcText[3] := rcText[1] + aSize[1]
   ENDIF
   hwg_Setbkmode( dc, TRANSPARENT )

   IF hb_bitand( dwStyle, BS_FLAT ) != 0  // "flat" frame
      pnFrmDark  := HPen():Add( PS_SOLID, 1,  hwg_ColorRgb2N( 64, 64, 64 ) )
      pnFrmLight := HPen():Add( PS_SOLID, 1, hwg_Getsyscolor( COLOR_3DHILIGHT ) )
      ppnOldPen := hwg_Selectobject( dc, pnFrmDark:Handle )
      hwg_Moveto( dc, rcText[1] - 2, rcText[2]  )
      hwg_Lineto( dc, rc[1], rcText[2] )
      hwg_Lineto( dc, rc[1], rc[4] )
      hwg_Lineto( dc, rc[3], rc[4] )
      hwg_Lineto( dc, rc[3], rcText[4] )
      hwg_Lineto( dc, rcText[3], rcText[4] )
      hwg_Selectobject( dc, pnFrmLight:handle )
      hwg_Moveto( dc, rcText[1] - 2, rcText[2] + 1 )
      hwg_Lineto( dc, rc[1] + 1, rcText[2] + 1 )
      hwg_Lineto( dc, rc[1] + 1, rc[4] - 1 )
      hwg_Lineto( dc, rc[3] - 1, rc[4] - 1 )
      hwg_Lineto( dc, rc[3] - 1, rcText[4] + 1 )
      hwg_Lineto( dc, rcText[3], rcText[4] + 1 )
   ELSE // 3D frame
      pnFrmDark  := HPen():Add( PS_SOLID, 1, hwg_Getsyscolor( COLOR_3DSHADOW ) )
      pnFrmLight := HPen():Add( PS_SOLID, 1, hwg_Getsyscolor( COLOR_3DHILIGHT ) )
      ppnOldPen := hwg_Selectobject( dc, pnFrmDark:handle )
      hwg_Moveto( dc, rcText[1] - 2, rcText[2] )
      hwg_Lineto( dc, rc[1], rcText[2] )
      hwg_Lineto( dc, rc[1], rc[4] - 1 )
      hwg_Lineto( dc, rc[3] - 1, rc[4] - 1 )
      hwg_Lineto( dc, rc[3] - 1, rcText[4] )
      hwg_Lineto( dc, rcText[3], rcText[4] )
      hwg_Selectobject( dc, pnFrmLight:handle )
      hwg_Moveto( dc, rcText[1] - 2, rcText[2] + 1 )
      hwg_Lineto( dc, rc[1] + 1, rcText[2] + 1 )
      hwg_Lineto( dc, rc[1] + 1, rc[4] - 1 )
      hwg_Moveto( dc, rc[1], rc[4] )
      hwg_Lineto( dc, rc[3], rc[4] )
      hwg_Lineto( dc, rc[3], rcText[4] - 1 )
      hwg_Moveto( dc, rc[3] - 2, rcText[4] + 1 )
      hwg_Lineto( dc, rcText[3], rcText[4] + 1 )
   ENDIF
   // draw text (if any)
   IF !Empty(szText)
      hwg_Setbkmode( dc, TRANSPARENT )
      IF ::oBrush != NIL
         hwg_Fillrect( DC, rc[1] + 2, rc[2] + iUpDist + 2 , rc[3] - 2, rc[4] - 2 , ::brush:handle )
         IF ! ::lTransparent
            hwg_Fillrect( DC, rcText[1] - 2, rc[2] + 1 ,  rcText[3] + 1, rc[2] + iUpDist + 2 , ::brush:handle )
         ENDIF
      ENDIF
      hwg_Drawtext( dc, szText, rcText, DT_VCENTER + DT_LEFT + DT_SINGLELINE + DT_NOCLIP )
   ENDIF
   // cleanup
   hwg_Deleteobject( pnFrmLight )
   hwg_Deleteobject( pnFrmDark )
   hwg_Selectobject( dc, ppnOldPen )

   RETURN NIL
