// Contribution ATZCT" <atzct@obukhov.kiev.ua

#xcommand @ <nX>, <nY> PROGRESSBAR <oPBar>       ;
            [ OF <oWnd> ]                       ;
            [ ID <nId> ]                        ;
            [ SIZE <nWidth>,<nHeight> ]         ;
            [ BARWIDTH <maxpos> ]               ;
            [ QUANTITY <nRange> ]               ;
            =>                                  ;
            <oPBar> :=  HProgressBar():New( <oWnd>,<nId>,<nX>,<nY>,<nWidth>, ;
                       <nHeight>,<maxpos>,<nRange> );
            [; hwg_SetCtrlName( <oPBar>,<(oPBar)> )]


#xcommand REDEFINE progress  [ <oBmp>  ] ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ TOOLTIP <cTooltip> ]       ;
            [ MAXPOS <mpos> ] ;
            [ RANGE <nRange> ] ;
          => ;
    [<oBmp> := ] HProgressBar():Redefine( <oWnd>,<nId>,<mpos>,<nRange>, ;
        <bInit>,<bSize>,,<cTooltip> );
    [; hwg_SetCtrlName( <oBmp>,<(oBmp)> )]
