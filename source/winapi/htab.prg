/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HTab class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

CLASS HTab INHERIT HControl

   CLASS VAR winclass INIT "SysTabControl32"
   
   DATA aTabs
   DATA aPages INIT {}
   DATA bChange, bChange2
   DATA hIml, aImages, Image1, Image2
   DATA oTemp
   DATA bAction
   DATA lResourceTab INIT .F.

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, aTabs, bChange, aImages, lResour, nBC, bClick, bGetFocus, bLostFocus)
   METHOD Activate()
   METHOD Init()
   //METHOD onEvent(msg, wParam, lParam)
   METHOD SetTab(n)
   METHOD StartPage(cName, oDlg)
   METHOD EndPage()
   METHOD ChangePage(nPage)
   METHOD DeletePage(nPage)
   METHOD HidePage(nPage)
   METHOD ShowPage(nPage)
   METHOD GetActivePage(nFirst, nEnd)
   METHOD Notify(lParam)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aItem)

   HIDDEN:
   DATA nActive INIT 0         // Active Page

ENDCLASS

METHOD HTab:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, aTabs, bChange, aImages, lResour, nBC, bClick, bGetFocus, bLostFocus)
   
   LOCAL i
   LOCAL aBmpSize

   nStyle   := hb_bitor(iif(nStyle == NIL, 0, nStyle), WS_CHILD + WS_VISIBLE + WS_TABSTOP)
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint)

   ::title   := ""
   ::oFont   := iif(oFont == NIL, ::oParent:oFont, oFont)
   ::aTabs   := iif(aTabs == NIL, {}, aTabs)
   ::bChange := bChange
   ::bChange2 := bChange

   ::bGetFocus := iif(bGetFocus == NIL, NIL, bGetFocus)
   ::bLostFocus := iif(bLostFocus == NIL, NIL, bLostFocus)
   ::bAction   := iif(bClick == NIL, NIL, bClick)

   IF aImages != NIL
      ::aImages := {}
      FOR i := 1 TO Len(aImages)
         AAdd(::aImages, Upper(aImages[i]))
         aImages[i] := iif(lResour, hwg_Loadbitmap(aImages[i]), hwg_Openbitmap(aImages[i]))
      NEXT
      aBmpSize := hwg_Getbitmapsize(aImages[1])
      ::himl := hwg_Createimagelist(aImages, aBmpSize[1], aBmpSize[2], 12, nBC)
      ::Image1 := 0
      IF Len(aImages) > 1
         ::Image2 := 1
      ENDIF
   ENDIF

   ::Activate()

   RETURN Self

METHOD HTab:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createtabcontrol(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HTab:Init()
   
   LOCAL i

   IF !::lInit
      ::Super:Init()
      hwg_Inittabcontrol(::handle, ::aTabs, IIF(::himl != NIL, ::himl, 0))
      ::nHolder := 1
      hwg_Setwindowobject(::handle, Self)

      IF ::himl != NIL
         hwg_Sendmessage(::handle, TCM_SETIMAGELIST, 0, ::himl)
      ENDIF

      FOR i := 2 TO Len(::aPages)
         ::HidePage(i)
      NEXT
      Hwg_InitTabProc(::handle)
   ENDIF

   RETURN NIL
/*
METHOD HTab:onEvent(msg, wParam, lParam)

   LOCAL iParHigh
   LOCAL iParLow
   LOCAL nPos

   IF msg == WM_COMMAND
      IF ::aEvents != NIL
         iParHigh := hwg_Hiword(wParam)
         iParLow  := hwg_Loword(wParam)
         IF ( nPos := Ascan(::aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow}) ) > 0
            Eval(::aEvents[nPos, 3], Self, iParLow)
         ENDIF
      ENDIF
   ENDIF

   Return - 1
*/
METHOD HTab:SetTab(n)

   hwg_Sendmessage(::handle, TCM_SETCURFOCUS, n - 1, 0)

   RETURN NIL

METHOD HTab:StartPage(cname, oDlg)

   ::oTemp := ::oDefaultParent
   ::oDefaultParent := Self

   IF Len(::aTabs) > 0 .AND. Len(::aPages) == 0
      ::aTabs := {}
   ENDIF
   AAdd(::aTabs, cname)
   if ::lResourceTab
      AAdd(::aPages, {oDlg, 0})
   ELSE
      AAdd(::aPages, {Len(::aControls), 0})
   ENDIF
   IF ::nActive > 1 .AND. !Empty(::handle)
      ::HidePage(::nActive)
   ENDIF
   ::nActive := Len(::aPages)

   RETURN NIL

METHOD HTab:EndPage()

   IF !::lResourceTab
      ::aPages[::nActive, 2] := Len(::aControls) - ::aPages[::nActive, 1]
      IF !Empty(::handle)
         hwg_Addtab(::handle, ::nActive, ::aTabs[::nActive])
      ENDIF
   ELSE
      IF !Empty(::handle != NIL)
         hwg_Addtabdialog(::handle, ::nActive, ::aTabs[::nActive], ::aPages[::nactive, 1]:handle)
      ENDIF
   ENDIF

   IF ::nActive > 1 .AND. !Empty(::handle)
      ::HidePage(::nActive)
   ENDIF
   ::nActive := 1

   ::oDefaultParent := ::oTemp
   ::oTemp := NIL

   ::bChange = {|o, n|o:ChangePage(n)}

   RETURN NIL

METHOD HTab:ChangePage(nPage)

   IF !Empty(::aPages)
      ::HidePage(::nActive)
      ::nActive := nPage
      ::ShowPage(::nActive)
   ENDIF

   IF HB_ISBLOCK(::bChange2)
      Eval(::bChange2, Self, nPage)
   ENDIF

   RETURN NIL

METHOD HTab:HidePage(nPage)
   
   LOCAL i
   LOCAL nFirst
   LOCAL nEnd

   IF !::lResourceTab
      nFirst := ::aPages[nPage, 1] + 1
      nEnd   := ::aPages[nPage, 1] + ::aPages[nPage, 2]
      FOR i := nFirst TO nEnd
         ::aControls[i]:Hide()
      NEXT
   ELSE
      ::aPages[nPage, 1]:Hide()
   ENDIF

   RETURN NIL

METHOD HTab:ShowPage(nPage)
   
   LOCAL i
   LOCAL nFirst
   LOCAL nEnd

   IF !::lResourceTab
      nFirst := ::aPages[nPage, 1] + 1
      nEnd   := ::aPages[nPage, 1] + ::aPages[nPage, 2]
      FOR i := nFirst TO nEnd
         ::aControls[i]:Show()
      NEXT
      FOR i := nFirst TO nEnd
         IF __ObjHasMsg(::aControls[i], "BSETGET") .AND. ::aControls[i]:bSetGet != NIL
            hwg_Setfocus(::aControls[i]:handle)
            EXIT
         ENDIF
      NEXT
   ELSE
      ::aPages[nPage, 1]:Show()
      FOR i := 1  TO Len(::aPages[nPage, 1]:aControls)
         IF __ObjHasMsg(::aPages[nPage, 1]:aControls[i], "BSETGET") .AND. ::aPages[nPage, 1]:aControls[i]:bSetGet != NIL
            hwg_Setfocus(::aPages[nPage, 1]:aControls[i]:handle)
            EXIT
         ENDIF
      NEXT
   ENDIF

   RETURN NIL

METHOD HTab:GetActivePage(nFirst, nEnd)

   IF !::lResourceTab
      IF !Empty(::aPages)
         nFirst := ::aPages[::nActive, 1] + 1
         nEnd   := ::aPages[::nActive, 1] + ::aPages[::nActive, 2]
      ELSE
         nFirst := 1
         nEnd   := Len(::aControls)
      ENDIF
   ENDIF

   Return ::nActive

METHOD HTab:DeletePage(nPage)

   LOCAL nFirst
   LOCAL nEnd
   LOCAL i

   if ::lResourceTab
      ADel(::m_arrayStatusTab, nPage, NIL, .T.)
      hwg_Deletetab(::handle, nPage)
      ::nActive := nPage - 1

   ELSE

      nFirst := ::aPages[nPage, 1] + 1
      nEnd   := ::aPages[nPage, 1] + ::aPages[nPage, 2]
      FOR i := nEnd TO nFirst STEP -1
         ::DelControl(::aControls[i])
      NEXT
      FOR i := nPage + 1 TO Len(::aPages)
         ::aPages[i, 1] -= ( nEnd-nFirst+1 )
      NEXT

      hwg_Deletetab(::handle, nPage - 1)

      ADel(::aPages, nPage)
      ASize(::aPages, Len(::aPages) - 1)

      ADel(::aTabs, nPage)
      ASize(::aTabs, Len(::aTabs) - 1)

      IF nPage > 1
         ::nActive := nPage - 1
         ::SetTab(::nActive)
      ELSEIF Len(::aPages) > 0
         ::nActive := 1
         ::SetTab(1)
      ENDIF
   ENDIF

   Return ::nActive

METHOD HTab:Notify(lParam)
   
   LOCAL nCode := hwg_Getnotifycode(lParam)

   //hwg_writelog(str(ncode))
   SWITCH nCode
   CASE TCN_SELCHANGE
      IF HB_ISBLOCK(::bChange)
         Eval(::bChange, Self, hwg_Getcurrenttab(::handle))
      ENDIF
      EXIT
   CASE TCN_CLICK
      IF HB_ISBLOCK(::bAction)
         Eval(::bAction, Self, hwg_Getcurrenttab(::handle))
      ENDIF
      EXIT
   CASE TCN_SETFOCUS
      IF HB_ISBLOCK(::bGetFocus)
         Eval(::bGetFocus, Self, hwg_Getcurrenttab(::handle))
      ENDIF
      EXIT
   CASE TCN_KILLFOCUS
      IF HB_ISBLOCK(::bLostFocus)
         Eval(::bLostFocus, Self, hwg_Getcurrenttab(::handle))
      ENDIF
   ENDSWITCH

   Return - 1

/* aItem and cCaption added */
METHOD HTab:Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aItem)

   HB_SYMBOL_UNUSED(cCaption)
   HB_SYMBOL_UNUSED(lTransp)
   HB_SYMBOL_UNUSED(aItem)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()
   ::lResourceTab := .T.
   ::aTabs := {}
   ::style := ::nX := ::nY := ::nWidth := ::nHeight := 0

   RETURN Self
