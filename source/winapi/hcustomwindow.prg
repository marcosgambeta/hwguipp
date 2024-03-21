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

CLASS HCustomWindow INHERIT HObject

   CLASS VAR oDefaultParent SHARED

   DATA handle INIT 0
   DATA oParent
   DATA title
   DATA TYPE
   DATA nTop // deprecated - use nY
   ACCESS nY INLINE ::nTop
   ASSIGN nY(n) INLINE ::nTop := n
   DATA nLeft // deprecated - use nX
   ACCESS nX INLINE ::nLeft
   ASSIGN nX(n) INLINE ::nLeft := n
   DATA nWidth
   DATA nHeight
   DATA tcolor
   DATA bcolor
   DATA brush
   DATA style
   DATA extStyle INIT 0
   DATA lHide INIT .F.
   DATA oFont
   DATA aEvents INIT {}
   DATA aNotify INIT {}
   DATA aControls INIT {}
   DATA bInit
   DATA bDestroy
   DATA bSize
   DATA bPaint
   DATA bGetFocus
   DATA bLostFocus
   DATA bOther
   DATA HelpId INIT 0
   DATA nHolder INIT 0
   DATA nChildId INIT 34000

   METHOD AddControl(oCtrl) INLINE AAdd(::aControls, oCtrl)
   METHOD DelControl(oCtrl)
   METHOD AddEvent(nEvent, nId, bAction, lNotify) INLINE AAdd(iif(lNotify == NIL .OR. !lNotify, ::aEvents, ::aNotify), {nEvent, nId, bAction})
   METHOD FindControl(nId, nHandle)
   METHOD Hide()
   METHOD Show()
   METHOD Refresh()
   METHOD Move(x1, y1, width, height)
   METHOD SetColor(tcolor, bColor, lRepaint)
   METHOD onEvent(msg, wParam, lParam)
   METHOD End()
   ERROR HANDLER OnError()

ENDCLASS

METHOD HCustomWindow:FindControl(nId, nHandle)

   LOCAL i

   IF HB_ISCHAR(nId)
      nId := Upper(nId)
      RETURN hwg_GetItemByName(::aControls, nId)
   ELSE
      i := Iif(nId != NIL, Ascan(::aControls, {|o|o:id == nId}), Ascan(::aControls, {|o|hwg_Isptreq(o:handle, nHandle)}))
   ENDIF

   RETURN Iif(i == 0, NIL, ::aControls[i])

METHOD HCustomWindow:DelControl(oCtrl)

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

METHOD HCustomWindow:SetColor(tcolor, bColor, lRepaint)

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

METHOD HCustomWindow:onEvent(msg, wParam, lParam)

   SWITCH msg
   CASE WM_NOTIFY         ; RETURN onNotify(Self, wParam, lParam)
   CASE WM_PAINT          ; RETURN iif(hb_IsBlock(::bPaint), Eval(::bPaint, Self, wParam), -1)
   CASE WM_CTLCOLORSTATIC ; RETURN onCtlColor(Self, wParam, lParam)
   CASE WM_CTLCOLOREDIT   ; RETURN onCtlColor(Self, wParam, lParam)
   CASE WM_CTLCOLORBTN    ; RETURN onCtlColor(Self, wParam, lParam)
   CASE WM_COMMAND        ; RETURN onCommand(Self, wParam, lParam)
   CASE WM_DRAWITEM       ; RETURN onDrawItem(Self, wParam, lParam)
   CASE WM_SIZE           ; RETURN onSize(Self, wParam, lParam)
   CASE WM_DESTROY        ; RETURN onDestroy(Self)
   OTHERWISE
      IF hb_IsBlock(::bOther)
         RETURN Eval(::bOther, Self, msg, wParam, lParam)
      ENDIF
   ENDSWITCH

   RETURN -1

METHOD HCustomWindow:End()

   LOCAL aControls
   LOCAL i
   LOCAL nLen

   IF ::nHolder != 0
      ::nHolder := 0
      hwg_DecreaseHolders(::handle)
      // TODO: FOR EACH
      aControls := ::aControls
      nLen := Len(aControls)
      FOR i := 1 TO nLen
         aControls[i]:End()
      NEXT
   ENDIF

   RETURN NIL

METHOD HCustomWindow:OnError()

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
   oError:severity := ES_ERROR
   oError:genCode := EG_LIMIT
   oError:subSystem := "HCUSTOMWINDOW"
   oError:subCode := 0
   oError:description := "Invalid class member"
   oError:canRetry := .F.
   oError:canDefault := .F.
   oError:fileName := ""
   oError:osCode := 0

   Eval(ErrorBlock(), oError)
   __errInHandler()

   RETURN NIL

STATIC FUNCTION onNotify(oWnd, wParam, lParam)

   LOCAL iItem
   LOCAL oCtrl
   LOCAL nCode
   LOCAL res
   LOCAL n

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

   // TODO: FOR EACH
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
   IF wParam != 0 .AND. (oCtrl := oWnd:FindControl(wParam)) != NIL .AND. hb_IsBlock(oCtrl:bPaint)
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
      IF hb_IsBlock(oItem:bSize)
         //  {|o, w, l|onSize(o, w, l)}
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
         IF hb_IsBlock(oCtrl:bChange)
            Eval(oCtrl:bChange, oCtrl)
            RETURN 0
         ENDIF
         EXIT
      CASE TB_THUMBTRACK
      CASE TB_PAGEUP
      CASE TB_PAGEDOWN
         IF hb_IsBlock(oCtrl:bThumbDrag)
            Eval(oCtrl:bThumbDrag, oCtrl)
            RETURN 0
         ENDIF
      ENDSWITCH
   ELSE
      IF hb_IsBlock(oWnd:bScroll)
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

#pragma BEGINDUMP

#define HB_OS_WIN_32_USED

#define OEMRESOURCE

#include "hwingui.hpp"
#include <commctrl.h>
#include <winuser.h>
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include <hbstack.hpp>
#include <hbapicls.hpp>
/* Suppress compiler warnings */
#include "incomp_pointer.hpp"
#include "warnings.hpp"

HB_FUNC_STATIC( HCUSTOMWINDOW_MOVE )
{
   auto self = hb_stackSelfItem();

   if( HB_ISNUM(1) ) {
      hb_objDataPutNI(self, "_NX", hb_parni(1));
   }

   if( HB_ISNUM(2) ) {
      hb_objDataPutNI(self, "_NY", hb_parni(2));
   }

   if( HB_ISNUM(3) ) {
      hb_objDataPutNI(self, "_NWIDTH", hb_parni(3));
   }

   if( HB_ISNUM(4) ) {
      hb_objDataPutNI(self, "_NHEIGHT", hb_parni(4));
   }

   MoveWindow(static_cast<HWND>(hb_objDataGetPtr(self, "HANDLE")),
              hb_objDataGetNI(self, "NX"),
              hb_objDataGetNI(self, "NY"),
              hb_objDataGetNI(self, "NWIDTH"),
              hb_objDataGetNI(self, "NHEIGHT"),
              TRUE);
}

HB_FUNC_STATIC( HCUSTOMWINDOW_HIDE )
{
   auto self = hb_stackSelfItem();
   hb_objDataPutL(self, "_LHIDE", true);
   ShowWindow(static_cast<HWND>(hb_objDataGetPtr(self, "HANDLE")), SW_HIDE);
}

HB_FUNC_STATIC( HCUSTOMWINDOW_SHOW )
{
   auto self = hb_stackSelfItem();
   hb_objDataPutL(self, "_LHIDE", false);
   ShowWindow(static_cast<HWND>(hb_objDataGetPtr(self, "HANDLE")), SW_SHOW);
}

HB_FUNC_STATIC( HCUSTOMWINDOW_REFRESH )
{
   RedrawWindow(static_cast<HWND>(hb_objDataGetPtr(hb_stackSelfItem(), "HANDLE")), nullptr, nullptr, RDW_ERASE | RDW_INVALIDATE | RDW_INTERNALPAINT | RDW_UPDATENOW);
}

#pragma ENDDUMP
