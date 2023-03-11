#xcommand @ <nX>, <nY> IMAGE [ <oImage> SHOW ] <image> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ TOOLTIP <cTooltip> ]       ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ TYPE <ctype>     ]       ;
          => ;
    [<oImage> := ] HSayFImage():New( <oWnd>,<nId>,<nX>,<nY>,<nWidth>, ;
        <nHeight>,<image>,<bInit>,<bSize>,<cTooltip>,<ctype> );
    [; hwg_SetCtrlName( <oImage>,<(oImage)> )]

#xcommand REDEFINE IMAGE [ <oImage> SHOW ] <image> ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ TOOLTIP <cTooltip> ]       ;
          => ;
    [<oImage> := ] HSayFImage():Redefine( <oWnd>,<nId>,<image>, ;
        <bInit>,<bSize>,<cTooltip> );
    [; hwg_SetCtrlName( <oImage>,<(oImage)> )]
