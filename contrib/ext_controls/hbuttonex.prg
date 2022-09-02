/*
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

CLASS HButtonEX INHERIT HButtonX, HThemed

   DATA hBitmap
   DATA hIcon
   DATA m_dcBk
   DATA m_bFirstTime INIT .T.
   DATA m_crColors INIT Array(6)
   DATA m_crBrush INIT Array(6)
   DATA Caption
   DATA state
   DATA m_bIsDefault INIT .F.
   DATA m_nTypeStyle  init 0
   DATA m_bSent, m_bLButtonDown, m_bIsToggle
   DATA m_rectButton           // button rect in parent window coordinates
   DATA m_dcParent init hdc():new()
   DATA m_bmpParent
   DATA m_pOldParentBitmap
   DATA m_csbitmaps init { , , , , }
   DATA m_bToggled INIT .F.
   DATA PictureMargin INIT 0
   DATA m_bDrawTransparent INIT .F.
   DATA iStyle
   DATA m_bmpBk, m_pbmpOldBk
   DATA bMouseOverButton INIT .F.
   DATA lnoThemes

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
      tcolor, bColor, hBitmap, iStyle, hicon, Transp, bGFocus, nPictureMargin, lnoThemes, bOther)
   METHOD Paint( lpDis )
   METHOD SetBitmap( hBitMap )
   METHOD SetIcon( hIcon )
   METHOD Init()
   METHOD onevent( msg, wParam, lParam )
   METHOD CancelHover()
   METHOD END()
   METHOD Redefine( oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, ;
      cTooltip, tcolor, bColor, cCaption, hBitmap, iStyle, hIcon, bGFocus, nPictureMargin )
   METHOD PaintBk( hdc )
   METHOD Setcolor( tcolor, bcolor ) INLINE ::SetDefaultColor( tcolor, bcolor ) //, ::SetDefaultColor( .T. )
   METHOD SetDefaultColor( tColor, bColor, lPaint )
   METHOD SetColorEx( nIndex, nColor, lPaint )
   METHOD SetText( c ) INLINE ::title := c,  ;
      hwg_Redrawwindow( ::Handle, RDW_NOERASE + RDW_INVALIDATE ), ;
      iif( ::oParent != NIL .AND. hwg_Iswindowvisible( ::Handle ) , ;
      hwg_Invalidaterect( ::oParent:Handle, 1 , ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight  ), ), ;
      hwg_Setwindowtext( ::handle, ::title )
   //   METHOD SaveParentBackground()

END CLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
      tcolor, bColor, hBitmap, iStyle, hicon, Transp, bGFocus, nPictureMargin, lnoThemes, bOther) CLASS HButtonEx

   DEFAULT iStyle TO ST_ALIGN_HORIZ
   DEFAULT Transp TO .T.
   DEFAULT nPictureMargin TO 0
   DEFAULT lnoThemes  TO .F.
   ::m_bLButtonDown := .F.
   ::m_bSent := .F.
   ::m_bLButtonDown := .F.
   ::m_bIsToggle := .F.

   cCaption := iif( cCaption = NIL, "", cCaption )
   ::Caption := cCaption
   ::iStyle              := iStyle
   ::hBitmap             := iif( Empty(hBitmap), NIL, hBitmap )
   ::hicon               := iif( Empty(hicon), NIL, hIcon )
   ::m_bDrawTransparent  := Transp
   ::PictureMargin       := nPictureMargin
   ::lnoThemes           := lnoThemes
   ::bOther := bOther
   bPaint := { | o, p | o:paint( p ) }

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
      tcolor, bColor, bGFocus)

   RETURN Self

METHOD Redefine( oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, ;
      cTooltip, tcolor, bColor, cCaption, hBitmap, iStyle, hIcon, bGFocus, nPictureMargin ,Transp,lnoThemes) CLASS HButtonEx

   DEFAULT iStyle TO ST_ALIGN_HORIZ
   DEFAULT nPictureMargin TO 0
   DEFAULT Transp TO .T.
   DEFAULT lnoThemes  TO .F.

   bPaint := { | o, p | o:paint( p ) }
   ::Super:Redefine( oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, ;
      cTooltip, tcolor, bColor, cCaption,  bGFocus  )
   ::bPaint  := bPaint	  
   ::m_bLButtonDown := .F.
   ::m_bIsToggle := .F.
   ::m_bLButtonDown := .F.
   ::m_bSent := .F.
  
   ::title := cCaption
   ::Caption := cCaption
   ::iStyle  := iStyle 
   ::hBitmap := hBitmap
   ::hIcon   := hIcon
   ::m_crColors[BTNST_COLOR_BK_IN]    := hwg_Getsyscolor( COLOR_BTNFACE )
   ::m_crColors[BTNST_COLOR_FG_IN]    := hwg_Getsyscolor( COLOR_BTNTEXT )
   ::m_crColors[BTNST_COLOR_BK_OUT]   := hwg_Getsyscolor( COLOR_BTNFACE )
   ::m_crColors[BTNST_COLOR_FG_OUT]   := hwg_Getsyscolor( COLOR_BTNTEXT )
   ::m_crColors[BTNST_COLOR_BK_FOCUS] := hwg_Getsyscolor( COLOR_BTNFACE )
   ::m_crColors[BTNST_COLOR_FG_FOCUS] := hwg_Getsyscolor( COLOR_BTNTEXT )
   ::PictureMargin                      := nPictureMargin
   ::m_bDrawTransparent  := Transp   
   ::lnoThemes           := lnoThemes
   
                  
   ::title := cCaption
   ::Caption := cCaption

   RETURN Self

METHOD SetBitmap( hBitMap ) CLASS HButtonEX

   DEFAULT hBitmap TO ::hBitmap
   IF !Empty(hBitmap)
      ::hBitmap := hBitmap
      hwg_Sendmessage( ::handle, BM_SETIMAGE, IMAGE_BITMAP, ::hBitmap )
      hwg_Redrawwindow( ::Handle, RDW_NOERASE + RDW_INVALIDATE + RDW_INTERNALPAINT )
   ENDIF

   RETURN Self

METHOD SetIcon( hIcon ) CLASS HButtonEX

   DEFAULT hIcon TO ::hIcon
   IF !Empty(hIcon)
      ::hIcon := hIcon
      hwg_Sendmessage( ::handle, BM_SETIMAGE, IMAGE_ICON, ::hIcon )
      hwg_Redrawwindow( ::Handle, RDW_NOERASE + RDW_INVALIDATE + RDW_INTERNALPAINT )
   ENDIF

   RETURN Self

METHOD END() CLASS HButtonEX

   ::Super:END()

   RETURN Self

METHOD INIT() CLASS HButtonEx
   LOCAL nbs
altd()
   IF ! ::lInit
      ::nHolder := 1
      IF !Empty(::handle)
         nbs := HWG_GETWINDOWSTYLE( ::handle )
         ::m_nTypeStyle :=  hwg_Getthestyle( nbs , BS_TYPEMASK )

         // Check if this is a checkbox
         // Set initial default state flag
         IF ( ::m_nTypeStyle == BS_DEFPUSHBUTTON )
            // Set default state for a default button
            ::m_bIsDefault := .T.

            // Adjust style for default button
            ::m_nTypeStyle := BS_PUSHBUTTON
         ENDIF
         nbs := hwg_Modstyle( nbs, BS_TYPEMASK  , BS_OWNERDRAW )
         HWG_SETWINDOWSTYLE ( ::handle, nbs )
      ENDIF

      ::Super:init()
      ::SetBitmap()
   ENDIF

   RETURN NIL

METHOD onEvent( msg, wParam, lParam ) CLASS HBUTTONEx

   LOCAL pt := { , }, rectButton, acoor
   LOCAL pos, nID, oParent, nEval

   wParam := hwg_PtrToUlong( wParam )
   IF msg == WM_THEMECHANGED
      IF ::Themed
         IF !Empty(::htheme)
            hwg_closethemedata( ::htheme )
            ::hTheme := NIL
         ENDIF
         ::Themed := .F.
      ENDIF
      ::m_bFirstTime := .T.
      hwg_Redrawwindow( ::handle, RDW_ERASE + RDW_INVALIDATE )
      RETURN 0
   ELSEIF msg == WM_ERASEBKGND
      RETURN 0
   ELSEIF msg == BM_SETSTYLE
      RETURN hwg_Buttonexonsetstyle( wParam, lParam, ::handle, @::m_bIsDefault )
   ELSEIF msg == WM_MOUSEMOVE
      IF wParam = MK_LBUTTON
         pt[1] := hwg_Loword( lParam )
         pt[2] := hwg_Hiword( lParam )
         acoor := hwg_Clienttoscreen( ::handle, pt[1], pt[2] )
         rectButton := hwg_Getwindowrect( ::handle )
         IF ( ! hwg_Ptinrect( rectButton, acoor ) )
            hwg_Sendmessage( ::handle, BM_SETSTATE, ::m_bToggled, 0 )
            ::bMouseOverButton := .F.
            RETURN 0
         ENDIF
      ENDIF
      IF ( ! ::bMouseOverButton )
         ::bMouseOverButton := .T.
         hwg_Invalidaterect( ::handle, .F. )
         hwg_Trackmousevent( ::handle )
      ENDIF
      RETURN 0
   ELSEIF msg == WM_MOUSELEAVE
      ::CancelHover()
      RETURN 0
   ENDIF
   IF ::bOther != NIL
      IF ( nEval := Eval( ::bOther, Self, msg, wParam, lParam ) ) != - 1 .AND. nEval != NIL
         RETURN 0
      ENDIF
   ENDIF
   IF msg == WM_KEYDOWN
      IF hwg_CheckBit( hwg_Ptrtoulong( lParam ), 30 )  // the key was down before ?
         RETURN 0
      ENDIF
      IF ( ( wParam == VK_SPACE ) .OR. ( wParam == VK_RETURN ) )
         hwg_Sendmessage( ::handle, WM_LBUTTONDOWN, 0, hwg_Makelparam( 1, 1 ) )
         RETURN 0
      ENDIF
      IF wParam == VK_LEFT .OR. wParam == VK_UP
         hwg_GetSkip( ::oParent, ::handle, - 1 )
         RETURN 0
      ELSEIF wParam == VK_RIGHT .OR. wParam == VK_DOWN
         hwg_GetSkip( ::oParent, ::handle, 1 )
         RETURN 0
      ELSEIF  wParam = VK_TAB
         hwg_GetSkip( ::oparent, ::handle, iif( hwg_IsCtrlShift( .F. , .T. ), - 1, 1 )  )
      ENDIF
      /*
      hwg_ProcKeyList( Self, wParam )
      */
   ELSEIF msg == WM_SYSKEYUP .OR. ( msg == WM_KEYUP .AND. ;
         ASCAN( { VK_SPACE, VK_RETURN, VK_ESCAPE }, wParam ) = 0 )
      IF hwg_Checkbit( lParam, 23 ) .AND. ( wParam > 95 .AND. wParam < 106 )
         wParam -= 48
      ENDIF
      IF ! Empty(::title) .AND. ( pos := At("&", ::title) ) > 0 .AND. wParam == Asc( Upper(SubStr(::title, ++pos, 1)) )
         IF ValType( ::bClick ) == "B" .OR. ::id < 3
            hwg_Sendmessage( ::oParent:handle, WM_COMMAND, hwg_Makewparam( ::id, BN_CLICKED ), ::handle )
         ENDIF
      ELSEIF ( nID := Ascan( ::oparent:acontrols, { | o | iif( ValType( o:title ) = "C", ( pos := At("&", o:title) ) > 0 .AND. ;
            wParam == Asc( Upper(SubStr(o:title, ++pos, 1)) ), ) } ) ) > 0
         IF __ObjHasMsg( ::oParent:aControls[nID], "BCLICK" ) .AND. ;
               ValType( ::oParent:aControls[nID]:bClick ) == "B" .OR. ::oParent:aControls[nID]:id < 3
            hwg_Sendmessage( ::oParent:handle, WM_COMMAND, hwg_Makewparam( ::oParent:aControls[nID]:id, BN_CLICKED ), ::oParent:aControls[nID]:handle )
         ENDIF
      ENDIF
      IF msg != WM_SYSKEYUP
         RETURN 0
      ENDIF
   ELSEIF msg == WM_KEYUP
      IF ( wParam == VK_SPACE .OR. wParam == VK_RETURN  )
         ::bMouseOverButton := .T.
         hwg_Sendmessage( ::handle, WM_LBUTTONUP, 0, hwg_Makelparam( 1, 1 ) )
         ::bMouseOverButton := .F.
         RETURN 0
      ENDIF
   ELSEIF msg == WM_LBUTTONUP
      ::m_bLButtonDown := .F.
      IF ( ::m_bSent )
         hwg_Sendmessage( ::handle, BM_SETSTATE, 0, 0 )
         ::m_bSent := .F.
      ENDIF
      IF ::m_bIsToggle
         pt[1] := hwg_Loword( lParam )
         pt[2] := hwg_Hiword( lParam )
         acoor := hwg_Clienttoscreen( ::handle, pt[1], pt[2] )
         rectButton := hwg_Getwindowrect( ::handle )
         IF ( ! hwg_Ptinrect( rectButton, acoor ) )
            ::m_bToggled := ! ::m_bToggled
            hwg_Invalidaterect( ::handle, 0 )
            hwg_Sendmessage( ::handle, BM_SETSTATE, 0, 0 )
            ::m_bLButtonDown := .T.
         ENDIF
      ENDIF
      IF ( ! ::bMouseOverButton )
         hwg_Setfocus(0)
         ::Setfocus()
         RETURN 0
      ENDIF
      RETURN - 1
   ELSEIF msg == WM_LBUTTONDOWN
      ::m_bLButtonDown := .T.
      IF ( ::m_bIsToggle )
         ::m_bToggled := ! ::m_bToggled
         hwg_Invalidaterect( ::handle, 0 )
      ENDIF
      RETURN - 1
   ELSEIF msg == WM_LBUTTONDBLCLK
      IF ( ::m_bIsToggle )
         // for toggle buttons, treat doubleclick as singleclick
         hwg_Sendmessage( ::handle, BM_SETSTATE, ::m_bToggled, 0 )
      ELSE
         hwg_Sendmessage( ::handle, BM_SETSTATE, 1, 0 )
         ::m_bSent := TRUE
      ENDIF
      RETURN 0
   ELSEIF msg == WM_GETDLGCODE
      IF wParam = VK_ESCAPE .AND. ( hwg_Getdlgmessage( lParam ) = WM_KEYDOWN .OR. hwg_Getdlgmessage( lParam ) = WM_KEYUP )
         oParent := hwg_GetParentForm( Self )
         /*
         IF ! hwg_ProcKeyList( Self, wParam )  .AND. ( oParent:Type < WND_DLG_RESOURCE .OR. ! oParent:lModal )
            hwg_Sendmessage( oParent:handle, WM_COMMAND, hwg_Makewparam( IDCANCEL, 0 ), ::handle )
         ELSE
         */
         IF oParent:FindControl( IDCANCEL ) != NIL .AND. ! oParent:FindControl( IDCANCEL ):Enabled .AND. oParent:lExitOnEsc
            hwg_Sendmessage( oParent:handle, WM_COMMAND, hwg_Makewparam( IDCANCEL, 0 ), ::handle )
            RETURN 0
         ENDIF
      ENDIF
      RETURN iif( wParam = VK_ESCAPE, - 1, hwg_Buttongetdlgcode( lParam ) )
   ELSEIF msg == WM_SYSCOLORCHANGE
      ::SetDefaultColors()
   ELSEIF msg == WM_CHAR
      IF wParam == VK_RETURN .OR. wParam == VK_SPACE
         IF ( ::m_bIsToggle )
            ::m_bToggled := ! ::m_bToggled
            hwg_Invalidaterect( ::handle, 0 )
         ELSE
            hwg_Sendmessage( ::handle, BM_SETSTATE, 1, 0 )
            //::m_bSent := .t.
         ENDIF
         // remove because repet click  2 times
         //hwg_Sendmessage( ::oParent:handle, WM_COMMAND, hwg_Makewparam( ::id, BN_CLICKED ), ::handle )
      ELSEIF wParam == VK_ESCAPE
         hwg_Sendmessage( ::oParent:handle, WM_COMMAND, hwg_Makewparam( IDCANCEL, BN_CLICKED ), ::handle )
      ENDIF
      RETURN 0
   ENDIF

   RETURN - 1

METHOD CancelHover() CLASS HBUTTONEx

   IF ( ::bMouseOverButton ) .AND. ::id != IDOK //NANDO
      ::bMouseOverButton := .F.
      IF !::lflat
         hwg_Invalidaterect( ::handle, .F. )
      ELSE
         hwg_Invalidaterect( ::oParent:Handle, 1 , ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight  )
      ENDIF
   ENDIF

   RETURN NIL

METHOD SetDefaultColor( tColor, bColor, lPaint ) CLASS HBUTTONEx

   DEFAULT lPaint TO .F.

   IF !Empty(tColor)
      ::tColor := tColor
   ENDIF
   IF !Empty(bColor)
      ::bColor := bColor
      IF ::brush != NIL
         ::brush:Release()
      ENDIF
      ::brush := HBrush():Add( bColor )
   ENDIF
   ::m_crColors[BTNST_COLOR_BK_IN]    := iif( ::bColor = NIL, hwg_Getsyscolor( COLOR_BTNFACE ), ::bColor )
   ::m_crColors[BTNST_COLOR_FG_IN]    := iif( ::tColor = NIL, hwg_Getsyscolor( COLOR_BTNTEXT ), ::tColor )
   ::m_crColors[BTNST_COLOR_BK_OUT]   := iif( ::bColor = NIL, hwg_Getsyscolor( COLOR_BTNFACE ), ::bColor )
   ::m_crColors[BTNST_COLOR_FG_OUT]   := iif( ::tColor = NIL, hwg_Getsyscolor( COLOR_BTNTEXT ), ::tColor )
   ::m_crColors[BTNST_COLOR_BK_FOCUS] := iif( ::bColor = NIL, hwg_Getsyscolor( COLOR_BTNFACE ), ::bColor )
   ::m_crColors[BTNST_COLOR_FG_FOCUS] := iif( ::tColor = NIL, hwg_Getsyscolor( COLOR_BTNTEXT ), ::tColor )
   //
   ::m_crBrush[BTNST_COLOR_BK_IN] := HBrush():Add( ::m_crColors[BTNST_COLOR_BK_IN] )
   ::m_crBrush[BTNST_COLOR_BK_OUT] := HBrush():Add( ::m_crColors[BTNST_COLOR_BK_OUT] )
   ::m_crBrush[BTNST_COLOR_BK_FOCUS] := HBrush():Add( ::m_crColors[BTNST_COLOR_BK_FOCUS] )
   IF lPaint
      hwg_Invalidaterect( ::handle, .F. )
   ENDIF

   RETURN Self

METHOD SetColorEx( nIndex, nColor, lPaint ) CLASS HBUTTONEx

   DEFAULT lPaint TO .F.
   IF nIndex > BTNST_MAX_COLORS
      RETURN - 1
   ENDIF
   ::m_crColors[nIndex]    := nColor
   IF lPaint
      hwg_Invalidaterect( ::handle, .F. )
   ENDIF

   RETURN 0

METHOD Paint( lpDis ) CLASS HBUTTONEx
   LOCAL drawInfo := hwg_Getdrawiteminfo( lpDis )
   LOCAL dc := drawInfo[3]
   LOCAL bIsPressed     := hb_bitand( drawInfo[9], ODS_SELECTED ) != 0
   LOCAL bIsFocused     := hb_bitand( drawInfo[9], ODS_FOCUS ) != 0
   LOCAL bIsDisabled    := hb_bitand( drawInfo[9], ODS_DISABLED ) != 0
   LOCAL bDrawFocusRect := ! hb_bitand( drawInfo[9], ODS_NOFOCUSRECT ) != 0
   LOCAL focusRect
   LOCAL captionRect
   LOCAL centerRect
   LOCAL bHasTitle
   LOCAL itemRect := hwg_Copyrect( { drawInfo[4], drawInfo[5], drawInfo[6], drawInfo[7] } )
   LOCAL state
   LOCAL crColor
   LOCAL brBackground
   LOCAL br
   LOCAL brBtnShadow
   LOCAL uState
   LOCAL captionRectHeight
   LOCAL centerRectHeight

   LOCAL uAlign, uStyleTmp
   LOCAL aTxtSize := iif( ! Empty(::caption), hwg_TxtRect( ::caption, Self ), { 0, 0 } )
   LOCAL aBmpSize := iif( ! Empty(::hbitmap), hwg_Getbitmapsize( ::hbitmap ), { 0, 0 } )
   LOCAL itemRectOld, saveCaptionRect, bmpRect, itemRect1, captionRect1, fillRect
   LOCAL lMultiLine, nHeight := 0

   IF ( ::m_bFirstTime )
      ::m_bFirstTime := .F.
      IF ( hwg_Isthemedload() )
         IF !Empty(::hTheme)
            hwg_closethemedata( ::htheme )
         ENDIF
         ::hTheme := NIL
         IF ::WindowsManifest
            ::hTheme := hwg_openthemedata( ::handle, "BUTTON" )
         ENDIF
      ENDIF
   ENDIF
   IF ! Empty(::hTheme) .AND. !::lnoThemes
      ::Themed := .T.
   ENDIF
   hwg_Setbkmode( dc, TRANSPARENT )
   IF ( ::m_bDrawTransparent )
      // ::PaintBk(DC)
   ENDIF

   // Prepare draw... paint button background
   IF ::Themed
      IF bIsDisabled
         state :=  PBS_DISABLED
      ELSE
         state := iif( bIsPressed, PBS_PRESSED, PBS_NORMAL )
      ENDIF
      IF state == PBS_NORMAL
         IF bIsFocused
            state := PBS_DEFAULTED
         ENDIF
         IF ::bMouseOverButton .OR. ::id = IDOK
            state := PBS_HOT
         ENDIF
      ENDIF
      IF ! ::lFlat
         hwg_drawthemebackground( ::hTheme, dc, BP_PUSHBUTTON, state, itemRect, NIL )
      ELSEIF bIsDisabled
         hwg_Fillrect( dc, itemRect[1] + 1, itemRect[2] + 1, itemRect[3] - 1, itemRect[4] - 1, hwg_Getsyscolorbrush( hwg_Getsyscolor( COLOR_BTNFACE ) ) )
      ELSEIF ::bMouseOverButton .OR. bIsFocused
         hwg_drawthemebackground( ::hTheme, dc, BP_PUSHBUTTON  , state, itemRect, NIL ) // + PBS_DEFAULTED
      ENDIF
   ELSE
      IF bIsFocused .OR. ::id = IDOK
         br := HBRUSH():Add( hwg_ColorRgb2N( 1, 1, 1 ) )
         hwg_Framerect( dc, itemRect, br:handle )
         hwg_Inflaterect( @itemRect, - 1, - 1 )
      ENDIF
      crColor := hwg_Getsyscolor( COLOR_BTNFACE )
      brBackground := HBRUSH():Add( crColor )
      hwg_Fillrect( dc, itemRect, brBackground:handle )
      IF ( bIsPressed )
         brBtnShadow := HBRUSH():Add( hwg_Getsyscolor( COLOR_BTNSHADOW ) )
         hwg_Framerect( dc, itemRect, brBtnShadow:handle )
      ELSE
         IF ! ::lFlat .OR. ::bMouseOverButton
            uState := hb_bitor( ;
               hb_bitor( DFCS_BUTTONPUSH, ;
               iif( ::bMouseOverButton, DFCS_HOT, 0 ) ), ;
               iif( bIsPressed, DFCS_PUSHED, 0 ) )
            hwg_Drawframecontrol( dc, itemRect, DFC_BUTTON, uState )
         ELSEIF bIsFocused
            uState := hb_bitor( ;
               hb_bitor( DFCS_BUTTONPUSH + DFCS_MONO , ; // DFCS_FLAT , ;
            iif( ::bMouseOverButton, DFCS_HOT, 0 ) ), ;
               iif( bIsPressed, DFCS_PUSHED, 0 ) )
            hwg_Drawframecontrol( dc, itemRect, DFC_BUTTON, uState )
         ENDIF
      ENDIF
   ENDIF

   uAlign := 0 //DT_LEFT
   IF !Empty(::hbitmap) .OR. !Empty(::hIcon)
      uAlign := DT_VCENTER
   ENDIF

   IF uAlign = DT_VCENTER
      uAlign := iif( hb_bitand( ::Style, BS_TOP ) != 0, DT_TOP, DT_VCENTER )
      uAlign += iif( hb_bitand( ::Style, BS_BOTTOM ) != 0, DT_BOTTOM - DT_VCENTER , 0 )
      uAlign += iif( hb_bitand( ::Style, BS_LEFT ) != 0, DT_LEFT, DT_CENTER )
      uAlign += iif( hb_bitand( ::Style, BS_RIGHT ) != 0, DT_RIGHT - DT_CENTER, 0 )
   ELSE
      uAlign := iif( uAlign = 0, DT_CENTER + DT_VCENTER, uAlign )
   ENDIF

   uStyleTmp := HWG_GETWINDOWSTYLE( ::handle )
   itemRectOld := AClone( itemRect )
   IF hb_BitAnd( uStyleTmp, BS_MULTILINE ) != 0 .AND. !Empty(::caption) .AND. ;
         Int( aTxtSize[2] ) !=  Int( hwg_Drawtext( dc, ::caption, itemRect[1], itemRect[2],;
         itemRect[3] - iif( ::iStyle = ST_ALIGN_VERT, 0, aBmpSize[1] + 8 ), ;
         itemRect[4], DT_CALCRECT + uAlign + DT_WORDBREAK, itemRectOld ) )
      // *-INT( aTxtSize[2] ) !=  INT( hwg_Drawtext( dc, ::caption, itemRect,  DT_CALCRECT + uAlign + DT_WORDBREAK ) )
      uAlign += DT_WORDBREAK
      lMultiline := .T.
      drawInfo[4] += 2
      drawInfo[6] -= 2
      itemRect[1] += 2
      itemRect[3] -= 2
      aTxtSize[1] := itemRectold[3] - itemRectOld[1] + 1
      aTxtSize[2] := itemRectold[4] - itemRectold[2] + 1
   ELSE
      uAlign += DT_SINGLELINE
      lMultiline := .F.
   ENDIF

   captionRect := { drawInfo[4], drawInfo[5], drawInfo[6], drawInfo[7] }
   //
   IF ( !Empty(::hbitmap) .OR. !Empty(::hicon) ) .AND. lMultiline
      IF ::iStyle = ST_ALIGN_HORIZ
         captionRect := { drawInfo[4] + ::PictureMargin , drawInfo[5], drawInfo[6] , drawInfo[7] }
      ELSEIF ::iStyle = ST_ALIGN_HORIZ_RIGHT
         captionRect := { drawInfo[4], drawInfo[5], drawInfo[6] - ::PictureMargin, drawInfo[7] }
      ELSEIF ::iStyle = ST_ALIGN_VERT
      ENDIF
   ENDIF

   itemRectOld := AClone( itemRect )

   IF !Empty(::caption) .AND. !Empty(::hbitmap)  //.AND.!EMPTY(::hicon)
      nHeight :=  aTxtSize[2] //nHeight := IIF( lMultiLine, hwg_Drawtext( dc, ::caption, itemRect,  DT_CALCRECT + uAlign + DT_WORDBREAK  ), aTxtSize[2] )
      IF ::iStyle = ST_ALIGN_HORIZ
         itemRect[1] := iif( ::PictureMargin = 0, ( ( ( ::nWidth - aTxtSize[1] - aBmpSize[1] / 2 ) / 2 ) ) / 2, ::PictureMargin )
         itemRect[1] := iif( itemRect[1] < 0, 0, itemRect[1] )
      ELSEIF ::iStyle = ST_ALIGN_HORIZ_RIGHT
      ELSEIF ::iStyle = ST_ALIGN_VERT .OR. ::iStyle = ST_ALIGN_OVERLAP
         nHeight := iif( lMultiLine,  hwg_Drawtext( dc, ::caption, itemRect,  DT_CALCRECT + DT_WORDBREAK  ), aTxtSize[2] )
         ::iStyle := ST_ALIGN_OVERLAP
         itemRect[1] := ( ::nWidth - aBmpSize[1] ) /  2
         itemRect[2] := iif( ::PictureMargin = 0, ( ( ( ::nHeight - ( nHeight + aBmpSize[2] + 1 ) ) / 2 ) ), ::PictureMargin )
      ENDIF
   ELSEIF ! Empty(::caption)
      nHeight := aTxtSize[2] //nHeight := IIF( lMultiLine, hwg_Drawtext( dc, ::caption, itemRect,  DT_CALCRECT + DT_WORDBREAK ), aTxtSize[2] )
   ENDIF

   bHasTitle := ValType( ::caption ) == "C" .AND. ! Empty(::Caption)

   IF !Empty(::hbitmap) .AND. ::m_bDrawTransparent .AND. ( ! bIsDisabled .OR. ::istyle = ST_ALIGN_HORIZ_RIGHT )
      bmpRect := hwg_Prepareimagerect( ::handle, dc, bHasTitle, @itemRect, @captionRect, bIsPressed, ::hIcon, ::hbitmap, ::iStyle )
      IF ::istyle = ST_ALIGN_HORIZ_RIGHT
         bmpRect[1]     -= ::PictureMargin
         captionRect[3] -= ::PictureMargin
      ENDIF
      IF ! bIsDisabled
         hwg_Drawtransparentbitmap( dc, ::hbitmap, bmpRect[1], bmpRect[2] )
      ELSE
         hwg_Drawgraybitmap( dc, ::hbitmap, bmpRect[1], bmpRect[2] )
      ENDIF
   ELSEIF !Empty(::hbitmap) .OR. !Empty(::hicon)
      IF ::istyle = ST_ALIGN_HORIZ_RIGHT
         captionRect[3] -= ::PictureMargin
      ENDIF
      hwg_Drawtheicon( ::handle, dc, bHasTitle, @itemRect, @captionRect, bIsPressed, bIsDisabled, ::hIcon, ::hbitmap, ::iStyle )
   ELSE
      hwg_Inflaterect( @captionRect, - 3, - 3 )
   ENDIF
   captionRect[1] += iif( hb_bitand( ::Style, BS_LEFT )  != 0, Max( ::PictureMargin, 2 ), 0 )
   captionRect[3] -= iif( hb_bitand( ::Style, BS_RIGHT ) != 0, Max( ::PictureMargin, 3 ), 0 )

   itemRect1    := AClone( itemRect )
   captionRect1 := AClone( captionRect )
   itemRect     := AClone( itemRectOld )

   IF ( bHasTitle )
      // If button is pressed then "press" title also
      IF bIsPressed .AND. ! ::Themed
         hwg_Offsetrect( @captionRect, 1, 1 )
      ENDIF
      // Center text
      centerRect := hwg_Copyrect( captionRect )
      IF !Empty(::hbitmap) .OR. !Empty(::hicon)
         IF ! lmultiline  .AND. ::iStyle != ST_ALIGN_OVERLAP
            // hwg_Drawtext( dc, ::caption, captionRect[1], captionRect[2], captionRect[3], captionRect[4], uAlign + DT_CALCRECT, @captionRect )
         ELSEIF !Empty(::caption)
            // figura no topo texto em baixo
            IF ::iStyle = ST_ALIGN_OVERLAP //ST_ALIGN_VERT
               captionRect[2] :=  itemRect1[2] + aBmpSize[2] //+ 1
               uAlign -= ST_ALIGN_OVERLAP + 1
            ELSE
               captionRect[2] :=  ( ::nHeight - nHeight ) / 2 + 2
            ENDIF
            savecaptionRect := AClone( captionRect )
            hwg_Drawtext( dc, ::caption, captionRect[1], captionRect[2], captionRect[3], captionRect[4], uAlign , @captionRect )
         ENDIF
      ELSE
         // *- uAlign += DT_CENTER
      ENDIF

      captionRectHeight := captionRect[4] - captionRect[2]
      centerRectHeight  := centerRect[4] - centerRect[2]
      hwg_Offsetrect( @captionRect, 0, ( centerRectHeight - captionRectHeight ) / 2 )
      IF ::Themed
         IF !Empty(::hbitmap) .OR. !Empty(::hicon)
            IF lMultiLine  .OR. ::iStyle = ST_ALIGN_OVERLAP
               captionRect := AClone( savecaptionRect )
            ENDIF
         ELSEIF lMultiLine
            captionRect[2] := ( ::nHeight  - nHeight ) / 2 + 2
         ENDIF
         hwg_drawthemetext( ::hTheme, dc, BP_PUSHBUTTON, iif( bIsDisabled, PBS_DISABLED, PBS_NORMAL ), ;
            ::caption, ;
            uAlign + DT_END_ELLIPSIS, ;
            0, captionRect )
      ELSE
         hwg_Setbkmode( dc, TRANSPARENT )
         IF ( bIsDisabled )
            hwg_Offsetrect( @captionRect, 1, 1 )
            hwg_Settextcolor( dc, hwg_Getsyscolor( COLOR_3DHILIGHT ) )
            hwg_Drawtext( dc, ::caption, @captionRect[1], @captionRect[2], @captionRect[3], @captionRect[4], uAlign )
            hwg_Offsetrect( @captionRect, - 1, - 1 )
            hwg_Settextcolor( dc, hwg_Getsyscolor( COLOR_3DSHADOW ) )
            hwg_Drawtext( dc, ::caption, @captionRect[1], @captionRect[2], @captionRect[3], @captionRect[4], uAlign )
         ELSE
            IF ( ::bMouseOverButton .OR. bIsPressed )
               hwg_Settextcolor( dc, ::m_crColors[BTNST_COLOR_FG_IN] )
               hwg_Setbkcolor( dc, ::m_crColors[BTNST_COLOR_BK_IN] )
               fillRect := hwg_Copyrect( itemRect )
               IF bIsPressed
                  hwg_Drawbutton( dc, fillRect[1], fillRect[2], fillRect[3], fillRect[4], 6 )
               ENDIF
               hwg_Inflaterect( @fillRect, - 2, - 2 )
               hwg_Fillrect( dc, fillRect[1], fillRect[2], fillRect[3], fillRect[4], ::m_crBrush[BTNST_COLOR_BK_IN]:handle )
            ELSE
               IF ( bIsFocused )
                  hwg_Settextcolor( dc, ::m_crColors[BTNST_COLOR_FG_FOCUS] )
                  hwg_Setbkcolor( dc, ::m_crColors[BTNST_COLOR_BK_FOCUS] )
                  fillRect := hwg_Copyrect( itemRect )
                  hwg_Inflaterect( @fillRect, - 2, - 2 )
                  hwg_Fillrect( dc, fillRect[1], fillRect[2], fillRect[3], fillRect[4], ::m_crBrush[BTNST_COLOR_BK_FOCUS]:handle )
               ELSE
                  hwg_Settextcolor( dc, ::m_crColors[BTNST_COLOR_FG_OUT] )
                  hwg_Setbkcolor( dc, ::m_crColors[BTNST_COLOR_BK_OUT] )
                  fillRect := hwg_Copyrect( itemRect )
                  hwg_Inflaterect( @fillRect, - 2, - 2 )
                  hwg_Fillrect( dc, fillRect[1], fillRect[2], fillRect[3], fillRect[4], ::m_crBrush[BTNST_COLOR_BK_OUT]:handle )
               ENDIF
            ENDIF
            IF !Empty(::hbitmap) .AND. ::m_bDrawTransparent
               hwg_Drawtransparentbitmap( dc, ::hbitmap, bmpRect[1], bmpRect[2] )
            ELSEIF !Empty(::hbitmap) .OR. !Empty(::hicon)
               hwg_Drawtheicon( ::handle, dc, bHasTitle, @itemRect1, @captionRect1, bIsPressed, bIsDisabled, ::hIcon, ::hbitmap, ::iStyle )
            ENDIF
            IF !Empty(::hbitmap) .OR. !Empty(::hicon)
               IF lmultiline  .OR. ::iStyle = ST_ALIGN_OVERLAP
                  captionRect := AClone( savecaptionRect )
               ENDIF
            ELSEIF lMultiLine
               captionRect[2] := ( ::nHeight  - nHeight ) / 2 + 2
            ENDIF
            hwg_Drawtext( dc, ::caption, @captionRect[1], @captionRect[2], @captionRect[3], @captionRect[4], uAlign )
         ENDIF
      ENDIF
   ENDIF

   // Draw the focus rect
   IF bIsFocused .AND. bDrawFocusRect .AND. hb_bitand( ::sTyle, WS_TABSTOP ) != 0
      focusRect := hwg_Copyrect( itemRect )
      hwg_Inflaterect( @focusRect, - 3, - 3 )
      hwg_Drawfocusrect( dc, focusRect )
   ENDIF
   hwg_Deleteobject( br )
   hwg_Deleteobject( brBackground )
   hwg_Deleteobject( brBtnShadow )

   RETURN NIL

METHOD PAINTBK( hdc ) CLASS HBUTTONEx

   LOCAL clDC := HclientDc():New(::oparent:handle)
   LOCAL rect, rect1

   rect := hwg_Getclientrect( ::handle )
   rect1 := hwg_Getwindowrect( ::handle )
   hwg_Screentoclient( ::oparent:handle, rect1 )
   IF ValType( ::m_dcBk ) == "U"
      ::m_dcBk := hdc():New()
      ::m_dcBk:Createcompatibledc( clDC:m_hDC )
      ::m_bmpBk := hwg_Createcompatiblebitmap( clDC:m_hDC, rect[3] - rect[1], rect[4] - rect[2] )
      ::m_pbmpOldBk := ::m_dcBk:Selectobject( ::m_bmpBk )
      ::m_dcBk:Bitblt( 0, 0, rect[3] - rect[1], rect[4] - rect[4], clDC:m_hDc, rect1[1], rect1[2], SRCCOPY )
   ENDIF
   hwg_Bitblt( hdc, 0, 0, rect[3] - rect[1], rect[4] - rect[4], ::m_dcBk:m_hDC, 0, 0, SRCCOPY )

   RETURN Self
