// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> PANEL [ <oPanel> ] ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ HSTYLE <oStyle> ]        ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ STYLE <nStyle> ]         ;
            [ <class: CLASS> <classname> ]       ;
          => ;
    [ <oPanel> := ] __IIF(<.class.>, <classname>, HPanel)():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<bInit>,<bSize>,<bDraw>,<nBackColor>,<oStyle> );
    [; hwg_SetCtrlName( <oPanel>,<(oPanel)> )]

#xcommand REDEFINE PANEL [ <oPanel> ]  ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ HEIGHT <nHeight> ]       ;
          => ;
    [ <oPanel> := ] HPanel():Redefine( <oWnd>,<nId>,<nHeight>,<bInit>,<bSize>,<bDraw> );
    [; hwg_SetCtrlName( <oPanel>,<(oPanel)> )]

#xcommand ADD TOP PANEL [ <oPanel> ] TO <oWnd> ;
            [ ID <nId> ]               ;
            HEIGHT <nHeight>            ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ HSTYLE <oStyle> ]        ;
            [ ON INIT <bInit> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ STYLE <nStyle> ]         ;
          => ;
    [ <oPanel> := ] HPanel():New( <oWnd>,<nId>,<nStyle>,0,0,<oWnd>:nWidth,<nHeight>,<bInit>,ANCHOR_TOPABS+ANCHOR_LEFTABS+ANCHOR_RIGHTABS,<bDraw>,<nBackColor>,<oStyle> );
    [; hwg_SetCtrlName( <oPanel>,<(oPanel)> )]

#xcommand ADD STATUS PANEL [ <oPanel> ] TO <oWnd> ;
            [ ID <nId> ]               ;
            HEIGHT <nHeight>            ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ ON INIT <bInit> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ FONT <oFont> ]           ;
            [ HSTYLE <oStyle> ]        ;
            [ PARTS <aparts,...> ]     ;
          => ;
    [ <oPanel> := ] HPanelSts():New( <oWnd>,<nId>,<nHeight>,<oFont>,<bInit>,<bDraw>,<nBackColor>,<oStyle>,\{<aparts>\} );
    [; hwg_SetCtrlName( <oPanel>,<(oPanel)> )]

#xcommand ADD HEADER PANEL [ <oPanel> ] [ TO <oWnd> ] ;
            [ ID <nId> ]               ;
            HEIGHT <nHeight>            ;
            [ TEXTCOLOR <tcolor> ]     ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ ON INIT <bInit> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ FONT <oFont> ]           ;
            [ HSTYLE <oStyle> ]        ;
            [ TEXT <cText> [COORS <xt>[,<yt>] ] ] ;
            [ <lBtnClose: BTN_CLOSE> ] ;
            [ <lBtnMax: BTN_MAXIMIZE> ];
            [ <lBtnMin: BTN_MINIMIZE> ];
          => ;
    [ <oPanel> := ] HPanelHea():New( <oWnd>,<nId>,<nHeight>,<oFont>,<bInit>,<bDraw>, ;
       <tcolor>,<nBackColor>,<oStyle>,<cText>,<xt>,<yt>,<.lBtnClose.>,<.lBtnMax.>,<.lBtnMin.> );
    [; hwg_SetCtrlName( <oPanel>,<(oPanel)> )]
