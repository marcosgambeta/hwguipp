#xcommand @ <x>,<y> ICON [ <oIco> SHOW ] <icon> ;
            [<res: FROM RESOURCE>]     ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON CLICK <bClick> ]      ;
            [ ON DBLCLICK <bDblClick> ];
            [ TOOLTIP <ctoolt> ]       ;
          => ;
    [<oIco> := ] HSayIcon():New( <oWnd>,<nId>,<x>,<y>,<width>, ;
        <height>,<icon>,<.res.>,<bInit>,<bSize>,<ctoolt>,,<bClick>,<bDblClick> );
    [; hwg_SetCtrlName( <oIco>,<(oIco)> )]

#xcommand REDEFINE ICON [ <oIco> SHOW ] <icon> ;
            [<res: FROM RESOURCE>]     ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ TOOLTIP <ctoolt> ]       ;
          => ;
    [<oIco> := ] HSayIcon():Redefine( <oWnd>,<nId>,<icon>,<.res.>, ;
        <bInit>,<bSize>,<ctoolt> );
    [; hwg_SetCtrlName( <oIco>,<(oIco)> )]
