// animation control
#xcommand @ <x>,<y>  ANIMATION [ <oAnimation> ] ;
            [ OF <oWnd> ]                       ;
            [ ID <nId> ]                        ;
            [ STYLE <nStyle> ]                  ;
            [ SIZE <nWidth>, <nHeight> ]        ;
            [ FILE <cFile> ]                    ;
            [ < autoplay: AUTOPLAY > ]          ;
            [ < center : CENTER > ]             ;
            [ < transparent: TRANSPARENT > ]    ;
	=>;
    [<oAnimation> :=] HAnimation():New( <oWnd>,<nId>,<nStyle>,<x>,<y>, ;
        <nWidth>,<nHeight>,<cFile>,<.autoplay.>,<.center.>,<.transparent.>);
    [; hwg_SetCtrlName( <oAnimation>,<(oAnimation)> )]
