// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY HWG_EXTCTRL.CH

#xcommand @ <nX>, <nY> BUTTONEX [ <oBut> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <nColor> ]          ;
             [ BACKCOLOR <nBackColor> ]     ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ BITMAP <hbit> ]          ;
             [ BSTYLE <nBStyle> ]       ;
             [ PICTUREMARGIN <nMargin> ];
             [ ICON <hIco> ]            ;
             [ <lTransp: TRANSPARENT> ] ;
             [ <lnoTheme: NOTHEMES> ]   ;
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ STYLE <nStyle> ]         ;
          => ;
          [<oBut> := ] HButtonEx():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<bClick>,<cTooltip>,<nColor>,<nBackColor>,<hbit>, ;
             <nBStyle>,<hIco>, <.lTransp.>,<bGfocus>,<nMargin>,<.lnoTheme.>, <bOther> );
          [; hwg_SetCtrlName( <oBut>,<(oBut)> )]


#xcommand REDEFINE BUTTONEX [ <oBut> ]   ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ CAPTION <cCaption> ]     ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ON CLICK <bClick> ]      ;
            [ ON GETFOCUS <bGfocus> ]  ;
            [ BITMAP <hbit> ]          ;
            [ BSTYLE <nBStyle> ]       ;
            [ PICTUREMARGIN <nMargin> ];
            [ ICON <hIco> ]            ;
            [ <lTransp: TRANSPARENT> ] ;
            [ <lnoTheme: NOTHEMES> ]   ;
            [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
          => ;
    [<oBut> := ] HButtonEx():Redefine( <oWnd>,<nId>,<oFont>,<bInit>,<bSize>,<bDraw>, ;
                    <bClick>,<cTooltip>,<nColor>,<nBackColor>,<cCaption>,<hbit>, ;
             <nBStyle>,<hIco>, <.lTransp.>,<bGfocus>,<nMargin>,<.lnoTheme.>, <bOther> ) ;
    [; hwg_SetCtrlName( <oBut>,<(oBut)> )]
