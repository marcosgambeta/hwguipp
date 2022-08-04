#xcommand @ <x>,<y> PAGER [ <oTool> ] ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ STYLE <nStyle> ]         ;
            [ <lVert: VERTICAL> ] ;
          => ;
    [<oTool> := ] HPager():New( <oWnd>,<nId>,<nStyle>,<x>,<y>,<width>, <height>,,,,,,,,,<.lVert.>);
    [; hwg_SetCtrlName( <oTool>,<(oTool)> )]
