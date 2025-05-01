// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

// animation control
#xcommand @ <nX>, <nY> ANIMATION [ <oAnimation> ] ;
            [ OF <oWnd> ]                         ;
            [ ID <nId> ]                          ;
            [ SIZE <nWidth>, <nHeight> ]          ;
            [ FILE <cFile> ]                      ;
            [ <autoplay: AUTOPLAY> ]              ;
            [ <center: CENTER> ]                  ;
            [ <transparent: TRANSPARENT> ]        ;
            [ STYLE <nStyle> ]                    ;
            [ <class: CLASS> <classname> ]        ;
          => ;
          [ <oAnimation> := ] __IIF(<.class.>, <classname>, HAnimation)():New(<oWnd>,<nId>,<nStyle>,<nX>,<nY>, ;
          <nWidth>,<nHeight>,<cFile>,<.autoplay.>,<.center.>,<.transparent.>);
          [; hwg_SetCtrlName(<oAnimation>,<(oAnimation)>)]
