// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> CHECKBOX [ <oCheck> CAPTION ] <caption> ;
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
            [ ON LOSTFOCUS <bLfocus> ] ;
            [ INIT <lInit> ]           ;
            [<lTransp: TRANSPARENT>]   ;
            [ STYLE <nStyle> ]         ;
          => ;
    [<oCheck> := ] HCheckButton():New( <oWnd>,<nId>,<lInit>,,<nStyle>,<nX>,<nY>, ;
         <nWidth>,<nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<bClick>,<cTooltip>,<nColor>,<nBackColor>,<bGfocus>,<.lTransp.>,<bLfocus> );
    [; hwg_SetCtrlName( <oCheck>,<(oCheck)> )]

#xcommand REDEFINE CHECKBOX [ <oCheck> ] ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ON CLICK <bClick> ]      ;
            [ INIT <lInit>    ]        ;
          => ;
    [<oCheck> := ] HCheckButton():Redefine( <oWnd>,<nId>,<lInit>,,<oFont>, ;
          <bInit>,<bSize>,<bDraw>,<bClick>,<cTooltip>,<nColor>,<nBackColor> );
    [; hwg_SetCtrlName( <oCheck>,<(oCheck)> )]

/* SAY ... GET system     */

#xcommand @ <nX>, <nY> GET CHECKBOX [ <oCheck> VAR ] <vari> CAPTION <caption> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ STYLE <nStyle> ]         ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [<lTransp: TRANSPARENT>]   ;
            [ <valid: VALID, ON CLICK> <bClick> ]     ;
            [ WHEN <bWhen> ]           ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON LOSTFOCUS <bLfocus> ] ;
          => ;
    [<oCheck> := ] HCheckButton():New( <oWnd>,<nId>,<vari>,              ;
                    {|v|Iif(v==Nil,<vari>,<vari>:=v)},                   ;
                    <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<caption>,<oFont>, ;
                    <bInit>,<bSize>,,<bClick>,<cTooltip>,<nColor>,<nBackColor>,<bWhen>,<.lTransp.>,<bLfocus> );
    [; hwg_SetCtrlName( <oCheck>,<(oCheck)> )]

#xcommand REDEFINE GET CHECKBOX [ <oCheck> VAR ] <vari>  ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ <valid: VALID, ON CLICK> <bClick> ] ;
            [ WHEN <bWhen> ]           ;
          => ;
    [<oCheck> := ] HCheckButton():Redefine( <oWnd>,<nId>,<vari>, ;
                    {|v|Iif(v==Nil,<vari>,<vari>:=v)},           ;
                    <oFont>,,,,<bClick>,<cTooltip>,<nColor>,<nBackColor>,<bWhen> );
    [; hwg_SetCtrlName( <oCheck>,<(oCheck)> )]
