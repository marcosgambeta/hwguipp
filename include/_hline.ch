// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> LINE [ <oLine> ]    ;
            [ LENGTH <length> ]            ;
            [ OF <oWnd> ]                  ;
            [ ID <nId> ]                   ;
            [ <lVert: VERTICAL> ]          ;
            [ ON SIZE <bSize> ]            ;
            [ <class: CLASS> <classname> ] ;
          => ;
          [ <oLine> := ] __IIF(<.class.>, <classname>, HLine)():New(<oWnd>,<nId>,<.lVert.>,<nX>,<nY>,<length>,<bSize>);
          [; hwg_SetCtrlName(<oLine>,<(oLine)>)]
