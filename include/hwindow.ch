#xcommand INIT WINDOW <oWnd>                ;
             [ MAIN ]                       ;
             [<lMdi: MDI>]                  ;
             [ APPNAME <appname> ]          ;
             [ TITLE <cTitle> ]             ;
             [ AT <x>, <y> ]                ;
             [ SIZE <width>, <height> ]     ;
             [ ICON <ico> ]                 ;
             [ SYSCOLOR <clr> ]             ;
             [ <bclr: BACKCOLOR, COLOR> <bcolor> ] ;
             [ BACKGROUND BITMAP <oBmp> ]   ;
             [ STYLE <nStyle> ]             ;
             [ EXCLUDE <nExclude> ]         ;
             [ FONT <oFont> ]               ;
             [ MENU <cMenu> ]               ;
             [ MENUPOS <nPos> ]             ;
             [ ON INIT <bInit> ]            ;
             [ ON SIZE <bSize> ]            ;
             [ ON PAINT <bPaint> ]          ;
             [ ON GETFOCUS <bGfocus> ]      ;
             [ ON LOSTFOCUS <bLfocus> ]     ;
             [ ON OTHER MESSAGES <bOther> ] ;
             [ ON EXIT <bExit> ]            ;
             [ HELP <cHelp> ]               ;
             [ HELPID <nHelpId> ]           ;
          => ;
   <oWnd> := HMainWindow():New( Iif(<.lMdi.>,WND_MDI,WND_MAIN), ;
                   <ico>,<clr>,<nStyle>,<x>,<y>,<width>,<height>,<cTitle>, ;
                   <cMenu>,<nPos>,<oFont>,<bInit>,<bExit>,<bSize>,<bPaint>,;
                   <bGfocus>,<bLfocus>,<bOther>,<appname>,<oBmp>,<cHelp>,<nHelpId>,<bcolor>,<nExclude> )

#xcommand INIT WINDOW <oWnd> MDICHILD       ;
             [ APPNAME <appname> ]          ;
             [ TITLE <cTitle> ]             ;
             [ AT <x>, <y> ]                ;
             [ SIZE <width>, <height> ]     ;
             [ ICON <ico> ]                 ;
             [ <bclr: BACKCOLOR, COLOR> <bColor> ] ;
             [ BACKGROUND BITMAP <oBmp> ]   ;
             [ STYLE <nStyle> ]             ;
             [ FONT <oFont> ]               ;
             [ MENU <cMenu> ]               ;
             [ ON INIT <bInit> ]            ;
             [ ON SIZE <bSize> ]            ;
             [ ON PAINT <bPaint> ]          ;
             [ ON GETFOCUS <bGfocus> ]      ;
             [ ON LOSTFOCUS <bLfocus> ]     ;
             [ ON OTHER MESSAGES <bOther> ] ;
             [ ON EXIT <bExit> ]            ;
             [ HELP <cHelp> ]               ;
             [ HELPID <nHelpId> ]           ;
          => ;
   <oWnd> := HMdiChildWindow():New( ;
                   <ico>,,<nStyle>,<x>,<y>,<width>,<height>,<cTitle>, ;
                   <cMenu>,<oFont>,<bInit>,<bExit>,<bSize>,<bPaint>, ;
                   <bGfocus>,<bLfocus>,<bOther>,<appname>,<oBmp>,<cHelp>,<nHelpId>,<bColor> )

#xcommand INIT WINDOW <oWnd> CHILD          ;
             APPNAME <appname>              ;
             [ TITLE <cTitle> ]             ;
             [ AT <x>, <y> ]                ;
             [ SIZE <width>, <height> ]     ;
             [ ICON <ico> ]                 ;
             [ SYSCOLOR <clr> ]             ;
             [ <bclr: BACKCOLOR, COLOR> <bColor> ] ;
             [ BACKGROUND BITMAP <oBmp> ]   ;
             [ STYLE <nStyle> ]             ;
             [ FONT <oFont> ]               ;
             [ MENU <cMenu> ]               ;
             [ ON INIT <bInit> ]            ;
             [ ON SIZE <bSize> ]            ;
             [ ON PAINT <bPaint> ]          ;
             [ ON GETFOCUS <bGfocus> ]      ;
             [ ON LOSTFOCUS <bLfocus> ]     ;
             [ ON OTHER MESSAGES <bOther> ] ;
             [ ON EXIT <bExit> ]            ;
             [ HELP <cHelp> ]               ;
             [ HELPID <nHelpId> ]           ;
          => ;
   <oWnd> := HChildWindow():New( ;
                   <ico>,<clr>,<nStyle>,<x>,<y>,<width>,<height>,<cTitle>, ;
                   <cMenu>,<oFont>,<bInit>,<bExit>,<bSize>,<bPaint>, ;
                   <bGfocus>,<bLfocus>,<bOther>,<appname>,<oBmp>,<cHelp>,<nHelpId>,<bColor> )

#xcommand ACTIVATE WINDOW <oWnd> ;
               [<lNoShow: NOSHOW>] ;
               [<lMaximized: MAXIMIZED>] ;
               [<lMinimized: MINIMIZED>] ;
               [<lCenter: CENTER>]       ;
               [ ON ACTIVATE <bInit> ]   ;
           => ;
      <oWnd>:Activate( !<.lNoShow.>, <.lMaximized.>, <.lMinimized.>, <.lCenter.>, <bInit> )

#xcommand CENTER WINDOW <oWnd> ;
	=>;
        <oWnd>:Center()

#xcommand MAXIMIZE WINDOW <oWnd> ;
	=>;
        <oWnd>:Maximize()

#xcommand MINIMIZE WINDOW <oWnd> ;
	=>;
        <oWnd>:Minimize()

#xcommand RESTORE WINDOW <oWnd> ;
	=>;
        <oWnd>:Restore()

#xcommand SHOW WINDOW <oWnd> ;
	=>;
        <oWnd>:Show()

#xcommand HIDE WINDOW <oWnd> ;
	=>;
        <oWnd>:Hide()
