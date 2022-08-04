#xcommand INIT DIALOG <oDlg>                ;
             [<res: FROM RESOURCE> <Resid> ]         ;
             [ TITLE <cTitle> ]             ;
             [ AT <x>, <y> ]                ;
             [ SIZE <width>, <height> ]     ;
             [ ICON <ico> ]                 ;
             [ BACKGROUND BITMAP <oBmp> ]   ;
             [ STYLE <nStyle> ]             ;
             [ FONT <oFont> ]               ;
             [ <bclr: BACKCOLOR, COLOR> <bColor> ] ;
             [<lClipper: CLIPPER>]          ;
             [<lExitOnEnter: NOEXIT>]       ; //Modified By Sandro
             [<lExitOnEsc: NOEXITESC>]      ; //Modified By Sandro
             [ <lnoClosable: NOCLOSABLE> ]  ;
             [ ON INIT <bInit> ]            ;
             [ ON SIZE <bSize> ]            ;
             [ ON PAINT <bPaint> ]          ;
             [ ON GETFOCUS <bGfocus> ]      ;
             [ ON LOSTFOCUS <bLfocus> ]     ;
             [ ON OTHER MESSAGES <bOther> ] ;
             [ ON EXIT <bExit> ]            ;
             [ HELPID <nHelpId> ]           ;
          => ;
   <oDlg> := HDialog():New( Iif(<.res.>,WND_DLG_RESOURCE,WND_DLG_NORESOURCE), ;
                   <nStyle>,<x>,<y>,<width>,<height>,<cTitle>,<oFont>,;
                   <bInit>,<bExit>,<bSize>, <bPaint>,<bGfocus>,<bLfocus>,;
                   <bOther>,<.lClipper.>,<oBmp>,<ico>,<.lExitOnEnter.>,<nHelpId>,<Resid>,<.lExitOnEsc.>,<bColor>,<.lnoClosable.> )

#xcommand ACTIVATE DIALOG <oDlg>       ;
             [ <lNoModal: NOMODAL> ]   ;
             [<lMaximized: MAXIMIZED>] ;
             [<lMinimized: MINIMIZED>] ;
             [<lCenter: CENTER>]       ;
             [ ON ACTIVATE <bInit> ]   ;
          => ;
          <oDlg>:Activate( <.lNoModal.>, <.lMaximized.>, <.lMinimized.>, <.lCenter.>, <bInit> )
