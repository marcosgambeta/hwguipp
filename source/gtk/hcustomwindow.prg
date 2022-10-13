/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HCustomWindow class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "error.ch"

   STATIC aCustomEvents := { ;
      { WM_PAINT, WM_COMMAND, WM_SIZE, WM_DESTROY }, ;
      { ;
      { |o, w|iif( o:bPaint != NIL, Eval( o:bPaint,o,w ), - 1 ) }, ;
      { |o, w|onCommand( o, w ) },                ;     && |o, w, l| ==> |o, w|
      { |o, w, l|onSize( o, w, l ) },                ;
      { |o|onDestroy( o ) }                          ;
      } ;
      }

CLASS HCustomWindow INHERIT HObject

   CLASS VAR oDefaultParent SHARED
   DATA handle  INIT 0
   DATA oParent
   DATA title
   DATA TYPE
   DATA nTop // deprecated - use nY
   ACCESS nY INLINE ::nTop
   ASSIGN nY(n) INLINE ::nTop := n
   DATA nLeft // deprecated - use nX
   ACCESS nX INLINE ::nLeft
   ASSIGN nX(n) INLINE ::nLeft := n
   DATA nWidth, nHeight
   DATA tcolor, bcolor, brush
   DATA style
   DATA extStyle  INIT 0
   DATA lHide INIT .F.
   DATA oFont
   DATA aEvents   INIT {}
   DATA aNotify   INIT {}
   DATA aControls INIT {}
   DATA bInit
   DATA bDestroy
   DATA bSize
   DATA bPaint
   DATA bGetFocus
   DATA bLostFocus
   DATA bOther
   DATA HelpId    INIT 0
   DATA nChildId  INIT 34000

   METHOD AddControl( oCtrl ) INLINE AAdd(::aControls, oCtrl)
   METHOD DelControl( oCtrl )
   METHOD AddEvent( nEvent, nId, bAction ) INLINE AAdd(::aEvents, {nEvent, nId, bAction})
   METHOD FindControl( nId, nHandle )
   METHOD Hide() INLINE ( ::lHide := .T. , hwg_Hidewindow( ::handle ) )
   METHOD Show() INLINE ( ::lHide := .F. , hwg_Showwindow( ::handle ) )
   METHOD Move( x1, y1, width, height )
   METHOD Refresh()
   METHOD Setcolor( tcolor, bcolor, lRepaint )
   METHOD onEvent( msg, wParam, lParam )
   METHOD End()
   ERROR HANDLER OnError()

ENDCLASS

METHOD FindControl( nId, nHandle ) CLASS HCustomWindow
   LOCAL i

   IF HB_ISCHAR(nId)
      nId := Upper(nId)
      RETURN hwg_GetItemByName( ::aControls, nId )
   ELSE
      i := Iif( nId != NIL, Ascan( ::aControls,{|o|o:id == nId } ), ;
         Ascan( ::aControls, {|o|o:handle == nHandle } ) )
   ENDIF

   RETURN Iif( i == 0, NIL, ::aControls[i] )

METHOD DelControl( oCtrl ) CLASS HCustomWindow
   LOCAL id := oCtrl:id, h
   LOCAL i := Ascan( ::aControls, { |o|o == oCtrl } )

   IF oCtrl:ClassName() == "HPANEL"
      hwg_Destroypanel( oCtrl:handle )
   ELSE
      hwg_DestroyWindow( oCtrl:handle )
   ENDIF
   IF i != 0
      ADel( ::aControls, i )
      ASize( ::aControls, Len( ::aControls ) - 1 )
   ENDIF
   h := 0
   FOR i := Len( ::aEvents ) TO 1 STEP - 1
      IF ::aEvents[i,2] == id
         ADel( ::aEvents, i )
         h ++
      ENDIF
   NEXT
   IF h > 0
      ASize( ::aEvents, Len( ::aEvents ) - h )
   ENDIF
   h := 0
   FOR i := Len( ::aNotify ) TO 1 STEP - 1
      IF ::aNotify[i,2] == id
         ADel( ::aNotify, i )
         h ++
      ENDIF
   NEXT
   IF h > 0
      ASize( ::aNotify, Len( ::aNotify ) - h )
   ENDIF

   RETURN NIL

METHOD Move( x1, y1, width, height )  CLASS HCustomWindow

   hwg_Movewindow( ::handle, x1, y1, width, height )
   IF !__ObjHasMsg( Self, "AWINDOWS" )
      IF x1 != NIL
         ::nX := x1
      ENDIF
      IF y1 != NIL
         ::nY := y1
      ENDIF
      IF width != NIL
         ::nWidth := width
      ENDIF
      IF height != NIL
         ::nHeight := height
      ENDIF
   ENDIF

   RETURN NIL

METHOD Refresh() CLASS HCustomWindow

   hwg_Redrawwindow( ::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW )

   RETURN NIL

METHOD Setcolor( tcolor, bcolor, lRepaint ) CLASS HCustomWindow

   IF tcolor != NIL
      ::tcolor  := tcolor
      IF !Empty(::handle)
         hwg_Setfgcolor( ::handle, ::tcolor )
      ENDIF
   ENDIF

   IF bcolor != NIL
      ::bcolor  := bcolor
      IF !Empty(::handle)
         hwg_Setbgcolor( ::handle, ::bcolor )
      ENDIF
      IF ::brush != NIL
         ::brush:Release()
      ENDIF
      ::brush := HBrush():Add( bcolor )
   ENDIF

   IF lRepaint != NIL .AND. lRepaint
      hwg_Redrawwindow( ::handle, RDW_ERASE + RDW_INVALIDATE )
   ENDIF

   RETURN NIL

METHOD onEvent( msg, wParam, lParam ) CLASS HCustomWindow
   LOCAL i

   // hwg_WriteLog( "== "+::Classname()+Str(msg)+Iif(wParam!=NIL,Str(wParam),"NIL")+Iif(lParam!=NIL,Str(lParam),"NIL") )
   IF ( i := Ascan( aCustomEvents[1],msg ) ) != 0
      RETURN Eval( aCustomEvents[2,i], Self, wParam, lParam )
   ELSEIF ::bOther != NIL
      RETURN Eval( ::bOther, Self, msg, wParam, lParam )
   ENDIF

   RETURN 0

METHOD End()  CLASS HCustomWindow
   LOCAL aControls := ::aControls
   LOCAL i, nLen := Len( aControls )

   FOR i := 1 TO nLen
      aControls[i]:End()
   NEXT

   hwg_ReleaseObject( ::handle )

   RETURN NIL

METHOD OnError() CLASS HCustomWindow

   LOCAL cMsg := __GetMessage()
   LOCAL oError
   LOCAL oItem

   IF !Empty(oItem := hwg_GetItemByName( ::aControls, cMsg ))
      RETURN oItem
   ENDIF
   FOR EACH oItem IN HTimer():aTimers
      IF !Empty(oItem:objname) .AND. oItem:objname == cMsg .AND. hwg_Isptreq( ::handle, oItem:oParent:handle )
         RETURN oItem
      ENDIF
   NEXT

   oError := ErrorNew()
   oError:severity    := ES_ERROR
   oError:genCode     := EG_LIMIT
   oError:subSystem   := "HCUSTOMWINDOW"
   oError:subCode     := 0
   oError:description := "Invalid class member"
   oError:canRetry    := .F.
   oError:canDefault  := .F.
   oError:fileName    := ""
   oError:osCode      := 0

   Eval( ErrorBlock(), oError )
   __errInHandler()

   RETURN NIL

STATIC FUNCTION onDestroy( oWnd )

   oWnd:End()

   RETURN 0

STATIC FUNCTION onCommand( oWnd, wParam )
   LOCAL iItem, iParHigh := hwg_Hiword( wParam ), iParLow := hwg_Loword( wParam )

   IF oWnd:aEvents != NIL .AND. ;
         ( iItem := Ascan( oWnd:aEvents, { |a|a[1] == iParHigh .AND. a[2] == iParLow } ) ) > 0
      Eval( oWnd:aEvents[iItem, 3], oWnd, iParLow )
   ENDIF

   RETURN 1

STATIC FUNCTION onSize( oWnd, wParam, lParam )
   LOCAL aControls := oWnd:aControls, oItem, x, y

   FOR EACH oItem in aControls
      IF oItem:bSize != NIL
         IF wParam != 0
            x := wParam
            y := lParam
         ELSE
            x := hwg_Loword( lParam )
            y := hwg_Hiword( lParam )
         ENDIF
         Eval( oItem:bSize, oItem, x, y )
         onSize( oItem, oItem:nWidth, oItem:nHeight )
      ENDIF
   NEXT

   RETURN 0

FUNCTION hwg_onTrackScroll( oWnd, wParam, lParam )

   LOCAL oCtrl := oWnd:FindControl( , lParam ), msg

   IF oCtrl != NIL
      msg := hwg_Loword ( wParam )
      IF msg == TB_ENDTRACK
         IF HB_ISBLOCK( oCtrl:bChange )
            Eval( oCtrl:bChange, oCtrl )
            RETURN 0
         ENDIF
      ELSEIF msg == TB_THUMBTRACK .OR. msg == TB_PAGEUP .OR. msg == TB_PAGEDOWN
         IF HB_ISBLOCK( oCtrl:bThumbDrag )
            Eval( oCtrl:bThumbDrag, oCtrl )
            RETURN 0
         ENDIF
      ENDIF
   ENDIF

   RETURN 0

FUNCTION hwg_GetItemByName( arr, cName )

   LOCAL oItem
   FOR EACH oItem IN arr
      IF !Empty(oItem:objname) .AND. oItem:objname == cName
         RETURN oItem
      ENDIF
   NEXT

   RETURN NIL
