// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> GROUPBOX [ <oGroup> CAPTION ] <caption> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ STYLE <nStyle> ]         ;
            [ <class: CLASS> <classname> ]       ;
          => ;
    [<oGroup> := ] __IIF(<.class.>, <classname>, HGroup)():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<nColor>,<nBackColor> );
    [; hwg_SetCtrlName( <oGroup>,<(oGroup)> )]
