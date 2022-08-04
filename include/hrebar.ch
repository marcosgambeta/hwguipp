
#xcommand @ <x>,<y> REBAR [ <oTool> ] ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ STYLE <nStyle> ]         ;
          => ;
    [<oTool> := ] HREBAR():New( <oWnd>,<nId>,<nStyle>,<x>,<y>,<width>, <height>,,,,,,,,);
    [; hwg_SetCtrlName( <oTool>,<(oTool)> )]

#xcommand ADDBAND <hWnd> to <opage> ;
          [BACKCOLOR <b> ] [FORECOLOR <f>] ;
          [STYLE <nstyle>] [TEXT <t>] ;
          => <opage>:ADDBARColor(<hWnd>,<f>,<b>,<t>,<nstyle>)

#xcommand ADDBAND <hWnd> to <opage> ;
          [BITMAP <b> ]  ;
          [STYLE <nstyle>] [TEXT <t>] ;
          => <opage>:ADDBARBITMAP(<hWnd>,<b>,<t>,<nstyle>)
