/*
 *
 * helpstatic.prg
 *
 * HWGUI - Harbour Win32 GUI and GTK library source code:
 * Sample for help window using static help text
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 * Copyright 2021 Wilfried Brunken, DF7BE
*/

   * Status:
    *  WinAPI   :  Yes
    *  GTK/Linux:  Yes
    *  GTK/Win  :  Yes

/*
 Additional instructions for editing static help texts:
 - Tail every line with CRLF (0x0d + 0x0a);
 - Check your text in your program, if the line is too long,
   the rest of the line is truncated. So another line feed
   must be inserted;
 - Compile this sample program on LINUX/UNIX with Harbour compile option
   -d__LINUX__, so UTF8 is strictly used.
   Or try function hwg__isUnicode().
 - The not modal call of this function has the avantage, that you can read the help text
   and continue the work in your programm. And it is possible, to display
   more than one help windows with differnt items.
*/

MEMVAR CAGUML, COGUML , CUGUML , CAKUML, COKUML , CUKUML , CSZUML , EURO

#include "hwguipp.ch"
#ifdef __GTK__
#include "gtk.ch"
#endif
#ifdef __XHARBOUR__
   #include "ttable.ch"
#endif

* ==============================================
FUNCTION MAIN
* ============================================== 

LOCAL oMain , oFontMain 


#ifdef __PLATFORM__WINDOWS
   PREPARE FONT oFontMain NAME "MS Sans Serif" WIDTH 0 HEIGHT -14
#else
   PREPARE FONT oFontMain NAME "Sans" WIDTH 0 HEIGHT 12 
#endif

        INIT WINDOW oMain MAIN TITLE "" ;
        FONT oFontMain SIZE 200, 100

* Main Menu
        MENU OF oMain
         MENU TITLE "&File" 
             MENUITEM "&Quit" ACTION {|| oMain:Close() }
         ENDMENU
         MENU TITLE "&Help" 
             MENUITEM "&Not modal" ACTION display_Help(.T.)
             MENUITEM "&Modal" ACTION display_Help(.F.)
         ENDMENU
        ENDMENU
        ACTIVATE WINDOW oMain

RETURN NIL

* ======================================================
*  FUNCTIONS
* ======================================================

* ==============================================
FUNCTION display_Help(lmode)
* cHelptxt,cTitle,cClose,opFont,blmodus
* ==============================================
IF lmode == NIL
 lmode := .T.  // not modal
ENDIF 

  hwg_ShowHelp(helptxt(),"Static Help text","Close",,lmode)
RETURN NIL 

* ==============================================
FUNCTION helptxt()
* Returns the static help text to display
* This sample especially for german special
* characters (Umlaute)
* ==============================================
LOCAL lf := Chr(13) + Chr(10)
LOCAL aUmlaute
LOCAL CAGUML, COGUML , CUGUML , CAKUML, COKUML , CUKUML , CSZUML , EURO
aUmlaute := UML_GUI_INIT_DE()
CAGUML := aUmlaute[1]
COGUML := aUmlaute[2]
CUGUML := aUmlaute[3]
CAKUML := aUmlaute[4]
COKUML := aUmlaute[5]
CUKUML := aUmlaute[6]
CSZUML := aUmlaute[7]
EURO   := aUmlaute[8]
RETURN "Line 1 of help text" + lf + ;
       "Line 2 of help text" + lf + ;
       "German Umlaute: " + CAGUML + " " + COGUML + " " + CUGUML + " " + CAKUML + " " + ;
         COKUML + " " + CUKUML + lf + ;
       "German sharp S: " + CSZUML + lf + ;
       "Euro currency sign: " + EURO
       
       

* ==============================================
FUNCTION UML_GUI_INIT_DE
* Initialisation sequence for GUI (messages)
* Umlaute and Euro Currency sign
* ==============================================
LOCAL aUmlaute := {}
#ifdef __LINUX__
* Linux / UTF8
CAGUML := "Ä"  // AE
COGUML := "Ö"  // OE
CUGUML := "Ü"  // UE
CAKUML := "ä"  // AE
COKUML := "ö"  // OE
CUKUML := "ü"  // UE
CSZUML := "ß"  // SZ
EURO   := "€"
#else
* Windows (WIN1252)
CAGUML := Chr(196)  // AE
COGUML := Chr(214)  // OE
CUGUML := Chr(220)  // UE
CAKUML := Chr(228)  // AE
COKUML := Chr(246)  // OE
CUKUML := Chr(252)  // UE
CSZUML := Chr(223)  // SZ
EURO   := Chr(128)
#endif

AADD(aUmlaute, CAGUML )  // AE
AADD(aUmlaute, COGUML )  // OE
AADD(aUmlaute, CUGUML )  // UE
AADD(aUmlaute, CAKUML )  // AE
AADD(aUmlaute, COKUML )  // OE
AADD(aUmlaute, CUKUML )  // UE
AADD(aUmlaute, CSZUML )  // SZ
AADD(aUmlaute, EURO )


RETURN aUmlaute
