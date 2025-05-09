// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

// trackbar control
#xcommand @ <nX>, <nY> TRACKBAR [ <oTrackBar> ] ;
            [ OF <oWnd> ]                       ;
            [ ID <nId> ]                        ;
            [ SIZE <nWidth>, <nHeight> ]        ;
            [ TOOLTIP <cTooltip> ]              ;
            [ RANGE <nLow>, <nHigh> ]           ;
            [ INIT <nInit> ]                    ;
            [ ON INIT <bInit> ]                 ;
            [ ON SIZE <bSize> ]                 ;
            [ ON PAINT <bDraw> ]                ;
            [ ON CHANGE <bChange> ]             ;
            [ ON DRAG <bDrag> ]                 ;
            [ <vertical: VERTICAL> ]            ;
            [ <autoticks: AUTOTICKS> ]          ;
            [ <noticks: NOTICKS> ]              ;
            [ <both: BOTH> ]                    ;
            [ <top: TOP> ]                      ;
            [ <left: LEFT> ]                    ;
            [ STYLE <nStyle> ]                  ;
            [ <class: CLASS> <classname> ]      ;
          => ;
          [ <oTrackBar> := ] __IIF(<.class.>, <classname>, HTrackBar)():New(<oWnd>, <nId>, <nInit>, <nStyle>, <nX>, <nY>,      ;
          <nWidth>, <nHeight>, <bInit>, <bSize>, <bDraw>, <cTooltip>, <bChange>, <bDrag>, <nLow>, <nHigh>, <.vertical.>,;
          IIf(<.autoticks.>, 1, IIf(<.noticks.>, 16, 0)), ;
          IIf(<.both.>, 8, IIf(<.top.> .OR. <.left.>, 4, 0))) ;
          [; hwg_SetCtrlName(<oTrackBar>, <(oTrackBar)>)]
