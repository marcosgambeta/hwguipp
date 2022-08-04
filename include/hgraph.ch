
/*             */
#xcommand @ <x>,<y> GRAPH [ <oGraph> DATA ] <aData> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ COLOR <color> ]          ;
            [ BACKCOLOR <bcolor> ]     ;
            [ ON SIZE <bSize> ]        ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <ctoolt> ]       ;
          => ;
    [<oGraph> := ] HGraph():New( <oWnd>,<nId>,<aData>,<x>,<y>,<width>, ;
        <height>,<oFont>,<bSize>,<ctoolt>,<color>,<bcolor> );
    [; hwg_SetCtrlName( <oGraph>,<(oGraph)> )]
