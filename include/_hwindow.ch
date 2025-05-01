// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand INIT WINDOW <oWnd>                          ;
            [ MAIN ]                                  ;
            [ <lMdi: MDI> ]                           ;
            [ APPNAME <appname> ]                     ;
            [ TITLE <cTitle> ]                        ;
            [ AT <nX>, <nY> ]                         ;
            [ SIZE <nWidth>, <nHeight> ]              ;
            [ ICON <ico> ]                            ;
            [ SYSCOLOR <clr> ]                        ;
            [ <bclr: BACKCOLOR, COLOR> <nBackColor> ] ;
            [ BACKGROUND BITMAP <oBmp> ]              ;
            [ STYLE <nStyle> ]                        ;
            [ EXCLUDE <nExclude> ]                    ;
            [ FONT <oFont> ]                          ;
            [ MENU <cMenu> ]                          ;
            [ MENUPOS <nPos> ]                        ;
            [ ON INIT <bInit> ]                       ;
            [ ON SIZE <bSize> ]                       ;
            [ ON PAINT <bPaint> ]                     ;
            [ ON GETFOCUS <bGfocus> ]                 ;
            [ ON LOSTFOCUS <bLfocus> ]                ;
            [ ON OTHER MESSAGES <bOther> ]            ;
            [ ON EXIT <bExit> ]                       ;
            [ HELP <cHelp> ]                          ;
            [ HELPID <nHelpId> ]                      ;
            [ <class: CLASS> <classname> ]            ;
          => ;
          <oWnd> := __IIF(<.class.>, <classname>, HMainWindow)():New(IIf(<.lMdi.>, WND_MDI, WND_MAIN), ;
          <ico>, <clr>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>, <cTitle>, ;
          <cMenu>, <nPos>, <oFont>, <bInit>, <bExit>, <bSize>, <bPaint>,;
          <bGfocus>, <bLfocus>, <bOther>, <appname>, <oBmp>, <cHelp>, <nHelpId>, <nBackColor>, <nExclude>)

#xcommand INIT WINDOW <oWnd> MDICHILD                 ;
            [ APPNAME <appname> ]                     ;
            [ TITLE <cTitle> ]                        ;
            [ AT <nX>, <nY> ]                         ;
            [ SIZE <nWidth>, <nHeight> ]              ;
            [ ICON <ico> ]                            ;
            [ <bclr: BACKCOLOR, COLOR> <nBackColor> ] ;
            [ BACKGROUND BITMAP <oBmp> ]              ;
            [ STYLE <nStyle> ]                        ;
            [ FONT <oFont> ]                          ;
            [ MENU <cMenu> ]                          ;
            [ ON INIT <bInit> ]                       ;
            [ ON SIZE <bSize> ]                       ;
            [ ON PAINT <bPaint> ]                     ;
            [ ON GETFOCUS <bGfocus> ]                 ;
            [ ON LOSTFOCUS <bLfocus> ]                ;
            [ ON OTHER MESSAGES <bOther> ]            ;
            [ ON EXIT <bExit> ]                       ;
            [ HELP <cHelp> ]                          ;
            [ HELPID <nHelpId> ]                      ;
            [ <class: CLASS> <classname> ]            ;
          => ;
          <oWnd> := __IIF(<.class.>, <classname>, HMdiChildWindow)():New( ;
          <ico>, , <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>, <cTitle>, ;
          <cMenu>, <oFont>, <bInit>, <bExit>, <bSize>, <bPaint>, ;
          <bGfocus>, <bLfocus>, <bOther>, <appname>, <oBmp>, <cHelp>, <nHelpId>, <nBackColor>)

#xcommand INIT WINDOW <oWnd> CHILD                    ;
            APPNAME <appname>                         ;
            [ TITLE <cTitle> ]                        ;
            [ AT <nX>, <nY> ]                         ;
            [ SIZE <nWidth>, <nHeight> ]              ;
            [ ICON <ico> ]                            ;
            [ SYSCOLOR <clr> ]                        ;
            [ <bclr: BACKCOLOR, COLOR> <nBackColor> ] ;
            [ BACKGROUND BITMAP <oBmp> ]              ;
            [ STYLE <nStyle> ]                        ;
            [ FONT <oFont> ]                          ;
            [ MENU <cMenu> ]                          ;
            [ ON INIT <bInit> ]                       ;
            [ ON SIZE <bSize> ]                       ;
            [ ON PAINT <bPaint> ]                     ;
            [ ON GETFOCUS <bGfocus> ]                 ;
            [ ON LOSTFOCUS <bLfocus> ]                ;
            [ ON OTHER MESSAGES <bOther> ]            ;
            [ ON EXIT <bExit> ]                       ;
            [ HELP <cHelp> ]                          ;
            [ HELPID <nHelpId> ]                      ;
            [ <class: CLASS> <classname> ]            ;
          => ;
          <oWnd> := __IIF(<.class.>, <classname>, HChildWindow)():New( ;
          <ico>, <clr>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>, <cTitle>, ;
          <cMenu>, <oFont>, <bInit>, <bExit>, <bSize>, <bPaint>, ;
          <bGfocus>, <bLfocus>, <bOther>, <appname>, <oBmp>, <cHelp>, <nHelpId>, <nBackColor>)

#xcommand ACTIVATE WINDOW <oWnd>              ;
            [ <lNoShow: NOSHOW> ]             ;
            [ <lMaximized: MAXIMIZED> ]       ;
            [ <lMinimized: MINIMIZED> ]       ;
            [ <lCentered: CENTER, CENTERED> ] ;
            [ ON ACTIVATE <bInit> ]           ;
          => ;
          <oWnd>:Activate(!<.lNoShow.>, <.lMaximized.>, <.lMinimized.>, <.lCentered.>, <bInit>)

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
