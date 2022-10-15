/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HTab class
 *
 * Copyright 2005 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "hwgui.ch"
#include "hbclass.ch"

CLASS HTab INHERIT HControl

   CLASS VAR winclass   INIT "SysTabControl32"
   DATA  aTabs
   DATA  aPages  INIT {}
   DATA  bChange, bChange2
   DATA  oTemp
   DATA  bAction

   METHOD New( oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, ;
      oFont, bInit, bSize, bPaint, aTabs, bChange, aImages, lResour, nBC, ;
      bClick, bGetFocus, bLostFocus )
   METHOD Activate()
   METHOD Init()
   METHOD onEvent( msg, wParam, lParam )
   METHOD SetTab( n )
   METHOD StartPage( cname )
   METHOD EndPage()
   METHOD GetActivePage( nFirst, nEnd )
   METHOD DeletePage( nPage )

   HIDDEN:
   DATA  nActive  INIT 0         // Active Page

ENDCLASS

METHOD New( oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, ;
      oFont, bInit, bSize, bPaint, aTabs, bChange, aImages, lResour, nBC, bClick, bGetFocus, bLostFocus  ) CLASS HTab

   // Variables not used
   // LOCAL i, aBmpSize
   
   * Parameters not used
   HB_SYMBOL_UNUSED(aImages)
   HB_SYMBOL_UNUSED(lResour)
   HB_SYMBOL_UNUSED(nBC)   

   ::Super:New( oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, ;
      bSize, bPaint )

   ::title   := ""
   ::oFont   := iif( oFont == NIL, ::oParent:oFont, oFont )
   ::aTabs   := iif( aTabs == NIL, {}, aTabs )
   ::bChange := bChange

   ::bChange2 := bChange

   ::bGetFocus := iif( bGetFocus == NIL, NIL, bGetFocus )
   ::bLostFocus := iif( bLostFocus == NIL, NIL, bLostFocus )
   ::bAction   := iif( bClick == NIL, NIL, bClick )

   ::Activate()

   RETURN Self

METHOD Activate() CLASS HTab

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createtabcontrol( ::oParent:handle, ::id, ;
         ::style, ::nX, ::nY, ::nWidth, ::nHeight )

      ::Init()
   ENDIF

   RETURN NIL

METHOD Init() CLASS HTab
   
   LOCAL i
   LOCAL h

   IF !::lInit
      ::Super:Init()
      FOR i := 1 TO Len( ::aTabs )
         h := hwg_Addtab( ::handle, ::aTabs[i] )
         AAdd(::aPages, {0, 0, .T., h})
      NEXT

      hwg_Setwindowobject( ::handle, Self )
   ENDIF

   RETURN NIL

METHOD onEvent( msg, wParam, lParam ) CLASS HTab

   * Parameters not used
   HB_SYMBOL_UNUSED(lParam)
   

   IF msg == WM_USER
      ::nActive := wParam
      IF ::bChange2 != NIL .AND. ::aPages[::nActive, 3]
         Eval( ::bChange2, Self, wParam )
      ENDIF
   ENDIF

   RETURN 0

METHOD SetTab( n ) CLASS HTab

   hwg_SetCurrentTab( ::handle, n )

   RETURN NIL

METHOD StartPage( cname ) CLASS HTab
   
   LOCAL i

   ::oTemp := ::oDefaultParent
   ::oDefaultParent := Self
   AAdd(::aTabs, cname)
   i := Len( ::aTabs )
   AAdd(::aPages, {Len(::aControls), 0, .F., 0})

   ::nActive := i
   ::aPages[i, 4] := hwg_Addtab( ::handle, ::aTabs[i] )

   RETURN NIL

METHOD EndPage() CLASS HTab

   ::aPages[::nActive, 2] := Len( ::aControls ) - ::aPages[::nActive, 1]
   ::aPages[::nActive, 3] := .T.
   ::nActive := 1

   ::oDefaultParent := ::oTemp
   ::oTemp := NIL

   RETURN NIL

METHOD GetActivePage( nFirst, nEnd ) CLASS HTab
   IF !Empty(::aPages)
      nFirst := ::aPages[::nActive, 1] + 1
      nEnd   := ::aPages[::nActive, 1] + ::aPages[::nActive, 2]
   ELSE
      nFirst := 1
      nEnd   := Len( ::aControls )
   ENDIF

   Return ::nActive

METHOD DeletePage( nPage ) CLASS HTab

   LOCAL nFirst
   LOCAL nEnd
   LOCAL i

   nFirst := ::aPages[nPage, 1] + 1
   nEnd   := ::aPages[nPage, 1] + ::aPages[nPage, 2]
   FOR i := nEnd TO nFirst STEP -1
      ::DelControl( ::aControls[i] )
   NEXT
   FOR i := nPage + 1 TO Len( ::aPages )
      ::aPages[i, 1] -= ( nEnd-nFirst+1 )
   NEXT

   hwg_Deletetab( ::handle, nPage - 1 )

   ADel( ::aPages, nPage )
   ASize( ::aPages, Len( ::aPages ) - 1 )

   ADel( :: aTabs, nPage )
   ASize( :: aTabs, Len( :: aTabs) - 1 )

   IF nPage > 1
      ::nActive := nPage - 1
      ::SetTab( ::nActive )
   ELSEIF Len( ::aPages ) > 0
      ::nActive := 1
      ::SetTab(1)
   ENDIF

   Return ::nActive
