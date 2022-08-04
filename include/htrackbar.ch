// trackbar control
#xcommand @ <x>,<y> TRACKBAR [ <oTrackBar> ]  ;
            [ OF <oWnd> ]                 ;
            [ ID <nId> ]                  ;
            [ SIZE <width>, <height> ]    ;
            [ RANGE <nLow>,<nHigh> ]      ;
            [ INIT <nInit> ]              ;
            [ ON INIT <bInit> ]           ;
            [ ON SIZE <bSize> ]           ;
            [ ON PAINT <bDraw> ]          ;
            [ ON CHANGE <bChange> ]       ;
            [ ON DRAG <bDrag> ]           ;
            [ STYLE <nStyle> ]            ;
            [ TOOLTIP <cTooltip> ]        ;
            [ < vertical : VERTICAL > ]   ;
            [ < autoticks : AUTOTICKS > ] ;
            [ < noticks : NOTICKS > ]     ;
            [ < both : BOTH > ]           ;
            [ < top : TOP > ]             ;
            [ < left : LEFT > ]           ;
          => ;
    [<oTrackBar> :=] HTrackBar():New( <oWnd>,<nId>,<nInit>,<nStyle>,<x>,<y>,      ;
        <width>,<height>,<bInit>,<bSize>,<bDraw>,<cTooltip>,<bChange>,<bDrag>,<nLow>,<nHigh>,<.vertical.>,;
        Iif(<.autoticks.>,1,Iif(<.noticks.>,16,0)), ;
        Iif(<.both.>,8,Iif(<.top.>.or.<.left.>,4,0)) );
    [; hwg_SetCtrlName( <oTrackBar>,<(oTrackBar)> )]
