// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> PAGER [ <oTool> ] ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ <lVert: VERTICAL> ] ;
            [ STYLE <nStyle> ]         ;
          => ;
    [<oTool> := ] HPager():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, <nHeight>,,,,,,,,,<.lVert.>);
    [; hwg_SetCtrlName( <oTool>,<(oTool)> )]
