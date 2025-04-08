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

CLASS HButtonX INHERIT HButton

   CLASS VAR winclass   INIT "BUTTON"
   DATA bClick
   DATA cNote  HIDDEN
   DATA lFlat INIT .F.
   DATA lnoWhen

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
      tcolor, bColor, bGFocus)
   METHOD Redefine( oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, ;
      cTooltip, tcolor, bColor, cCaption, bGFocus )
   METHOD Init()
   METHOD onClick()
   METHOD onGetFocus()
   METHOD onLostFocus()
   METHOD onEvent( msg, wParam, lParam )
   METHOD NoteCaption( cNote )  SETGET

ENDCLASS

METHOD HButtonX:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
      tcolor, bColor, bGFocus)

   nStyle := hb_bitor( iif( nStyle == NIL, 0, nStyle ), BS_PUSHBUTTON + BS_NOTIFY )
   ::lFlat := hb_bitand( nStyle, BS_FLAT ) != 0

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint,, cTooltip, ;
      tcolor, bColor, bGFocus)

   ::bClick := bClick
   ::bGetFocus  := bGFocus
   ::oParent:AddEvent( BN_SETFOCUS, ::id, { || ::onGetFocus() } )
   ::oParent:AddEvent( BN_KILLFOCUS, ::id, { || ::onLostFocus() } )

   IF ::id > IDCANCEL .OR. ::bClick != NIL
      IF ::id < IDABORT
         hwg_GetParentForm( Self ):AddEvent( BN_CLICKED, ::id, { || ::onClick() } )
      ENDIF
      IF hwg_GetParentForm( Self ):Classname != ::oParent:Classname  .OR. ::id > IDCANCEL
         ::oParent:AddEvent( BN_CLICKED, ::id, { || ::onClick() } )
      ENDIF
   ENDIF

   RETURN Self

METHOD HButtonX:Redefine( oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, ;
      cTooltip, tcolor, bColor, cCaption, bGFocus )

   ::super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, ;
      bSize, bPaint, cTooltip, tcolor, bColor)

   ::title   := cCaption
   ::bGetFocus  := bGFocus
   ::oParent:AddEvent( BN_SETFOCUS, ::id, { || ::onGetFocus() } )
   ::oParent:AddEvent( BN_KILLFOCUS, ::id, { || ::onLostFocus() } )
   ::bClick  := bClick
   IF ::id > IDCANCEL .OR. ::bClick != NIL
      IF ::id < IDABORT
         hwg_GetParentForm( Self ):AddEvent( BN_CLICKED, ::id, { || ::onClick() } )
      ENDIF
      IF hwg_GetParentForm( Self ):Classname != ::oParent:Classname  .OR. ::id > IDCANCEL
         ::oParent:AddEvent( BN_CLICKED, ::id, { || ::onClick() } )
      ENDIF
   ENDIF

   RETURN Self

METHOD HButtonX:Init()

   IF ! ::lInit
      IF !( hwg_GetParentForm( Self ):classname == ::oParent:classname .AND. ;
            hwg_GetParentForm( Self ):Type >= WND_DLG_RESOURCE ) .OR. ;
            ! hwg_GetParentForm( Self ):lModal  .OR. ::nHolder = 1
         ::nHolder := 1
         hwg_Setwindowobject( ::handle, Self )
         HWG_INITBUTTONPROC( ::handle )
      ENDIF
      ::Super:init()
   ENDIF

   RETURN  NIL

METHOD HButtonX:onevent( msg, wParam, lParam )

   IF msg = WM_SETFOCUS .AND. ::oParent:oParent = NIL
   ELSEIF msg = WM_KILLFOCUS
      IF hwg_GetParentForm( Self ):handle != ::oParent:Handle
         hwg_Invalidaterect( ::handle, 0 )
         hwg_Sendmessage( ::handle, BM_SETSTYLE , BS_PUSHBUTTON , 1 )
      ENDIF
   ELSEIF msg = WM_KEYDOWN
      IF ( wParam == VK_RETURN   .OR. wParam == VK_SPACE )
         hwg_Sendmessage( ::handle, WM_LBUTTONDOWN, 0, hwg_Makelparam( 1, 1 ) )
         RETURN 0
      ENDIF
      /*
      IF ! hwg_ProcKeyList( Self, wParam )
         IF wParam = VK_TAB
            hwg_GetSkip( ::oparent, ::handle,iif( hwg_IsCtrlShift( .F. , .T. ), - 1, 1 )  )
            RETURN 0
         ELSEIF wParam = VK_LEFT .OR. wParam = VK_UP
            hwg_GetSkip( ::oparent, ::handle,- 1 )
            RETURN 0
         ELSEIF wParam = VK_RIGHT .OR. wParam = VK_DOWN
            hwg_GetSkip( ::oparent, ::handle, 1 )
            RETURN 0
         ENDIF
      ENDIF
      */
   ELSEIF msg == WM_KEYUP
      IF ( wParam == VK_RETURN .OR. wParam == VK_SPACE )
         hwg_Sendmessage( ::handle, WM_LBUTTONUP, 0, hwg_Makelparam( 1, 1 ) )
         RETURN 0
      ENDIF
   ELSEIF  msg = WM_GETDLGCODE .AND. ! Empty(lParam)
      IF wParam = VK_RETURN .OR. wParam = VK_TAB
      ELSEIF hwg_Getdlgmessage( lParam ) = WM_KEYDOWN .AND. wParam != VK_ESCAPE
      ELSEIF hwg_Getdlgmessage( lParam ) = WM_CHAR .OR. wParam = VK_ESCAPE
         RETURN - 1
      ENDIF
      RETURN DLGC_WANTMESSAGE
   ENDIF

   RETURN - 1

METHOD HButtonX:onClick()

   IF ::bClick != NIL
      Eval( ::bClick, Self, ::id )
   ENDIF

   RETURN NIL

METHOD HButtonX:NoteCaption( cNote )

   IF cNote != NIL
      IF hb_bitor( ::Style, BS_COMMANDLINK ) > 0
         hwg_Sendmessage( ::Handle, BCM_SETNOTE, 0, hwg_Ansitounicode( cNote ) )
      ENDIF
      ::cNote := cNote
   ENDIF

   RETURN ::cNote

METHOD HButtonX:onGetFocus()
   LOCAL res := .T. , nSkip

   /*
   IF ! hwg_CheckFocus( Self, .F. ) .OR. ::bGetFocus = NIL
      RETURN .T.
   ENDIF
   */
   IF ::bGetFocus != NIL
      nSkip := iif( hwg_Getkeystate( VK_UP ) < 0 .OR. ( hwg_Getkeystate( VK_TAB ) < 0 .AND. hwg_Getkeystate( VK_SHIFT ) < 0 ), - 1, 1 )
      res := Eval( ::bGetFocus, ::title, Self )
      IF res != NIL .AND.  Empty(res)
         /*
         hwg_WhenSetFocus( Self, nSkip )
         */
         IF ::lflat
            hwg_Invalidaterect( ::oParent:Handle, 1 , ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight  )
         ENDIF
      ENDIF
   ENDIF

   RETURN res

METHOD HButtonX:onLostFocus()

   IF ::lflat
      hwg_Invalidaterect( ::oParent:Handle, 1 , ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight  )
   ENDIF
   ::lnoWhen := .F.
   IF ::bLostFocus != NIL .AND. hwg_Selffocus( hwg_Getparent( hwg_Getfocus() ), hwg_getparentform( Self ):Handle )
      Eval( ::bLostFocus, ::title, Self )
   ENDIF

   RETURN NIL
