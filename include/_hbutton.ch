// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> BUTTON [ <oBut> CAPTION ] <caption> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]         ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]     ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ON CLICK <bClick> ]      ;
            [ STYLE <nStyle> ]         ;
          => ;
    [ <oBut> := ] HButton():New(<oWnd>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>, <caption>, <oFont>, ;
       <bInit>, <bSize>, <bDraw>, <bClick>, <cTooltip>, <nColor>, <nBackColor>);
    [ ; hwg_SetCtrlName(<oBut>, <(oBut)>) ]

#xcommand REDEFINE BUTTON [ <oBut> ]   ;
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
          => ;
    [ <oBut> := ] HButton():Redefine(<oWnd>, <nId>, <oFont>, <bInit>, <bSize>, <bDraw>, <bClick>, <cTooltip>, <nColor>, <nBackColor>, <cCaption>);
    [ ; hwg_SetCtrlName(<oBut>, <(oBut)>) ]
