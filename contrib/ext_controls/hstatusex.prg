/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HStaticEx, HButtonEx, HGroupEx
 *
 * Copyright 2007 Luiz Rafael Culik Guimaraes <luiz at xharbour.com.br >
 * www - http://sites.uol.com.br/culikr/
*/

#include <hbclass.ch>
#include "hwguipp.ch"
#include <common.ch>

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

CLASS HStatusEx INHERIT HControl

CLASS VAR winclass   INIT "msctls_statusbar32"

   DATA aParts
   DATA nStatusHeight   INIT 0
   DATA bDblClick
   DATA bRClick

   METHOD New(oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint, bRClick, bDblClick, nHeight)
   METHOD Activate()
   METHOD Init()
   METHOD Notify( lParam )
   METHOD Redefine( oWndParent, nId, cCaption, oFont, bInit, ;
                    bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aParts )
   METHOD SetText( cText,nPart ) INLINE  hwg_WriteStatus( ::oParent, nPart, cText )
   METHOD SetTextPanel( nPart, cText, lRedraw )
   METHOD GetTextPanel( nPart )
   METHOD SetIconPanel( nPart, cIcon, nWidth, nHeight )
   METHOD StatusHeight( nHeight )
   METHOD Resize( xIncrSize )

ENDCLASS

METHOD HStatusEx:New(oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint, bRClick, bDblClick, nHeight)

   bSize  := IIf( bSize != NIL, bSize, {|o, x, y|o:Move(0, y - ::nStatusHeight, x, ::nStatusHeight)} )
   nStyle := hb_bitor( IIf( nStyle == NIL, 0, nStyle ), ;
                        WS_CHILD + WS_VISIBLE + WS_OVERLAPPED + WS_CLIPSIBLINGS )
   ::Super:New(oWndParent, nId, nStyle, 0, 0, 0, 0, oFont, bInit, bSize, bPaint)

   ::nStatusHeight := IIF( nHeight = NIL, ::nStatusHeight, nHeight )
   ::aParts    := aParts
   ::bDblClick := bDblClick
   ::bRClick   := bRClick

   ::Activate()

   RETURN Self

METHOD HStatusEx:Activate()

   IF ! Empty(::oParent:handle)
      ::handle := hwg_CreateStatusWindow( ::oParent:handle, ::id )
      ::StatusHeight( ::nStatusHeight )
      ::Init()
   ENDIF
   RETURN NIL

METHOD HStatusEx:Init()
   IF ! ::lInit
      IF ! Empty(::aParts)
         hwg_InitStatus( ::oParent:handle, ::handle, Len( ::aParts ), ::aParts )
      ENDIF
      ::Super:Init()
   ENDIF
   RETURN  NIL

METHOD HStatusEx:Redefine( oWndParent, nId, cCaption, oFont, bInit, ;
                 bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aParts )

   HB_SYMBOL_UNUSED(cCaption)
   HB_SYMBOL_UNUSED(lTransp)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()
   ::style   := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0
   ::aParts := aParts
   RETURN Self

METHOD HStatusEx:Notify( lParam )

LOCAL nCode := hwg_GetNotifyCode( lParam )
LOCAL nParts := hwg_GetNotifySBParts( lParam ) - 1

#define NM_DBLCLK               (NM_FIRST-3)
#define NM_RCLICK               (NM_FIRST-5)    // uses NMCLICK struct
#define NM_RDBLCLK              (NM_FIRST-6)

   DO CASE
      CASE nCode == NM_CLICK

      CASE nCode == NM_DBLCLK
          IF ::bdblClick != NIL
              Eval(::bdblClick, Self, nParts)
          ENDIF
      CASE nCode == NM_RCLICK
         IF ::bRClick != NIL
             Eval(::bRClick, Self, nParts)
         ENDIF
   ENDCASE
   RETURN NIL

METHOD HStatusEx:StatusHeight( nHeight  )
   LOCAL aCoors

   IF nHeight != NIL
      aCoors := hwg_GetWindowRect( ::handle )
      IF nHeight != 0
         IF  ::lInit .AND. __ObjHasMsg( ::oParent, "AOFFSET" )
            ::oParent:aOffset[4] -= ( aCoors[4] - aCoors[2] )
         ENDIF
         hwg_SendMessage( ::handle,;           // (HWND) handle to destination control
                SB_SETMINHEIGHT, nHeight, 0 )      // (UINT) message ID  // = (WPARAM)(int) minHeight;
         hwg_SendMessage( ::handle, WM_SIZE, 0, 0 )
         aCoors := hwg_GetWindowRect( ::handle )
      ENDIF
      ::nStatusHeight := ( aCoors[4] - aCoors[2] ) - 1
      IF __ObjHasMsg( ::oParent, "AOFFSET" )
         ::oParent:aOffset[4] += ( aCoors[4] - aCoors[2]  )
      ENDIF
   ENDIF
   RETURN ::nStatusHeight

METHOD HStatusEx:GetTextPanel( nPart )
   LOCAL ntxtLen, cText := ""

   ntxtLen := hwg_SendMessage( ::handle, SB_GETTEXTLENGTH, nPart - 1, 0 )
   cText := Replicate(Chr(0), ntxtLen)
   hwg_SendMessage( ::handle, SB_GETTEXT, nPart - 1, @cText )
   RETURN cText

METHOD HStatusEx:SetTextPanel( nPart, cText, lRedraw )
   hwg_SendMessage( ::handle, SB_SETTEXT, nPart - 1, cText )
   IF lRedraw != NIL .AND. lRedraw
      hwg_RedrawWindow( ::handle, RDW_ERASE + RDW_INVALIDATE )
   ENDIF

   RETURN NIL
   
METHOD HStatusEx:SetIconPanel( nPart, cIcon, nWidth, nHeight )
   Local oIcon

   DEFAULT nWidth := 16
   DEFAULT nHeight := 16
   DEFAULT cIcon := ""

   IF HB_IsNumeric( cIcon ) .OR. At(".", cIcon) = 0
      oIcon := HIcon():addResource( cIcon, nWidth, nHeight )
   ELSE
      oIcon := HIcon():addFile( cIcon, nWidth, nHeight )
    ENDIF
    IF ! EMPTY(oIcon)
      hwg_SendMessage( ::handle, SB_SETICON, nPart - 1, oIcon:handle )
   ENDIF

   RETURN NIL

METHOD HStatusEx:Resize( xIncrSize )
   LOCAL i
   
   IF ! Empty(::aParts)
      FOR i := 1 TO LEN( ::aParts )
         ::aParts[i] := ROUND( ::aParts[i] * xIncrSize, 0 )
      NEXT   
      hwg_InitStatus( ::oParent:handle, ::handle, Len( ::aParts ), ::aParts )
   ENDIF
   RETURN NIL
