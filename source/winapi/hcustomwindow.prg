/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HCustomWindow class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "error.ch"

#if 0
#define EVENTS_MESSAGES 1
#define EVENTS_ACTIONS  2
#endif

#if 0
STATIC aCustomEvents := { ;
      { WM_NOTIFY, WM_PAINT, WM_CTLCOLORSTATIC, WM_CTLCOLOREDIT, WM_CTLCOLORBTN, ;
      WM_COMMAND, WM_DRAWITEM, WM_SIZE, WM_DESTROY }, ;
      { ;
      { |o, w, l| onNotify(o, w, l) }, ;
      { |o, w|   iif(o:bPaint != NIL, Eval(o:bPaint, o, w), -1) }, ;
      { |o, w, l| onCtlColor(o, w, l) }, ;
      { |o, w, l| onCtlColor(o, w, l) }, ;
      { |o, w, l| onCtlColor(o, w, l) }, ;
      { |o, w, l| onCommand(o, w, l) }, ;
      { |o, w, l| onDrawItem(o, w, l) }, ;
      { |o, w, l| onSize(o, w, l) }, ;
      { |o|     onDestroy(o) }                                       ;
      } ;
      }
#endif

CLASS HCustomWindow INHERIT HObject

   CLASS VAR oDefaultParent SHARED

   DATA handle        INIT 0
   DATA oParent
   DATA title
   DATA TYPE
   DATA nTop
   DATA nLeft
   DATA nWidth
   DATA nHeight
   DATA tcolor
   DATA bcolor
   DATA brush
   DATA style
   DATA extStyle      INIT 0
   DATA lHide         INIT .F.
   DATA oFont
   DATA aEvents       INIT {}
   DATA aNotify       INIT {}
   DATA aControls     INIT {}
   DATA bInit
   DATA bDestroy
   DATA bSize
   DATA bPaint
   DATA bGetFocus
   DATA bLostFocus
   DATA bOther
   DATA HelpId        INIT 0
   DATA nHolder       INIT 0
   DATA nChildId      INIT 34000

   METHOD AddControl(oCtrl) INLINE AAdd(::aControls, oCtrl)
   METHOD DelControl(oCtrl)
   METHOD AddEvent(nEvent, nId, bAction, lNotify) INLINE AAdd(iif(lNotify == NIL .OR. !lNotify, ::aEvents, ::aNotify), {nEvent, nId, bAction})
   METHOD FindControl(nId, nHandle)
   METHOD Hide() INLINE (::lHide := .T., hwg_Hidewindow(::handle))
   METHOD Show() INLINE (::lHide := .F., hwg_Showwindow(::handle))
   METHOD Refresh()
   METHOD Move(x1, y1, width, height)
   METHOD SetColor(tcolor, bColor, lRepaint)
   METHOD onEvent(msg, wParam, lParam)
   METHOD End()
   ERROR HANDLER OnError()

ENDCLASS

METHOD FindControl(nId, nHandle) CLASS HCustomWindow

   LOCAL i

   IF Valtype(nId) == "C"
      nId := Upper(nId)
      RETURN hwg_GetItemByName(::aControls, nId)
   ELSE
      i := Iif(nId != NIL, Ascan(::aControls, {|o|o:id == nId}), Ascan(::aControls, {|o|hwg_Isptreq(o:handle, nHandle)}))
   ENDIF

   RETURN Iif(i == 0, NIL, ::aControls[i])

METHOD DelControl(oCtrl) CLASS HCustomWindow

   LOCAL h := oCtrl:handle
   LOCAL id := oCtrl:id
   LOCAL i := Ascan(::aControls, {|o|hwg_Isptreq(o:handle, h)})

   hwg_Sendmessage(h, WM_CLOSE, 0, 0)
   IF i != 0
      ADel(::aControls, i)
      ASize(::aControls, Len(::aControls) - 1)
   ENDIF

   h := 0
   FOR i := Len(::aEvents) TO 1 STEP -1
      IF ::aEvents[i, 2] == id
         ADel(::aEvents, i)
         h++
      ENDIF
   NEXT

   IF h > 0
      ASize(::aEvents, Len(::aEvents) - h)
   ENDIF

   h := 0
   FOR i := Len(::aNotify) TO 1 STEP -1
      IF ::aNotify[i, 2] == id
         ADel(::aNotify, i)
         h++
      ENDIF
   NEXT

   IF h > 0
      ASize(::aNotify, Len(::aNotify) - h)
   ENDIF

   RETURN NIL

METHOD Move(x1, y1, width, height) CLASS HCustomWindow

   IF x1     != NIL
      ::nLeft   := x1
   ENDIF
   IF y1     != NIL
      ::nTop    := y1
   ENDIF
   IF width  != NIL
      ::nWidth  := width
   ENDIF
   IF height != NIL
      ::nHeight := height
   ENDIF
   hwg_Movewindow(::handle, ::nLeft, ::nTop, ::nWidth, ::nHeight)

   RETURN NIL

METHOD Refresh() CLASS HCustomWindow

   hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)

   RETURN NIL

METHOD SetColor(tcolor, bColor, lRepaint) CLASS HCustomWindow

   IF tcolor != NIL
      ::tcolor := tcolor
      IF bColor == NIL .AND. ::bColor == NIL
         bColor := hwg_Getsyscolor(COLOR_3DFACE)
      ENDIF
   ENDIF

   IF bColor != NIL
      ::bColor := bColor
      IF ::brush != NIL
         ::brush:Release()
      ENDIF
      ::brush := HBrush():Add(bColor)
   ENDIF

   IF lRepaint != NIL .AND. lRepaint
      hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE)
   ENDIF

   RETURN NIL

#if 0
METHOD onEvent(msg, wParam, lParam)  CLASS HCustomWindow
   LOCAL i
   STATIC iCount := 0

   IF ++iCount == 7
      iCount := 0
      hb_gcStep()
   ENDIF

   IF ( i := Ascan(aCustomEvents[EVENTS_MESSAGES], msg) ) != 0
      RETURN Eval(aCustomEvents[EVENTS_ACTIONS, i], Self, wParam, lParam)

   ELSEIF ::bOther != NIL

      RETURN Eval(::bOther, Self, msg, wParam, lParam)

   ENDIF

   RETURN -1
#endif

METHOD onEvent(msg, wParam, lParam)  CLASS HCustomWindow

   SWITCH msg
   CASE WM_NOTIFY         ; RETURN Eval({|o, w, l|onNotify(o, w, l)}, Self, wParam, lParam)
   CASE WM_PAINT          ; RETURN Eval({|o, w|iif(o:bPaint != NIL, Eval(o:bPaint, o, w), -1)}, Self, wParam, lParam)
   CASE WM_CTLCOLORSTATIC ; RETURN Eval({|o, w, l|onCtlColor(o, w, l)}, Self, wParam, lParam)
   CASE WM_CTLCOLOREDIT   ; RETURN Eval({|o, w, l|onCtlColor(o, w, l)}, Self, wParam, lParam)
   CASE WM_CTLCOLORBTN    ; RETURN Eval({|o, w, l|onCtlColor(o, w, l)}, Self, wParam, lParam)
   CASE WM_COMMAND        ; RETURN Eval({|o, w, l|onCommand(o, w, l)}, Self, wParam, lParam)
   CASE WM_DRAWITEM       ; RETURN Eval({|o, w, l|onDrawItem(o, w, l)}, Self, wParam, lParam)
   CASE WM_SIZE           ; RETURN Eval({|o, w, l|onSize(o, w, l)}, Self, wParam, lParam)
   CASE WM_DESTROY        ; RETURN Eval({|o|onDestroy(o)}, Self, wParam, lParam)
   OTHERWISE
      IF ::bOther != NIL
         RETURN Eval(::bOther, Self, msg, wParam, lParam)
      ENDIF
   ENDSWITCH

   RETURN -1

METHOD End()  CLASS HCustomWindow

   LOCAL aControls
   LOCAL i
   LOCAL nLen

   IF ::nHolder != 0
      ::nHolder := 0
      hwg_DecreaseHolders(::handle)
      aControls := ::aControls
      nLen := Len(aControls)
      FOR i := 1 TO nLen
         aControls[i]:End()
      NEXT
   ENDIF

   RETURN NIL

METHOD OnError() CLASS HCustomWindow

   LOCAL cMsg := __GetMessage()
   LOCAL oError
   LOCAL oItem

   IF !Empty(oItem := hwg_GetItemByName(::aControls, cMsg))
      RETURN oItem
   ENDIF
   FOR EACH oItem IN HTimer():aTimers
      IF !Empty(oItem:objname) .AND. oItem:objname == cMsg .AND. hwg_Isptreq(::handle, oItem:oParent:handle)
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

   Eval(ErrorBlock(), oError)
   __errInHandler()

   RETURN NIL

STATIC FUNCTION onNotify(oWnd, wParam, lParam)

   LOCAL iItem
   LOCAL oCtrl
   LOCAL nCode
   LOCAL res
   LOCAL n

   // Not used parameter
   // (lParam)

   wParam := hwg_PtrToUlong(wParam)
   IF Empty(oCtrl := oWnd:FindControl(wParam))
      FOR n := 1 TO Len(oWnd:aControls)
         oCtrl := oWnd:aControls[n]:FindControl(wParam)
         IF oCtrl != NIL
            EXIT
         ENDIF
      NEXT
   ENDIF

   IF oCtrl != NIL

      IF __ObjHasMsg(oCtrl, "NOTIFY")
         RETURN oCtrl:Notify(lParam)
      ELSE
         nCode := hwg_Getnotifycode(lParam)
         IF nCode == EN_PROTECTED
            RETURN 1
         ELSEIF oWnd:aNotify != NIL .AND. ( iItem := Ascan(oWnd:aNotify, {|a|a[1] == nCode .AND. a[2] == wParam}) ) > 0
            IF ( res := Eval(oWnd:aNotify[iItem, 3], oWnd, wParam) ) != NIL
               RETURN res
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   RETURN -1

STATIC FUNCTION onDestroy(oWnd)

   LOCAL aControls := oWnd:aControls
   LOCAL i
   LOCAL nLen := Len(aControls)

   FOR i := 1 TO nLen
      aControls[i]:End()
   NEXT
   oWnd:End()

   RETURN 1

STATIC FUNCTION onCtlColor(oWnd, wParam, lParam)

   LOCAL oCtrl := oWnd:FindControl(NIL, lParam)

   IF oCtrl != NIL
      IF oCtrl:tcolor != NIL
         hwg_Settextcolor(wParam, oCtrl:tcolor)
      ENDIF

      //hwg_writelog(octrl:classname)
      IF hb_bitand(oCtrl:extStyle, WS_EX_TRANSPARENT) != 0
         hwg_SetTransparentMode(wParam, .T.)
         RETURN 0  //hwg_getBackBrush(oWnd:handle)
      ELSE
         IF oCtrl:bcolor != NIL
            hwg_Setbkcolor(wParam, oCtrl:bcolor)
            RETURN oCtrl:brush:handle
         ENDIF
      ENDIF
   ENDIF

   RETURN -1

STATIC FUNCTION onDrawItem(oWnd, wParam, lParam)

   LOCAL oCtrl

   wParam := hwg_PtrToUlong(wParam)
   IF wParam != 0 .AND. (oCtrl := oWnd:FindControl(wParam)) != NIL .AND. oCtrl:bPaint != NIL
      Eval(oCtrl:bPaint, oCtrl, lParam)
      RETURN 1

   ENDIF

   RETURN -1

STATIC FUNCTION onCommand(oWnd, wParam, lParam)

   LOCAL iItem
   LOCAL iParHigh := hwg_Hiword(wParam)
   LOCAL iParLow := hwg_Loword(wParam)

   HB_SYMBOL_UNUSED(lParam)

   IF oWnd:aEvents != NIL .AND. ( iItem := Ascan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow}) ) > 0
      Eval(oWnd:aEvents[iItem, 3], oWnd, iParLow)
   ENDIF

   RETURN 1

STATIC FUNCTION onSize(oWnd, wParam, lParam)

   LOCAL aControls := oWnd:aControls
   LOCAL oItem

   HB_SYMBOL_UNUSED(wParam)

   FOR EACH oItem IN aControls
      IF oItem:bSize != NIL
         //  { |o, w, l| onSize(o, w, l) }
         Eval(oItem:bSize, oItem, hwg_Loword(lParam), hwg_Hiword(lParam))
      ENDIF
   NEXT

   RETURN -1

FUNCTION hwg_onTrackScroll(oWnd, msg, wParam, lParam)

   LOCAL oCtrl := oWnd:FindControl(NIL, lParam)

   IF oCtrl != NIL
      msg := hwg_Loword(wParam)
      SWITCH msg
      CASE TB_ENDTRACK
         IF HB_ISBLOCK(oCtrl:bChange)
            Eval(oCtrl:bChange, oCtrl)
            RETURN 0
         ENDIF
         EXIT
      CASE TB_THUMBTRACK
      CASE TB_PAGEUP
      CASE TB_PAGEDOWN
         IF HB_ISBLOCK(oCtrl:bThumbDrag)
            Eval(oCtrl:bThumbDrag, oCtrl)
            RETURN 0
         ENDIF
      ENDSWITCH
   ELSE
      IF HB_ISBLOCK(oWnd:bScroll)
         Eval(oWnd:bScroll, oWnd, msg, wParam, lParam)
         RETURN 0
      ENDIF
   ENDIF

   RETURN -1

FUNCTION hwg_GetItemByName(arr, cName)

   LOCAL oItem

   FOR EACH oItem IN arr
      IF !Empty(oItem:objname) .AND. oItem:objname == cName
         RETURN oItem
      ENDIF
   NEXT

   RETURN NIL
