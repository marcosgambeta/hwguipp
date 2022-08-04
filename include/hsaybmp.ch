#xcommand @ <x>,<y> BITMAP [ <oBmp> SHOW ] <bitmap> ;
            [<res: FROM RESOURCE>]     ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ BACKCOLOR <bcolor> ]     ;
            [ STRETCH <nStretch>]      ;
            [<lTransp: TRANSPARENT> [COLOR  <trcolor> ]] ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON CLICK <bClick> ]      ;
            [ ON DBLCLICK <bDblClick> ];
            [ TOOLTIP <ctoolt> ]       ;
          => ;
    [<oBmp> := ] HSayBmp():New( <oWnd>,<nId>,<x>,<y>,<width>, ;
        <height>,<bitmap>,<.res.>,<bInit>,<bSize>,<ctoolt>,<bClick>,<bDblClick>,<.lTransp.>,<nStretch>,<trcolor>,<bcolor> );
    [; hwg_SetCtrlName( <oBmp>,<(oBmp)> )]

#xcommand REDEFINE BITMAP [ <oBmp> SHOW ] <bitmap> ;
            [<res: FROM RESOURCE>]     ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ TOOLTIP <ctoolt> ]       ;
          => ;
    [<oBmp> := ] HSayBmp():Redefine( <oWnd>,<nId>,<bitmap>,<.res.>, ;
        <bInit>,<bSize>,<ctoolt> );
    [; hwg_SetCtrlName( <oBmp>,<(oBmp)> )]
