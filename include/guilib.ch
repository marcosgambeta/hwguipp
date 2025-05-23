#ifndef _GUILIB_CH_
#define _GUILIB_CH_

/*
  ========== Define HWGUI release version ============
*/
/* For note of latest official release version number */
#define HWG_VERSION         "1.0.0dev"
/* For note of latest official release build */
#define HWG_BUILD               0
/* ----- End of HWGUI version definition ----- */

#define WND_MAIN                1
#define WND_MDI                 2
#define WND_MDICHILD            3
#define WND_CHILD               4
#define WND_DLG_RESOURCE       10
#define WND_DLG_NORESOURCE     11

#define WND_NOTITLE            -1
#define WND_NOSYSMENU          -2
#define WND_NOSIZEBOX          -4

#define OBTN_INIT               0
#define OBTN_NORMAL             1
#define OBTN_MOUSOVER           2
#define OBTN_PRESSED            3

#define SHS_NOISE               0
#define SHS_DIAGSHADE           1
#define SHS_HSHADE              2
#define SHS_VSHADE              3
#define SHS_HBUMP               4
#define SHS_VBUMP               5
#define SHS_SOFTBUMP            6
#define SHS_HARDBUMP            7
#define SHS_METAL               8

#define PAL_DEFAULT             0
#define PAL_METAL               1

#define BRW_ARRAY               1
#define BRW_DATABASE            2

#define PAINT_LINE_ALL          0
#define PAINT_LINE_BACK         1
#define PAINT_HEAD_ALL          2
#define PAINT_HEAD_BACK         3
#define PAINT_FOOT_ALL          4
#define PAINT_FOOT_BACK         5
#define PAINT_LINE_ITEM        11
#define PAINT_HEAD_ITEM        12
#define PAINT_FOOT_ITEM        13
#define PAINT_BACK              1
#define PAINT_ITEM             11

#define PAGE_FIRST              1
#define PAGE_LAST               2

#define ANCHOR_TOPLEFT         0   // Anchors control to the top and left borders of the container and does not change the distance between the top and left borders. (Default)
#define ANCHOR_TOPABS          1   // Anchors control to top border of container and does not change the distance between the top border.
#define ANCHOR_LEFTABS         2   // Anchors control to left border of container and does not change the distance between the left border.
#define ANCHOR_BOTTOMABS       4   // Anchors control to bottom border of container and does not change the distance between the bottom border.
#define ANCHOR_RIGHTABS        8   // Anchors control to right border of container and does not change the distance between the right border.
#define ANCHOR_TOPREL          16  // Anchors control to top border of container and maintains relative distance between the top border.
#define ANCHOR_LEFTREL         32  // Anchors control to left border of container and maintains relative distance between the left border.
#define ANCHOR_BOTTOMREL       64  // Anchors control to bottom border of container and maintains relative distance between the bottom border.
#define ANCHOR_RIGHTREL        128 // Anchors control to right border of container and maintains relative distance between the right border.
#define ANCHOR_HORFIX          256 // Anchors center of control relative to left and right borders but remains fixed in size.
#define ANCHOR_VERTFIX         512 // Anchors center of control relative to top and bottom borders but remains fixed in size.

#define HORZ_PTS                9
#define VERT_PTS               12

#ifdef __LINUX__
   /* for some ancient [x]Harbour versions which do not set __PLATFORM__UNIX */
   #ifndef __PLATFORM__UNIX
      #define __PLATFORM__UNIX
   #endif
#endif

#ifndef __GTK__
   #ifdef __PLATFORM__UNIX
      #define __GTK__
   #endif
#endif

#ifdef __XHARBOUR__
  #ifndef HB_SYMBOL_UNUSED
     #define HB_SYMBOL_UNUSED( x )    ( (x) := (x) )
  #endif
#endif

#xtranslate hwg_Rgb([<n,...>])                    => hwg_ColorRGB2N(<n>)
#xtranslate hwg_VColor([<n,...>])                 => hwg_ColorC2N(<n>)
#xtranslate hwg_ParentGetDialog([<n,...>])        => hwg_getParentForm(<n>)

// Allow the definition of different classes without defining a new command

#xtranslate __IIF(.T., [<true>], [<false>]) => <true>
#xtranslate __IIF(.F., [<true>], [<false>]) => <false>

// Commands for windows, dialogs handling

#include "_hwindow.ch"
#include "_hdialog.ch"

#xcommand MENU FROM RESOURCE OF <oWnd> ON <id1> ACTION <b1>  ;
                                 [ ON <idn> ACTION <bn> ]    ;
          => ;
   <oWnd>:aEvents := \{ \{ 0,<id1>, <{b1}> \} [ , \{ 0,<idn>, <{bn}> \} ] \}

#xcommand DIALOG ACTIONS OF <oWnd> ON <id1>,<id2> ACTION <b1>      ;
                                 [ ON <idn1>,<idn2> ACTION <bn> ]  ;
          => ;
   <oWnd>:aEvents := \{ \{ <id1>,<id2>, <b1> \} [ , \{ <idn1>,<idn2>, <bn> \} ] \}

// Commands for control handling

#include "_hprogressbar.ch"
#include "_hstatus.ch"
#include "_hstatic.ch"
#include "_hsaybmp.ch"
#include "_hsayicon.ch"
#include "_hsayfimage.ch"
#include "_hline.ch"
#include "_hedit.ch"
#include "_hrichedit.ch"
#include "_hbutton.ch"
#include "_hgroup.ch"
#include "_htree.ch"
#include "_htab.ch"
#include "_hcheckbutton.ch"
#include "_hradiogroup.ch"
#include "_hradiobutton.ch"
#include "_hcombobox.ch"
#include "_hupdown.ch"
#include "_hpanel.ch"
#include "_hbrowse.ch"
#include "_hgrid.ch"
#include "_hownbutton.ch"
#include "_hshadebutton.ch"
#include "_hdatepicker.ch"
#include "_hsplitter.ch"

#xcommand PREPARE FONT <oFont>       ;
             NAME <cName>            ;
             [ WIDTH <nWidth> ]      ;
             [ HEIGHT <nHeight> ]    ;
             [ WEIGHT <nWeight> ]    ;
             [ CHARSET <charset> ]   ;
             [ <ita: ITALIC> ]       ;
             [ <under: UNDERLINE> ]  ;
             [ <strike: STRIKEOUT> ] ;
          => ;
    <oFont> := HFont():Add( <cName>, <nWidth>, <nHeight>, <nWeight>, <charset>, ;
                iif( <.ita.>,1,0 ), iif( <.under.>,1,0 ), iif( <.strike.>,1,0 ) )

/* Print commands */

#xcommand START PRINTER DEFAULT    ;
          => ;
    OpenDefaultPrinter(); StartDoc()

/* SAY ... GET system     */

#xcommand SAY <value> TO <oDlg> ID <id> ;
          => ;
    hwg_SetDlgItemText( <oDlg>:handle, <id>, <value> )

/*   Menu system     */

#include "_hmenu.ch"

#include "_htimer.ch"

#xcommand SET KEY [ <lGlobal:GLOBAL> ] <nctrl>, <nkey> [ OF <oDlg> ] TO [ <func> ] ;
          => ;
    hwg_SetDlgKey( <oDlg>, <nctrl>, <nkey>, <{func}>, <.lGlobal.> )

#include "_hgraph.ch"

/* open an .dll resource */
#xcommand SET RESOURCES TO [ <cName1> ]  =>  hwg_LoadResource( <cName1> )

/* open a binary container as resource */
#xcommand SET RESOURCES CONTAINER TO [ <cName> ]  =>  hwg_SetResContainer( <cName> )

// Addded by jamaj
#xcommand DEFAULT <uVar1> := <uVal1> ;
               [, <uVarN> := <uValN> ] => ;
                  <uVar1> := IIf( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
                [ <uVarN> := IIf( <uVarN> == nil, <uValN>, <uVarN> ); ]

#include "_hipedit.ch"

#define ISOBJECT(c)    (Valtype(c) == "O")
#define ISBLOCK(c)     (Valtype(c) == "B")
#define ISARRAY(c)     (Valtype(c) == "A")
#define ISNUMBER(c)    (Valtype(c) == "N")
#define ISLOGICAL(c)   (Valtype(c) == "L")

/* Commands for PrintDos Class*/

#xcommand SET PRINTER TO <oPrinter> OF <oPtrObj>     ;
           => ;
      <oPtrObj>:=Printdos():New( <oPrinter>)

#xcommand @ <nX>, <nY> PSAY <vari> ;
            [ PICTURE <cPicture> ] OF <oPtrObj>   ;
          => ;
          <oPtrObj>:Say(<nX>, <nY>, <vari>, <cPicture>)

#xcommand  EJECT OF <oPtrObj> => <oPtrObj>:Eject()

#xcommand  END PRINTER <oPtrObj> => <oPtrObj>:End()

/* Hprinter */
#include "_hprinter.ch"

#include "_hmonthcalendar.ch"
#include "_hlistbox.ch"
#include "_hsplash.ch"
#include "_hnicebutton.ch"
#include "_htrackbar.ch"
#include "_hanimation.ch"
#include "_hrect.ch"
#include "_hstaticlink.ch"
#include "_htoolbar.ch"

#xcommand CREATE MENUBAR <o> => <o> := \{ \}

#xcommand MENUBARITEM  <oWnd> CAPTION <c> ON <id1> ACTION <b1>      ;
          => ;
          Aadd(<oWnd>, \{ <c>, <id1>, <{b1}> \})

#include "_hpager.ch"
#include "_hrebar.ch"
#include "_hshape.ch"
#include "_hcedit.ch"

#endif // _GUILIB_CH_
