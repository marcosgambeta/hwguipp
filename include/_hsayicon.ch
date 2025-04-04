// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> ICON [ <oIco> SHOW ] <icon> ;
            [<res: FROM RESOURCE>]     ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ TOOLTIP <cTooltip> ]       ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON CLICK <bClick> ]      ;
            [ ON DBLCLICK <bDblClick> ];
          => ;
    [<oIco> := ] HSayIcon():New( <oWnd>,<nId>,<nX>,<nY>,<nWidth>, ;
        <nHeight>,<icon>,<.res.>,<bInit>,<bSize>,<cTooltip>,,<bClick>,<bDblClick> );
    [; hwg_SetCtrlName( <oIco>,<(oIco)> )]

#xcommand REDEFINE ICON [ <oIco> SHOW ] <icon> ;
            [<res: FROM RESOURCE>]     ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ TOOLTIP <cTooltip> ]       ;
          => ;
    [<oIco> := ] HSayIcon():Redefine( <oWnd>,<nId>,<icon>,<.res.>, ;
        <bInit>,<bSize>,<cTooltip> );
    [; hwg_SetCtrlName( <oIco>,<(oIco)> )]
