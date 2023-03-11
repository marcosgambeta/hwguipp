// animation control
#xcommand @ <nX>, <nY> ANIMATION [ <oAnimation> ] ;
            [ OF <oWnd> ]                       ;
            [ ID <nId> ]                        ;
            [ SIZE <nWidth>, <nHeight> ]        ;
            [ FILE <cFile> ]                    ;
            [ < autoplay: AUTOPLAY > ]          ;
            [ < center : CENTER > ]             ;
            [ < transparent: TRANSPARENT > ]    ;
            [ STYLE <nStyle> ]                  ;
	=>;
    [<oAnimation> :=] HAnimation():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>, ;
        <nWidth>,<nHeight>,<cFile>,<.autoplay.>,<.center.>,<.transparent.>);
    [; hwg_SetCtrlName( <oAnimation>,<(oAnimation)> )]
