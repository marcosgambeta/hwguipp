// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

/*             */
#xcommand @ <nX>, <nY> GRAPH [ <oGraph> DATA ] <aData> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ ON SIZE <bSize> ]        ;
            [ <class: CLASS> <classname> ]       ;
          => ;
    [ <oGraph> := ] __IIF(<.class.>, <classname>, HGraph)():New( <oWnd>,<nId>,<aData>,<nX>,<nY>,<nWidth>, ;
        <nHeight>,<oFont>,<bSize>,<cTooltip>,<nColor>,<nBackColor> );
    [; hwg_SetCtrlName( <oGraph>,<(oGraph)> )]
