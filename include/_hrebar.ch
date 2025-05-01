// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> REBAR [ <oTool> ]   ;
            [ OF <oWnd> ]                  ;
            [ ID <nId> ]                   ;
            [ SIZE <nWidth>, <nHeight> ]   ;
            [ STYLE <nStyle> ]             ;
            [ <class: CLASS> <classname> ] ;
          => ;
          [ <oTool> := ] __IIF(<.class.>, <classname>, HREBAR)():New(<oWnd>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>, , , , , , , ,) ;
          [; hwg_SetCtrlName(<oTool>, <(oTool)>)]

#xcommand ADDBAND <hWnd> to <opage> ;
            [ BACKCOLOR <b> ]       ;
            [ FORECOLOR <f> ]       ;
            [ STYLE <nstyle> ]      ;
            [ TEXT <t> ]            ;
          => ;
          <opage>:ADDBARColor(<hWnd>, <f>, <b>, <t>, <nstyle>)

#xcommand ADDBAND <hWnd> to <opage> ;
            [ BITMAP <b> ]          ;
            [ STYLE <nstyle> ]      ;
            [ TEXT <t> ]            ;
          => ;
          <opage>:ADDBARBITMAP(<hWnd>, <b>, <t>, <nstyle>)
