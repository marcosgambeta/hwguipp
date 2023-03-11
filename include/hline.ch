#xcommand @ <nX>, <nY> LINE [ <oLine> ]   ;
            [ LENGTH <length> ]        ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [<lVert: VERTICAL>]        ;
            [ ON SIZE <bSize> ]        ;
          => ;
    [<oLine> := ] HLine():New( <oWnd>,<nId>,<.lVert.>,<nX>,<nY>,<length>,<bSize> );
    [; hwg_SetCtrlName( <oLine>,<(oLine)> )]
