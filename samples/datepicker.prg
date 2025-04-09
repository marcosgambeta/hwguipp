/*
 *
 * datepicker.prg
 *
 * HWGUI - Harbour Win32 and Linux (GTK) GUI library
 *
 * This sample demonstrates:
 * The multi platform substitute for the
 * Windows only DATEPICKER command. 
 *
 * Copyright 2006 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
 *
 * Copyright 2022 Wilfried Brunken, DF7BE 
 * https://sourceforge.net/projects/cllog/
 *
 */
 
    * Status:
    *  WinAPI   :  Yes
    *  GTK/Linux:  Yes
    *  GTK/Win  :  No


#include "hwguipp.ch"



Function Main
Local oMainWindow

* Modify to your own needs
 SET CENTURY ON
 SET DATE GERMAN

   INIT WINDOW oMainWindow MAIN TITLE "Datepicker main dialog" ;
     AT 200, 0 SIZE 200, 250

   MENU OF oMainWindow
     MENU TITLE "&Exit"
      MENUITEM "&Quit" ACTION hwg_EndWindow()
     ENDMENU
     MENU TITLE "&Test"
      MENUITEM "&Datepicker" ACTION DlgDPick()
   
     ENDMENU
   ENDMENU

   ACTIVATE WINDOW oMainWindow

Return NIL


FUNCTION DlgDPick()
Local odGet, oDateOwb, daltdatum, Ctext
Local oModDlg, oFont, d1 := Date() + 1

oFont := hwg_DefaultFont()

* Remember old date
daltdatum := d1

  INIT DIALOG oModDlg TITLE "Datepicker"  ;
   AT 210, 10 SIZE 350, 300                  ;
   FONT oFont NOEXIT

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Windows only DATEPICKER substitute
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*  v==> These are the original coordinates of DATEPICKER command    
   @ 160, 170 GET odGet VAR d1  ;
        STYLE WS_DLGFRAME   ;
        SIZE 80, 20 COLOR 0xFF0000
*            ^==> This is the original size of DATEPICKER command

*    v==>  x = 160 + 81 (x value of GET + width of GET + 1 )
   @ 241, 170 OWNERBUTTON oDateOwb  ;
   ON CLICK { | | d1 := hwg_pCalendar(d1) , odGet:Value(d1) } ;
   SIZE 12, 12  ;            // Size of image + 1
   BITMAP hwg_oDatepicker_bmp() ; 
   TRANSPARENT  COORDINATES 0, 0, 11, 11 ;
   TOOLTIP "Pick date from calendar"

   @ 150, 250 BUTTON "Close" ON CLICK {|| oModDlg:Close() } SIZE 100, 40

   ACTIVATE DIALOG oModDlg
   oFont:Release()

  * Check for modified / Cancel
    IF daltdatum == d1
     Ctext := "Date not modified or dialog cancelled"
     hwg_Msginfo(Ctext)
    ENDIF 

    hwg_Msginfo(dtoc(d1))

Return NIL
