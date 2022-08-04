#xcommand @ <x>,<y> SPLITTER [ <oSplit> ] ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ COLOR <color> ]          ;
            [ BACKCOLOR <bcolor> ]     ;
            [ HSTYLE <oStyle> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ DIVIDE <aLeft> FROM <aRight> ] ;
            [ LIMITS [<nFrom>][,<nTo>] ]   ;
          => ;
    [<oSplit> :=] HSplitter():New( <oWnd>,<nId>,<x>,<y>,<width>,<height>,<bSize>,<bDraw>,<color>,<bcolor>,<aLeft>,<aRight>,<nFrom>,<nTo>,<oStyle> );
    [; hwg_SetCtrlName( <oSplit>,<(oSplit)> )]
