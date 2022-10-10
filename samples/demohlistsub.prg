/*
 * HWGUI - Harbour Win32 and Linux (GTK) GUI library
 *
 *  demohlistsub.prg
 *
 * Sample for substite of listbox usage:
 * Use BROWSE of an array instead for
 * multi platform use. 
 *
 * Copyright 2020 Wilfried Brunken, DF7BE 
 * https://sourceforge.net/projects/cllog/
 * Copied from sample "demohlist.prg".
 */
 
   * Status:
    *  WinAPI   :  Yes
    *  GTK/Linux:  Yes
    *  GTK/Win  :  Yes  

#include "windows.ch" 
#include "guilib.ch"
// #include "listbox.ch"


Function Main
Local oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Example" ;
     AT 0,0 SIZE hwg_Getdesktopwidth(), hwg_Getdesktopheight() - 28
   // MENUITEM in main menu on GTK/Linux does not start the desired action 
   // Submenu needed 
   MENU OF oMainWindow
      MENU TITLE "&Exit"
        MENUITEM "&Quit" ACTION oMainWindow:Close()
      ENDMENU
      MENU TITLE "&Teste"
        MENUITEM "&Do it" ACTION Teste()
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oMainWindow
Return NIL

Function Teste
Local oModDlg, oFont, obrowsbox1, nPosi, cResult
Local oList, oItemso := { { "Item01" } , { "Item02" } , { "Item03" } , { "Item04" } }
// Array oItemso is a 2 dimensional array with one "column". 

   nPosi   := 0
   cResult := ""

#ifdef __PLATFORM__WINDOWS
   PREPARE FONT oFont NAME "MS Sans Serif" WIDTH 0 HEIGHT -13
#else
   PREPARE FONT oFont NAME "Sans" WIDTH 0 HEIGHT 12 // vorher 13
#endif 

   INIT DIALOG oModDlg TITLE "Test"  ;
   AT 0,0  SIZE 450,350   ;
   FONT oFont

   // Please dimensionize size of BROWSE window so that it is enough space to display
   // all items in oItemso with additional reserve about 20 pixels.
   @ 34,56  BROWSE obrowsbox1  ARRAY oList SIZE 210, 220 FONT oFont  ;
                   STYLE WS_BORDER  // NO VSCROLL   
    obrowsbox1:aArray := ConvItems(oItemso) // Fill browse box with all items
    obrowsbox1:AddColumn( HColumn():New("Listbox", {|v,o|o:aArray[o:nCurrent, 1]}, "C", 10, 0))
    obrowsbox1:lEditable := .F.
    obrowsbox1:lDispHead := .F. // No Header
    obrowsbox1:active := .T.

   @  10,280 BUTTON "Ok" ID IDOK  SIZE 50, 32
    ACTIVATE DIALOG oModDlg
    oFont:Release()

   // Get result 
   nPosi   := obrowsbox1:nCurrent
   cResult := obrowsbox1:aArray[nPosi,1]   
   // show result
   hwg_msgInfo("Position: " + STR(nPosi) + " Value: " + cResult,"Result of Listbox selection")

   IF oModDlg:lResult
    ENDIF
Return NIL

* --------------------------------------------
STATIC FUNCTION ConvItems( ap )
* areal value, not a pointer
* --------------------------------------------
LOCAL a
 a := ap
RETURN a
