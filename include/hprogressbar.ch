// Contribution ATZCT" <atzct@obukhov.kiev.ua
#xcommand @ <x>,<y> PROGRESSBAR <oPBar>       ;
            [ OF <oWnd> ]                       ;
            [ ID <nId> ]                        ;
            [ SIZE <nWidth>,<nHeight> ]         ;
            [ BARWIDTH <maxpos> ]               ;
            [ QUANTITY <nRange> ]               ;
            =>                                  ;
            <oPBar> :=  HProgressBar():New( <oWnd>,<nId>,<x>,<y>,<nWidth>, ;
                       <nHeight>,<maxpos>,<nRange> );
            [; hwg_SetCtrlName( <oPBar>,<(oPBar)> )]


#xcommand REDEFINE progress  [ <oBmp>  ] ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ TOOLTIP <ctoolt> ]       ;
            [ MAXPOS <mpos> ] ;
            [ RANGE <nRange> ] ;
          => ;
    [<oBmp> := ] HProgressBar():Redefine( <oWnd>,<nId>,<mpos>,<nRange>, ;
        <bInit>,<bSize>,,<ctoolt> );
    [; hwg_SetCtrlName( <oBmp>,<(oBmp)> )]
