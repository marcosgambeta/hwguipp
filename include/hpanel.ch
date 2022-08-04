#xcommand @ <x>,<y> PANEL [ <oPanel> ] ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ BACKCOLOR <bcolor> ]     ;
            [ HSTYLE <oStyle> ]        ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ STYLE <nStyle> ]         ;
          => ;
    [<oPanel> :=] HPanel():New( <oWnd>,<nId>,<nStyle>,<x>,<y>,<width>,<height>,<bInit>,<bSize>,<bDraw>,<bcolor>,<oStyle> );
    [; hwg_SetCtrlName( <oPanel>,<(oPanel)> )]

#xcommand REDEFINE PANEL [ <oPanel> ]  ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ HEIGHT <nHeight> ]       ;
          => ;
    [<oPanel> :=] HPanel():Redefine( <oWnd>,<nId>,<nHeight>,<bInit>,<bSize>,<bDraw> );
    [; hwg_SetCtrlName( <oPanel>,<(oPanel)> )]

#xcommand ADD TOP PANEL [ <oPanel> ] TO <oWnd> ;
            [ ID <nId> ]               ;
            HEIGHT <height>            ;
            [ BACKCOLOR <bcolor> ]     ;
            [ HSTYLE <oStyle> ]        ;
            [ ON INIT <bInit> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ STYLE <nStyle> ]         ;
          => ;
    [<oPanel> :=] HPanel():New( <oWnd>,<nId>,<nStyle>,0,0,<oWnd>:nWidth,<height>,<bInit>,ANCHOR_TOPABS+ANCHOR_LEFTABS+ANCHOR_RIGHTABS,<bDraw>,<bcolor>,<oStyle> );
    [; hwg_SetCtrlName( <oPanel>,<(oPanel)> )]

#xcommand ADD STATUS PANEL [ <oPanel> ] TO <oWnd> ;
            [ ID <nId> ]               ;
            HEIGHT <height>            ;
            [ BACKCOLOR <bcolor> ]     ;
            [ ON INIT <bInit> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ FONT <oFont> ]           ;
            [ HSTYLE <oStyle> ]        ;
            [ PARTS <aparts,...> ]     ;
          => ;
    [<oPanel> :=] HPanelSts():New( <oWnd>,<nId>,<height>,<oFont>,<bInit>,<bDraw>,<bcolor>,<oStyle>,\{<aparts>\} );
    [; hwg_SetCtrlName( <oPanel>,<(oPanel)> )]

#xcommand ADD HEADER PANEL [ <oPanel> ] [ TO <oWnd> ] ;
            [ ID <nId> ]               ;
            HEIGHT <height>            ;
            [ TEXTCOLOR <tcolor> ]     ;
            [ BACKCOLOR <bcolor> ]     ;
            [ ON INIT <bInit> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ FONT <oFont> ]           ;
            [ HSTYLE <oStyle> ]        ;
            [ TEXT <cText> [COORS <xt>[,<yt>] ] ] ;
            [ <lBtnClose: BTN_CLOSE> ] ;
            [ <lBtnMax: BTN_MAXIMIZE> ];
            [ <lBtnMin: BTN_MINIMIZE> ];
          => ;
    [<oPanel> :=] HPanelHea():New( <oWnd>,<nId>,<height>,<oFont>,<bInit>,<bDraw>, ;
       <tcolor>,<bcolor>,<oStyle>,<cText>,<xt>,<yt>,<.lBtnClose.>,<.lBtnMax.>,<.lBtnMin.> );
    [; hwg_SetCtrlName( <oPanel>,<(oPanel)> )]
