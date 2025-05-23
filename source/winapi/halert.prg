//
// halert.prg
//
// HWGUI - Harbour Win32 GUI library source code:
// alert() replacement.
//
// Copyright 2005,2020 Alex Strickland <sscc@mweb.co.za>
//

// $BEGIN_LICENSE$
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this software; see the file COPYING.  If not, write to
// the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
// Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
//
// As a special exception, you have permission for
// additional uses of the text contained in its release of HWGUI.
//
// The exception is that, if you link the HWGUI library with other
// files to produce an executable, this does not by itself cause the
// resulting executable to be covered by the GNU General Public License.
// Your use of that executable is in no way restricted on account of
// linking the HWGUI library code into it.
// $END_LICENSE$

// An attempt to replicate the Clipper Alert() in the style of Windows MessageBox(). I have not studied
// Alert() very carefully (or MessageBox() for that matter). It is nice to just call alert("hello") and
// you get what you expect from Clipper.
//
// Not thread safe without your own objects - that is oAlert:Alert() is ok, alert() is not.
//
// Nice (and completely optional) add ons are:
//      Timer (in s not ms)
//      Non-modal (only one at a time though)
//      Timer and non-modal
//      Left or Centered text (or something else if you like)
//      Can display no active buttons, modal with timer - no esc, alt-f4
//      Can display no active buttons, non-modal and remove later for short processing jobs
//      Optional beep and choice of beep
//      Icon can be displayed in title bar and task bar
//      Close button and esc can be disabled - must use a button
//
// *If* you use a non-modal alert you must call ReleaseDefaultAlert() at the end of your app,
// actually if you don't, nothing bad will happen, but it isn't neat.
//
// If you have a timer with an ID of 1899, you won't be happy!

#include <hbclass.ch>
#include <common.ch>
#include "hwguipp.ch"
#include "halert.ch"

#define GW_OWNER            4
#define WS_POPUPWINDOW      (WS_POPUP + WS_BORDER + WS_SYSMENU)
#define ALERTSTYLE          WS_POPUPWINDOW + WS_VISIBLE + WS_CLIPSIBLINGS + WS_DLGFRAME + WS_OVERLAPPED + DS_3DLOOK + DS_MODALFRAME + DS_CENTER

// The "default" alert setup is stored here, and will be used when simply calling Alert()
STATIC s_soDefaultAlert

CLASS HAlert

   CLASS VAR anTimerIDs /*SHARED*/ INIT {}                 // What does SHARED do?

   PROTECT cTitle AS STRING INIT "Alert"
   PROTECT cFont AS STRING INIT "Tahoma"
   PROTECT nFontSize AS NUMERIC INIT 8
   PROTECT nCharSet AS NUMERIC INIT 0
   PROTECT nIcon AS NUMERIC INIT IDI_INFORMATION           // Feel free to use your own
   PROTECT acOptions AS ARRAY INIT {"OK"}
   PROTECT abOptionActions                                 // Can be NIL, so no types
   PROTECT nAlign AS NUMERIC INIT SS_CENTER                // MessageBox is SS_LEFT
   PROTECT lModal AS LOGIC INIT .T.
   PROTECT nTime AS NUMERIC INIT 0
   PROTECT lBeep AS LOGIC INIT .T.
   PROTECT nBeepSound AS NUMERIC INIT MB_ICONEXCLAMATION
   PROTECT lTitleIcon AS LOGIC INIT .F.
   PROTECT lCloseButton AS LOGIC INIT .T.
   PROTECT nChoice AS NUMERIC INIT 0
   PROTECT nTimerID AS NUMERIC INIT 1899                   // Should you have timers with this ID ??? Change it.
   PROTECT oDlg
   PROTECT oFont
   PROTECT oIcon
   PROTECT oTimer
   PROTECT oMessage

   ACCESS Title INLINE ::cTitle
   ASSIGN Title(cVar) INLINE ::cTitle := cVar

   ACCESS Font INLINE ::cFont
   ASSIGN Font(cVar) INLINE ::cFont := cVar

   ACCESS FontSize INLINE ::nFontSize
   ASSIGN FontSize(nVar) INLINE ::nFontSize := nVar

   ACCESS FontCharset INLINE ::nCharset
   ASSIGN FontCharset(nVar) INLINE ::nCharset := nVar

   ACCESS Icon INLINE ::nIcon
   ASSIGN Icon(nVar) INLINE ::nIcon := nVar

   ACCESS Options INLINE ::acOptions
   ASSIGN Options(acVar) INLINE ::acOptions := aclone(acVar)

   ACCESS OptionActions INLINE ::abOptionActions
   ASSIGN OptionActions(abVar) INLINE ::abOptionActions := aclone(abVar)

   ACCESS Align INLINE ::nAlign
   ASSIGN Align(nVar) INLINE ::nAlign := nVar

   ACCESS Modal INLINE ::lModal
   ASSIGN Modal(lVar) INLINE ::lModal := lVar

   ACCESS Time INLINE ::nTime
   ASSIGN Time(nVar) INLINE ::nTime := nVar

   ACCESS Beep INLINE ::lBeep
   ASSIGN Beep(lVar) INLINE ::lBeep := lVar

   ACCESS BeepSound INLINE ::nBeepSound
   ASSIGN BeepSound(nVar) INLINE ::nBeepSound := nVar

   ACCESS TitleIcon INLINE ::lTitleIcon
   ASSIGN TitleIcon(lVar) INLINE ::lTitleIcon := lVar

   ACCESS CloseButton INLINE ::lCloseButton
   ASSIGN CloseButton(lVar) INLINE ::lCloseButton := lVar

   ACCESS TimerID INLINE ::nTimerID
   ASSIGN TimerID(nVar) INLINE ::nTimerID := nVar

   ACCESS Choice INLINE ::nChoice

   METHOD Init(cTitle, cFont, nFontSize, nIcon, acOptions, nAlign, lModal, nTime, lBeep, nBeepSound, lTitleIcon, lCloseButton, abOptionActions, nCharSet)
   // Nice for SetDefaultAlert utility function
   METHOD SetVars(cTitle, cFont, nFontSize, nIcon, acOptions, nAlign, lModal, nTime, lBeep, nBeepSound, lTitleIcon, lCloseButton, abOptionActions, nCharSet)
   METHOD ResetVars()
   METHOD ReleaseNonModalAlert(lViaCode)
   METHOD SetupTimer()
   METHOD RemoveTimer(nTimerID)
   METHOD Alert(cMessage, acOptions)
   METHOD UpdateMessage(cMessage)

ENDCLASS

METHOD HAlert:Init(cTitle, cFont, nFontSize, nIcon, acOptions, nAlign, lModal, nTime, lBeep, nBeepSound, lTitleIcon, lCloseButton, abOptionActions, nCharSet)

   ::SetVars(cTitle, cFont, nFontSize, nIcon, acOptions, nAlign, lModal, nTime, lBeep, nBeepSound, lTitleIcon, lCloseButton, abOptionActions, nCharSet)

RETURN Self

METHOD HAlert:SetVars(cTitle, cFont, nFontSize, nIcon, acOptions, nAlign, lModal, nTime, lBeep, nBeepSound, lTitleIcon, lCloseButton, abOptionActions, nCharSet)

   IF cTitle != NIL
      ::Title := cTitle
   ENDIF
   IF cFont != NIL
      ::Font := cFont
   ENDIF
   IF nFontSize != NIL
      ::FontSize := nFontSize
   ENDIF
   IF nCharSet != NIL
      ::nCharSet := nCharSet
   ENDIF
   IF nIcon != NIL
      ::Icon := nIcon
   ENDIF
   IF acOptions != NIL
      ::Options := acOptions
   ENDIF
   IF nAlign != NIL
      ::Align := nAlign
   ENDIF
   IF lModal != NIL
      ::Modal := lModal
   ENDIF
   IF nTime != NIL
      ::Time := nTime
   ENDIF
   IF lBeep != NIL
      ::Beep := lBeep
   ENDIF
   IF nBeepSound != NIL
      ::BeepSound := nBeepSound
   ENDIF
   IF lTitleIcon != NIL
      ::TitleIcon := lTitleIcon
   ENDIF
   IF lCloseButton != NIL
      ::CloseButton := lCloseButton
   ENDIF
   IF abOptionActions != NIL
      ::OptionActions := abOptionActions
   ENDIF

   ::nChoice := 0

RETURN NIL

METHOD HAlert:ResetVars()

   ::Title := "Alert"
   ::Font := "Tahoma"
   ::FontSize := 8
   ::nCharSet := 0
   ::Icon := IDI_INFORMATION        // Feel free to use your own
   ::Options := {"OK"}
   ::OptionActions := NIL
   ::Align := SS_CENTER             // MessageBox is actually SS_LEFT
   ::Modal := .T.
   ::Time := 0
   ::Beep := .T.
   ::BeepSound := MB_ICONEXCLAMATION
   ::TitleIcon := .F.
   ::CloseButton := .T.

   ::nChoice := 0

RETURN NIL

METHOD HAlert:ReleaseNonModalAlert(lViaCode)

   DEFAULT lViaCode TO .T.

   IF ::oDlg != NIL
      IF lViaCode
         Hwg_DestroyWindow(::oDlg:handle)
      ENDIF
      ::oFont:Release()
      ::oIcon:Release()
      IF ::oTimer != NIL
         ::oTimer:end()
      ENDIF
      ::oDlg := NIL
   ENDIF

RETURN .T.

METHOD HAlert:SetupTimer()

   LOCAL nTimer

   IF Empty(::anTimerIDs)
      nTimer := ::TimerID
   ELSE
      nTimer := ::anTimerIDs[len(::anTimerIDs)] + 1
   ENDIF
   AAdd(::anTimerIDs, nTimer)

   // Hopefully this won't clash - a nasty error to find if it does
   // SET TIMER ::oTimer OF ::oDlg ID nTimer VALUE (::Time * 1000) ACTION {||Hwg_EndDialog(::oDlg:handle), ::RemoveTimer(nTimer)}
   ::oTimer := HTimer():New(::oDlg, nTimer, (::Time * 1000), {||Hwg_EndDialog(::oDlg:handle), ::RemoveTimer(nTimer)}) //; ::oTimer:name := "::oTimer"

RETURN NIL

METHOD HAlert:RemoveTimer(nTimerID)

   LOCAL nIDPos

   IF nIDPos := ascan(::anTimerIDs, nTimerID) > 0
      adel(::anTimerIDs, nIDPos)
      asize(::anTimerIDs, len(::anTimerIDs) - 1)
   ENDIF

RETURN .T.

METHOD HAlert:Alert(cMessage, acOptions)

   LOCAL hDC
   LOCAL hOldFont
   LOCAL i
   LOCAL nFontHeight
   LOCAL nFontWidth
   LOCAL nButtonWidth
   LOCAL nButtonLeft
   LOCAL nMessageWidth := 0
   LOCAL nMessageHeight
   LOCAL nMessageTop
   LOCAL aMessage
   LOCAL nOptions
   LOCAL nIconHeight := Hwg_GetSystemMetrics(SM_CXICON)
   LOCAL nIconWidth := Hwg_GetSystemMetrics(SM_CYICON)
   LOCAL nDialogHeight
   LOCAL nDialogWidth

   // We can't do more than one non-modal alert
   IF ::oDlg != NIL .AND. !::Modal
      RETURN 0
   ENDIF

   IF !hb_IsChar(cMessage)
      cMessage := HB_ValToStr(cMessage)
   ENDIF
   cMessage := strtran(cMessage, ";", chr(10))

   IF acOptions == NIL
      acOptions := ::Options
   ENDIF
   nOptions := len(acOptions)

   hDC := Hwg_GetDC(0)

   ::oFont := HFont():Add(::Font, 0, Hwg_Pts2Pix(-::FontSize), NIL, ::nCharSet)
   hOldFont := Hwg_SelectObject(hDC, ::oFont:handle)

   // All dimensions of the dialog are in multiples of the Font height and width
   nFontWidth := Hwg_GetTextMetric(hDC)[2]
   nFontHeight := Hwg_GetTextMetric(hDC)[1]
   // Minimum button
   nButtonWidth := nFontWidth * 15
   // Widest button (add two chars of padding)
   aeval(acOptions, {|x|nButtonWidth := max(nButtonWidth, Hwg_GetTextSize(hDC, x)[1] + 2 * nFontWidth)})
   // Widest line of text
   aeval(aMessage := StringToArray(cMessage, chr(10)), {|x|nMessageWidth := max(nMessageWidth, Hwg_GetTextSize(hDC, x)[1] + 2 * nFontWidth)})
   // Height of text
   nMessageHeight := len(aMessage) * nFontHeight

   Hwg_SelectObject(hDC, hOldFont)
   Hwg_ReleaseDC(0, hDC)

   ::oIcon := HIcon():AddResource(::Icon, NIL, NIL, NIL, .T.)

   // 1.7 seems to give the closest to MessageBox results
   nDialogHeight := nFontHeight + max(nIconHeight, nMessageHeight) + IIf(nOptions > 0, nFontHeight + 1.7 * nFontHeight, 0) + nFontHeight
   nDialogWidth := 2 * nFontWidth + max(nIconWidth + 3 * nFontWidth + nMessageWidth, nOptions * nButtonWidth + (nOptions - 1) * nFontWidth) + nFontWidth

   // Buttons smaller than icon and message?
   IF nIconWidth + 3 * nFontWidth + nMessageWidth > nOptions * nButtonWidth + (nOptions - 1) * nFontWidth
      nButtonLeft := (nDialogWidth - (nOptions * nButtonWidth + (nOptions - 1) * nFontWidth)) / 2
   ELSE
      nButtonLeft := 2 * nFontWidth
   ENDIF

   // Message shorter in y direction than icon?
   nMessageTop := nFontHeight + IIf(nMessageHeight < nIconHeight, (nIconHeight - nMessageHeight) / 2, 0)

   INIT DIALOG ::oDlg TITLE ::Title ;
      AT 0, 0 SIZE nDialogWidth, nDialogHeight ;
      ICON IIf(::lTitleIcon, ::oIcon, NIL) ;        // Visible in task switch (alt-tab) & on title bar
      STYLE ALERTSTYLE ;
      FONT ::oFont ;
      ON INIT {|oWin|Hwg_Alert_CenterWindow(oWin:handle), IIf(!::lCloseButton, hwg_Alert_DisableCloseButton(oWin:handle), NIL), IIf(::Time > 0, ::SetupTimer(), NIL)} ;
      ON EXIT {|oWin|HB_SYMBOL_UNUSED(oWin), IIf(!::Modal, ::ReleaseNonModalAlert(.F.), .T.)}

   @ 2 * nFontWidth, nFontHeight ICON ::oIcon

   @ 2 * nFontWidth + nIconWidth + 3 * nFontWidth, nMessageTop SAY ::oMessage CAPTION cMessage SIZE nMessageWidth, nMessageHeight + nFontHeight /*padding*/ STYLE /*WS_TABSTOP +*/ ::Align

   IF nOptions > 0
      @ nButtonLeft, nFontHeight + max(nIconHeight, nMessageHeight) + nFontHeight ;
         BUTTON acOptions[1] ID 100 SIZE nButtonWidth, 1.7 * nFontHeight ;
         ON CLICK {|oCtl|HB_SYMBOL_UNUSED(oCtl), ::nChoice := 1, IIf(::OptionActions != NIL, eval(::OptionActions[1]), NIL), Hwg_EndDialog(::oDlg:handle)} ;
         STYLE WS_TABSTOP + BS_DEFPUSHBUTTON
      FOR i := 2 TO nOptions
         @ nButtonLeft + (i - 1) * (nButtonWidth + nFontWidth), nFontHeight + max(nIconHeight, nMessageHeight) + nFontHeight ;
            BUTTON acOptions[i] ID i + 100 SIZE nButtonWidth, 1.7 * nFontHeight ;
            ON CLICK {|oCtl|::nChoice := oCtl:id - 100, IIf(::OptionActions != NIL, eval(::OptionActions[oCtl:id - 100]), NIL), Hwg_EndDialog(::oDlg:handle)} ;
            STYLE WS_TABSTOP
      NEXT
   ENDIF

   IF !::CloseButton
      ::oDlg:lExitOnEsc := .F.
   ENDIF

   IF ::Beep
      Hwg_MsgBeep(::BeepSound)
   ENDIF

   IF ::Modal
      ACTIVATE DIALOG ::oDlg
      // and then release ...
      ::oFont:Release()
      ::oIcon:Release()
      IF ::oTimer != NIL
         ::oTimer:end()
      ENDIF
      ::oDlg := NIL
   ELSE
      ACTIVATE DIALOG ::oDlg NOMODAL
   ENDIF

RETURN ::nChoice

METHOD HAlert:UpdateMessage(cMessage)

   cMessage := STRTRAN(cMessage, ";", Chr(10))
   //::oMessage:autosize := .T.
   ::oMessage:SetValue(cMessage)

RETURN NIL

// END OF CLASS

//
// These functions are used to manipulate the "default" alert setup.
//

FUNCTION hwg_Alert(cMessage, acOptions)

   IF s_soDefaultAlert == NIL
      s_soDefaultAlert := HAlert():New()
   ENDIF

RETURN s_soDefaultAlert:Alert(cMessage, acOptions)

PROCEDURE SetDefaultAlert(cTitle, cFont, nFontSize, nIcon, acOptions, nAlign, lModal, nTime, lBeep, nBeepSound, lTitleIcon, lCloseButton, abOptionActions)

   IF s_soDefaultAlert == NIL
      s_soDefaultAlert := HAlert():New(cTitle, cFont, nFontSize, nIcon, acOptions, nAlign, lModal, nTime, lBeep, nBeepSound, lTitleIcon, lCloseButton, abOptionActions)
   ELSE
      s_soDefaultAlert:SetVars(cTitle, cFont, nFontSize, nIcon, acOptions, nAlign, lModal, nTime, lBeep, nBeepSound, lTitleIcon, lCloseButton, abOptionActions)
   ENDIF

RETURN

PROCEDURE ResetDefaultAlert()

   IF s_soDefaultAlert == NIL
      s_soDefaultAlert := HAlert():New()
   ELSE
      s_soDefaultAlert:ResetVars()
   ENDIF

RETURN

FUNCTION hwg_GetDefaultAlert()

   IF s_soDefaultAlert == NIL
      s_soDefaultAlert := HAlert():New()
   ENDIF

RETURN s_soDefaultAlert

FUNCTION hwg_ReleaseDefaultAlert()

   IF s_soDefaultAlert != NIL
      s_soDefaultAlert:ReleaseNonModalAlert(.T.)
   ENDIF

RETURN NIL

// Utility functions

STATIC FUNCTION StringToArray(cString, cDelimiter)

   LOCAL nAt
   LOCAL aStrings := {}

   DEFAULT cDelimiter TO ","

   WHILE (nAt := at(cDelimiter, cString)) != 0
      AAdd(aStrings, substr(cString, 1, nAt - 1))
      cString := substr(cString, nAt + 1)
   END
   AAdd(aStrings, cString)

RETURN aStrings

FUNCTION HWG_Alert_CenterWindow(hWnd)
// Zentriert ein Kind-Fenster inmitten des Vater Fensters,
// als Antwort auf eine WM_INITDIALOG Nachricht.
// hWnd: Handle des Kind-Fensters.

   LOCAL hWndParent   // handle to the Parent Window
   LOCAL nCWidth      // Width of Child Window
   LOCAL nCHeight     // Height of Child Window
   LOCAL aParent      // Logical Coordinates of Parent Window  // [4]
   LOCAL aPoint       // Multiple Uses                         // [2]
   LOCAL aChild       // Screen Coordinates of Child Window    // [4]

   aChild := Hwg_GetWindowRect(hWnd)
   nCWidth := aChild[3] - aChild[1]
   nCHeight := aChild[4] - aChild[2]

   hWndParent := hwg_Alert_GetWindow(hWnd, GW_OWNER)
   IF Empty(hWndParent)
      hWndParent := Hwg_GetParent(hWnd)
   ENDIF

   IF !Hwg_IsWindowVisible(hWndParent)
      RETURN NIL
   ENDIF

   aParent := Hwg_GetClientRect(hWndParent)
   aPoint := Hwg_ClientToScreen(hWndParent, aParent[3] / 2, aParent[4] / 2)
   aPoint[1] -= (nCWidth  / 2)
   aPoint[2] -= (nCHeight / 2)
   aPoint := Hwg_ScreenToClient(hWndParent, aPoint[1], aPoint[2] )
   aPoint[1] := MAX(0, aPoint[1] )
   aPoint[2] := MAX(0, aPoint[2] )
   aPoint := Hwg_ClientToScreen(hWndParent, aPoint[1], aPoint[2])

   Hwg_MoveWindow(hWnd, aPoint[1], aPoint[2], nCWidth, nCHeight, .F.)

RETURN NIL
