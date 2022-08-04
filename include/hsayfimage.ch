#xcommand @ <x>,<y> IMAGE [ <oImage> SHOW ] <image> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ TOOLTIP <ctoolt> ]       ;
            [ TYPE <ctype>     ]       ;
          => ;
    [<oImage> := ] HSayFImage():New( <oWnd>,<nId>,<x>,<y>,<width>, ;
        <height>,<image>,<bInit>,<bSize>,<ctoolt>,<ctype> );
    [; hwg_SetCtrlName( <oImage>,<(oImage)> )]

#xcommand REDEFINE IMAGE [ <oImage> SHOW ] <image> ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ TOOLTIP <ctoolt> ]       ;
          => ;
    [<oImage> := ] HSayFImage():Redefine( <oWnd>,<nId>,<image>, ;
        <bInit>,<bSize>,<ctoolt> );
    [; hwg_SetCtrlName( <oImage>,<(oImage)> )]
