// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> SPLITTER [ <oSplit> ] ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ HSTYLE <oStyle> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ DIVIDE <aLeft> FROM <aRight> ] ;
            [ LIMITS [ <nFrom> ][, <nTo> ] ]   ;
            [ <class: CLASS> <classname> ]       ;
          => ;
    [ <oSplit> := ] __IIF(<.class.>, <classname>, HSplitter)():New( <oWnd>,<nId>,<nX>,<nY>,<nWidth>,<nHeight>,<bSize>,<bDraw>,<nColor>,<nBackColor>,<aLeft>,<aRight>,<nFrom>,<nTo>,<oStyle> );
    [; hwg_SetCtrlName( <oSplit>,<(oSplit)> )]
