#xcommand @ <nX>, <nY> SAY [ <oSay> CAPTION ] <caption> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [<lTransp: TRANSPARENT>]   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ STYLE <nStyle> ]         ;
          => ;
    [<oSay> := ] HStatic():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
        <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<cTooltip>,<nColor>,<nBackColor>,<.lTransp.> );
    [; hwg_SetCtrlName( <oSay>,<(oSay)> )]

#xcommand REDEFINE SAY   [ <oSay> CAPTION ] <cCaption>   ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [<lTransp: TRANSPARENT>]   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
          => ;
    [<oSay> := ] HStatic():Redefine( <oWnd>,<nId>,<cCaption>, ;
        <oFont>,<bInit>,<bSize>,<bDraw>,<cTooltip>,<nColor>,<nBackColor>,<.lTransp.> );
    [; hwg_SetCtrlName( <oSay>,<(oSay)> )]
