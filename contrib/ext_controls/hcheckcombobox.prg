/*
 * $Id: hcomboex.prg 2655 2018-08-31 11:00:12Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HCombo class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HCheckComboEx class
 *
 * Copyright 2007 Luiz Rafale Culik Guimaraes (Luiz at xharbour.com.br)
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#define CB_GETDROPPEDSTATE          343
#define TRANSPARENT        1

#pragma begindump
#include "hwingui.h"
#include "hbapiitm.h"
#include "hbvm.h"

HB_FUNC( COPYDATA )
{
   LPARAM lParam = ( LPARAM ) hb_parnl(1) ;
   void * hText;
   LPCTSTR m_strText = HB_PARSTR(2, &hText, NULL);
   WPARAM wParam = ( WPARAM ) hb_parnl(3) ;

   lstrcpyn( ( LPTSTR ) lParam, m_strText, ( INT ) wParam ) ;
   hb_strfree( hText );
}

#pragma enddump

#ifndef __XHARBOUR__
   #xtranslate RAScan([<x,...>])        => hb_RAScan(<x>)
#endif

CLASS HCheckComboBox INHERIT HComboBoxEx

   CLASS VAR winclass  INIT "COMBOBOX"
   DATA m_bTextUpdated INIT .F.

   DATA m_bItemHeightSet INIT .F.
   DATA m_hListBox   INIT 0
   DATA aCheck
   DATA nWidthCheck  INIT 0
   DATA m_strText    INIT ""

   DATA lCheck
   DATA nCurPos      INIT 0
   DATA aHimages, aImages

   METHOD onGetText( wParam, lParam )
   METHOD OnGetTextLength( wParam, lParam )

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
      aItems, oFont, bInit, bSize, bPaint, bChange, ctooltip, lEdit, lText, bGFocus, ;
      tcolor, bcolor, bValid, acheck, nDisplay, nhItem, ncWidth, aImages)
   METHOD Redefine( oWndParent, nId, vari, bSetGet, aItems, oFont, bInit, bSize, bPaint, ;
      bChange, ctooltip, bGFocus, acheck,aImage )
   METHOD INIT()
   METHOD Requery()
   METHOD Refresh()
   METHOD Paint( lpDis )
   METHOD SetCheck( nIndex, bFlag )
   METHOD RecalcText()

   METHOD GetCheck( nIndex )

   METHOD SelectAll( bCheck )
   METHOD MeasureItem( l )

   METHOD onEvent( msg, wParam, lParam )
   METHOD GetAllCheck()

   METHOD EnabledItem( nItem, lEnabled )
   METHOD SkipItems( nNav )

ENDCLASS

METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, aItems, oFont, ;
      bInit, bSize, bPaint, bChange, ctooltip, lEdit, lText, bGFocus, tcolor, bcolor, ;
      bValid, acheck, nDisplay, nhItem, ncWidth, aImages) CLASS hCheckComboBox

   ::acheck := iif( acheck == NIL, {}, acheck )
   ::lCheck := iif( aImages == NIL, .T. , .F. )
   ::aImages := aImages

   IF ValType( nStyle ) == "N"
      nStyle := hwg_multibitor( nStyle, CBS_DROPDOWNLIST, CBS_OWNERDRAWVARIABLE, CBS_HASSTRINGS )
   ELSE
      nStyle := hwg_multibitor( CBS_DROPDOWNLIST, CBS_OWNERDRAWVARIABLE, CBS_HASSTRINGS )
   ENDIF

   bPaint := { | o, p | o:paint( p ) }

   ::Super:New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, aItems, oFont, ;
      bInit, bSize, bPaint, bChange, ctooltip, lEdit, lText, bGFocus, tcolor, bcolor, ;
      bValid, , nDisplay, nhItem, ncWidth)

   RETURN Self

METHOD Redefine( oWndParent, nId, vari, bSetGet, aItems, oFont, bInit, bSize, bPaint, ;
      bChange, ctooltip, bGFocus, acheck, aImages ) CLASS hCheckComboBox
      bPaint := { | o, p | o:paint( p ) }
     ::acheck := iif( acheck == NIL, {}, acheck )
     ::lCheck := iif( aImages == NIL, .T. , .F. )
     ::aImages := aImages
     ::Super:Redefine( oWndParent, nId, vari, bSetGet, aItems, oFont, bInit, bSize, bPaint, ;
      bChange, ctooltip, bGFocus,, , , , , ,aCheck )

   ::lResource := .T.


   RETURN Self

METHOD INIT() CLASS hCheckComboBox
   LOCAL i, nSize, hImage

   IF !::lInit
      ::Super:Init()

      IF Len( ::acheck ) > 0
         AEval( ::aCheck, { | a ,v| ::Setcheck(v, a ) } )
      ENDIF
      IF !Empty(::aItems) .AND. !Empty(::nhItem)
         FOR i := 1 TO Len( ::aItems )
            hwg_Sendmessage( ::handle, CB_SETITEMHEIGHT , i - 1, ::nhItem )
         NEXT
      ENDIF
      ::nCurPos := hwg_Sendmessage( ::handle, CB_GETCURSEL, 0, 0 )
      // LOAD IMAGES COMBO
      IF ::aImages != NIL .AND. Len( ::aImages ) > 0
         ::aHImages := {}
         nSize := hwg_Sendmessage( ::handle, CB_GETITEMHEIGHT, - 1, 0 ) - 5
         FOR i := 1 TO Len( ::aImages )
            hImage := 0
            IF ( ValType( ::aImages[i] ) == "C" .OR. ::aImages[i] > 1 ) .AND. ! Empty(::aImages[i])
               IF ValType( ::aImages[i] ) == "C" .AND. At(".", ::aImages[i]) != 0
                  IF File( ::aImages[i] )
                     hImage := HBITMAP():AddfILE( ::aImages[i], , .T. , 16, nSize ):handle
                  ENDIF
               ELSE
                  hImage := HBitmap():AddResource( ::aImages[i], , , 16, nSize ):handle
               ENDIF
            ENDIF
            AAdd(::aHImages, hImage)
         NEXT
      ENDIF
   ENDIF

   RETURN NIL

METHOD onEvent( msg, wParam, lParam ) CLASS hCheckComboBox
   LOCAL nIndex
   LOCAL rcItem, rcClient
   LOCAL pt
   LOCAL nItemHeight
   LOCAL nTopIndex
   LOCAL nPos

   IF msg == WM_RBUTTONDOWN
   ELSEIF msg == LB_GETCURSEL
      RETURN - 1

   ELSEIF msg == WM_MEASUREITEM
      ::MeasureItem( lParam )
      RETURN 0
   ELSEIF msg == WM_GETTEXT
      RETURN ::OnGetText( wParam, lParam )

   ELSEIF msg == WM_GETTEXTLENGTH
      RETURN ::OnGetTextLength( wParam, lParam )

   ELSEIF msg = WM_MOUSEWHEEL
      RETURN ::SkipItems( iif( hwg_Hiword( wParam ) > 32768, 1, - 1 ) )

   ELSEIF msg = WM_COMMAND
      IF hwg_Hiword( wParam ) = CBN_SELCHANGE
         nPos := hwg_Sendmessage( ::handle, CB_GETCURSEL, 0, 0 )
         IF Left( ::Title, 2 ) == "\]" .OR. Left( ::Title, 2 ) == "\-"
            RETURN 0
         ELSE
            ::nCurPos := nPos
         ENDIF
      ENDIF

   ELSEIF msg == WM_CHAR

      IF ( wParam == VK_SPACE )
         nIndex := hwg_Sendmessage( ::handle, CB_GETCURSEL, wParam, lParam ) + 1
         rcItem := hwg_Combogetitemrect( ::handle, nIndex - 1 )
         hwg_Invalidaterect( ::handle, .F. , rcItem[1], rcItem[2], rcItem[3], rcItem[4] )
         ::SetCheck( nIndex, !::GetCheck( nIndex ) )
         hwg_Sendmessage( ::oParent:handle, WM_COMMAND, hwg_Makelong( ::id, CBN_SELCHANGE ), ::handle )
      ENDIF
      IF ( hwg_GetParentForm( Self ) :Type < WND_DLG_RESOURCE .OR. !hwg_GetParentForm( Self ) :lModal )
         IF wParam = VK_TAB
            hwg_GetSkip( ::oParent, ::handle, , iif( hwg_IsCtrlShift( .F. , .T. ), - 1, 1 ) )
            RETURN 0
         ELSEIF wParam == VK_RETURN
            hwg_GetSkip( ::oParent, ::handle, , 1 )
            RETURN 0
         ENDIF
      ENDIF
      RETURN 0
   ELSEIF msg = WM_KEYDOWN

      IF wParam = VK_HOME .OR. wParam = VK_END
         nPos := iif( wParam = VK_HOME, ;
            Ascan( ::aItems, { | a | ! Left( a[1], 2 ) $ "\-" + Chr(0) + "\]" } , , ) , ;
            RAscan( ::aItems, { | a | ! Left( a[1], 2 ) $ "\-" + Chr(0) + "\]" } , , ) )
         IF nPos - 1 != ::nCurPos
            hwg_Setfocus( NIL )
            hwg_Sendmessage( ::handle, CB_SETCURSEL, nPos - 1, 0 )
            hwg_Sendmessage( ::oParent:handle, WM_COMMAND, hwg_Makelong( ::id, CBN_SELCHANGE ), ::handle )
            ::nCurPos := nPos - 1
            RETURN 0
         ENDIF
      ELSEIF ( wParam = VK_UP .OR. wParam = VK_DOWN )
         RETURN ::SkipItems( iif( wParam = VK_DOWN, 1, - 1 ) )
      ENDIF
      //hwg_ProcKeyList( Self, wParam )

   ELSEIF msg = WM_KEYUP
      IF ( wParam = VK_DOWN .OR. wParam = VK_UP )
         IF Left( ::Title, 2 ) == "\]" .OR. Left( ::Title, 2 ) == "\-"
            RETURN 0
         ENDIF
      ENDIF


   ELSEIF msg == WM_LBUTTONDOWN

      rcClient := hwg_Getclientrect( ::handle )

      pt := { , }
      pt[1] = hwg_Loword( lParam )
      pt[2] = hwg_Hiword( lParam )

      IF ( hwg_Ptinrect( rcClient, pt ) )

         nItemHeight := hwg_Sendmessage( ::handle, LB_GETITEMHEIGHT, 0, 0 )
         nTopIndex   := hwg_Sendmessage( ::handle, LB_GETTOPINDEX, 0, 0 )

         // Compute which index to check/uncheck
         nIndex := ( nTopIndex + pt[2] / nItemHeight ) + 1
         rcItem := hwg_Combogetitemrect( ::handle, nIndex - 1 )

         IF pt[1] < ::nWidthCheck
            // Invalidate this window
            hwg_Invalidaterect( ::handle, .F. , rcItem[1], rcItem[2], rcItem[3], rcItem[4] )
            nIndex := hwg_Sendmessage( ::handle, CB_GETCURSEL, wParam, lParam ) + 1
            ::SetCheck( nIndex, !::GetCheck( nIndex ) )

            // Notify that selection has changed

            hwg_Sendmessage( ::oParent:handle, WM_COMMAND, hwg_Makelong( ::id, CBN_SELCHANGE ), ::handle )

         ENDIF
      ENDIF

   ELSEIF msg == WM_LBUTTONUP
      RETURN - 1
   ENDIF

   RETURN - 1

METHOD Requery() CLASS hCheckComboBox
   LOCAL i

   ::Super:Requery()
   IF Len( ::acheck ) > 0
      AEval( ::aCheck, { | a ,v| ::Setcheck( v,a ) } )
   ENDIF
   IF !Empty(::aItems) .AND. !Empty(::nhItem)
      FOR i := 1 TO Len( ::aItems )
         hwg_Sendmessage( ::handle, CB_SETITEMHEIGHT , i - 1, ::nhItem )
      NEXT
   ENDIF

   RETURN NIL

METHOD Refresh() CLASS hCheckComboBox

   ::Super:refresh()

   RETURN NIL

METHOD SetCheck( nIndex, bFlag ) CLASS hCheckComboBox

   LOCAL nResult := hwg_Comboboxsetitemdata( ::handle, nIndex - 1, bFlag )

   IF ( nResult < 0 )
      RETURN nResult
   ENDIF

   ::m_bTextUpdated := FALSE

   // Redraw the window
   hwg_Invalidaterect( ::handle, 0 )

   RETURN nResult

METHOD GetCheck( nIndex ) CLASS hCheckComboBox

   LOCAL l := hwg_Comboboxgetitemdata( ::handle, nIndex - 1 )

   RETURN iif( l == 1, .T. , .F. )

METHOD SelectAll( bCheck ) CLASS hCheckComboBox

   LOCAL nCount
   LOCAL i

   DEFAULT bCheck TO .T.

   nCount := hwg_Sendmessage( ::handle, CB_GETCOUNT, 0, 0 )

   FOR i := 1 TO nCount
      ::SetCheck( i, bCheck )
   NEXT

   RETURN NIL

METHOD RecalcText() CLASS hCheckComboBox
   LOCAL strtext
   LOCAL ncount
   LOCAL strSeparator
   LOCAL i
   LOCAL stritem

   IF ( !::m_bTextUpdated )

      // Get the list count
      ncount := hwg_Sendmessage( ::handle, CB_GETCOUNT, 0, 0 )

      // Get the list separator

      strSeparator := hwg_Getlocaleinfo()

      // If none found, the the ''
      IF Len( strSeparator ) == 0
         strSeparator := ''
      ENDIF

      strSeparator := RTrim(strSeparator)

      strSeparator += ' '

      FOR i := 1 TO ncount

         IF ( hwg_Comboboxgetitemdata( ::handle, i ) ) = 1

            hwg_Comboboxgetlbtext( ::handle, i, @stritem )

            IF !Empty(strtext)
               strtext += strSeparator
            ENDIF
            //strtext += stritem     // error
         ENDIF
      NEXT

      // Set the text
      ::m_strText := strtext

      ::m_bTextUpdated := TRUE
   ENDIF

   RETURN Self

METHOD Paint( lpDis ) CLASS hCheckComboBox

   LOCAL drawInfo := hwg_Getdrawiteminfo( lpDis )

   LOCAL dc := drawInfo[3]

   LOCAL rcBitmap := { drawInfo[4], drawInfo[5], drawInfo[6], drawInfo[7] }
   LOCAL rcText   := { drawInfo[4], drawInfo[5], drawInfo[6], drawInfo[7] }
   LOCAL strtext  := "", cTmp
   LOCAL ncheck   := 0
   LOCAL metrics
   LOCAL nstate
   LOCAL iStyle  := ST_ALIGN_HORIZ
   LOCAL nIndent
   LOCAL hbitmap := 0, bmpRect
   LOCAL lDroped := hwg_Sendmessage( ::handle, CB_GETDROPPEDSTATE, 0, 0 ) > 0

   IF ( drawInfo[1] < 0 )

      ::RecalcText()

      strtext := ::m_strText
      

      ncheck := 0

   ELSE
      hwg_Comboboxgetlbtext( ::handle, drawInfo[1], @strtext )

      IF  ::lCheck
         ncheck := 1 + ( hwg_Comboboxgetitemdata( ::handle, drawInfo[1] ) )
         metrics := hwg_Gettextmetric( dc )
         rcBitmap[1] := 0
         rcBitmap[3] := rcBitmap[1] + metrics[1] + metrics[4] + 6
         rcBitmap[2] += 1
         rcBitmap[4] -= 1

         rcText[1]   := rcBitmap[3]
         ::nWidthCheck := rcBitmap[3]

      ELSEIF ::aHImages != NIL .AND. DrawInfo[1] + 1 <= Len( ::aHImages ) .AND. ! Empty(::aHImages[DrawInfo[1] + 1])
         nIndent := iif( ! lDroped, 1, ( Len( strText ) - Len( LTrim(strText) ) ) * hwg_TxtRect( "a", Self, ::oFont )[1] )
         strtext := LTrim(strtext)
         hbitmap := ::aHImages[DrawInfo[1] + 1]
         rcBitmap[1] := nIndent
         bmpRect := hwg_Prepareimagerect( ::handle, dc, .T. , @rcBitmap, @rcText, , , hbitmap, iStyle )
         rcText[1] :=  iif( iStyle = ST_ALIGN_HORIZ, nIndent + hwg_Getbitmapsize( hbitmap )[1] + iif( lDroped, 3, 4 ) , 1 )
      ENDIF

   ENDIF

   // Erase and draw
   IF Empty(strtext)
      strtext := ""
   ENDIF
   ::Title := strtext
   cTmp := Left( ::Title, 2 )

   IF cTmp == "\]" .OR. cTmp == "\-"
      IF ! lDroped
         hwg_Exttextout( dc, 0, 0, iif( ::lCheck, rcText[1], 0 ), rcText[2], rcText[3], rcText[4] )
         RETURN 0
      ENDIF
   ENDIF
   IF ( ncheck > 0 ) .AND. cTmp != "\-"
      hwg_Setbkcolor( dc, hwg_Getsyscolor( COLOR_WINDOW ) )
      hwg_Settextcolor( dc, hwg_Getsyscolor( COLOR_WINDOWTEXT ) )

      nstate := DFCS_BUTTONCHECK

      IF ( ncheck > 1 )
         nstate := hb_bitor( nstate, DFCS_CHECKED )
      ENDIF

      // Draw the checkmark using DrawFrameControl
      hwg_Drawframecontrol( dc, rcBitmap, DFC_BUTTON, nstate )
   ENDIF

   IF ( hb_bitand( drawInfo[9], ODS_SELECTED ) != 0 )
      hwg_Setbkcolor( dc, hwg_Getsyscolor( COLOR_HIGHLIGHT ) )
      hwg_Settextcolor( dc, hwg_Getsyscolor( COLOR_HIGHLIGHTTEXT ) )
   ELSE
      hwg_Setbkcolor( dc, hwg_Getsyscolor( COLOR_WINDOW ) )
      hwg_Settextcolor( dc, hwg_Getsyscolor( COLOR_WINDOWTEXT ) )
   ENDIF

   IF cTmp == "\]"
      hwg_Settextcolor( dc, hwg_Getsyscolor( COLOR_GRAYTEXT ) )
      strtext := SubStr(strText, 3)
   ENDIF
   IF cTmp == "\-"
      hwg_Drawline( DC, 1, rcText[2] + ( rcText[4] - rcText[2] ) / 2 , ;
         rcText[3] - 1, ;
         rcText[2] + ( rcText[4] - rcText[2] ) / 2 )
   ELSE
      hwg_Exttextout( dc, 0, 0, iif( ::lCheck, rcText[1], 0 ), rcText[2], rcText[3], rcText[4] )
      hwg_Drawtext( dc, ' ' + strtext, rcText[1], rcText[2], rcText[3], rcText[4], DT_SINGLELINE + DT_VCENTER + DT_END_ELLIPSIS )
   ENDIF
   IF hbitmap != 0
      hwg_Setbkmode( dc, TRANSPARENT )
      IF cTmp == "\]"
         hwg_Drawgraybitmap( dc, hbitmap, bmpRect[1]  , bmpRect[2] + 1 )
      ELSE
         hwg_Drawtransparentbitmap( dc, hbitmap, bmpRect[1]  , bmpRect[2] + 1 )
      ENDIF
   ENDIF
   IF ( ( hb_bitand( DrawInfo[9], ODS_FOCUS + ODS_SELECTED ) ) == ( ODS_FOCUS + ODS_SELECTED ) )
      IF  cTmp != "\-"  .AND. ! lDroped
         hwg_Drawfocusrect( dc, iif( ::lCheck, rcText , rcBitmap ) )
      ENDIF
   ENDIF

   RETURN Self

METHOD MeasureItem( l ) CLASS hCheckComboBox
   LOCAL dc                  := HCLIENTDC():new(::handle)
   LOCAL lpMeasureItemStruct := hwg_Getmeasureiteminfo( l )
   LOCAL metrics
   LOCAL pFont

   pFont := dc:Selectobject( iif( ValType( ::oFont ) == "O", ::oFont:handle, ;
      iif( ValType( ::oParent:oFont ) == "O", ::oParent:oFont:handle, ) ) )

   IF !Empty(pFont)

      metrics := dc:Gettextmetric()

      lpMeasureItemStruct[5] := metrics[1] + metrics[4]

      lpMeasureItemStruct[5] += 2

      IF ( !::m_bItemHeightSet )
         ::m_bItemHeightSet := .T.
         hwg_Sendmessage( ::handle, CB_SETITEMHEIGHT, - 1, hwg_Makelong( lpMeasureItemStruct[5], 0 ) )
      ENDIF

      dc:Selectobject( pFont )
      dc:END()
   ENDIF

   RETURN Self

METHOD OnGetText( wParam, lParam ) CLASS hCheckComboBox

   ::RecalcText()

   IF ( lParam == 0 )
      RETURN 0
   ENDIF

   // Copy the 'fake' window text
   copydata( lParam, ::m_strText, wParam )

   RETURN iif( Empty(::m_strText), 0, Len( ::m_strText ) )

METHOD OnGetTextLength( WPARAM, LPARAM ) CLASS hCheckComboBox

   HB_SYMBOL_UNUSED(WPARAM)
   HB_SYMBOL_UNUSED(LPARAM)

   ::RecalcText()

   RETURN iif( Empty(::m_strText), 0, Len( ::m_strText ) )

METHOD GetAllCheck() CLASS hCheckComboBox
   LOCAL aCheck := { }
   LOCAL n

   FOR n := 1 TO Len( ::aItems )
      IF ::GetCheck( n )
         AAdd(aCheck, n)
      ENDIF
   NEXT

   RETURN aCheck

METHOD EnabledItem( nItem, lEnabled ) CLASS hCheckComboBox
   LOCAL cItem

   IF lEnabled != NIL
      IF nItem != NIL .AND. nItem > 0
         IF lEnabled .AND. Left( ::aItems[nItem], 2 ) == "\]"
            cItem := SubStr(::aItems[nItem], 3)
         ELSEIF ! lEnabled .AND. Left( ::aItems[nItem], 2 ) != "\]" .AND. Left( ::aItems[nItem], 2 ) != "\-"
            cItem := "\]" + ::aItems[nItem]
         ENDIF
         IF !Empty(cItem)
            ::aItems[nItem] := cItem
            hwg_Sendmessage( ::Handle, CB_DELETESTRING, nItem - 1, 0 )
            hwg_Comboinsertstring( ::handle, nItem - 1, cItem )
         ENDIF
      ENDIF
   ENDIF

   RETURN  ! Left( ::aItems[nItem], 2 ) == "\]"

METHOD SkipItems( nNav ) CLASS hCheckComboBox
   LOCAL nPos
   LOCAL strText := ""

   hwg_Comboboxgetlbtext( ::handle, ::nCurPos + nNav, @strText ) // NEXT
   IF Left( strText, 2 ) == "\]" .OR. Left( strText, 2 ) == "\-"
      nPos := iif( nNav > 0, ;
         Ascan(  ::aItems, { | a | ! Left( a[1], 2 ) $ "\-" + Chr(0) + "\]" }, ::nCurPos + 2  ), ;
         RAscan( ::aItems, { | a | ! Left( a[1], 2 ) $ "\-" + Chr(0) + "\]" }, ::nCurPos - 1, ) )
      nPos := iif( nPos = 0, ::nCurPos , nPos - 1 )
      hwg_Setfocus( NIL )
      hwg_Sendmessage( ::handle, CB_SETCURSEL, nPos , 0 )
      IF nPos != ::nCurPos
         hwg_Sendmessage( ::oParent:handle, WM_COMMAND, hwg_Makelong( ::id, CBN_SELCHANGE ), ::handle )
      ENDIF
      ::nCurPos := nPos
      RETURN 0
   ENDIF

   RETURN - 1
