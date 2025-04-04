// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> SHADEBUTTON [ <oShBtn> ]  ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ TOOLTIP <cTooltip> ]    ;
            [ EFFECT <shadeID>  [ PALETTE <palet> ]             ;
                 [ GRANULARITY <granul> ] [ HIGHLIGHT <highl> ] ;
                 [ COLORING <coloring> ] [ SHCOLOR <shcolor> ] ];
            [ ON INIT <bInit> ]     ;
            [ ON SIZE <bSize> ]     ;
            [ ON PAINT <bPaint> ]    ;
            [ ON CLICK <bClick> ]   ;
            [ <flat: FLAT> ]        ;
            [ <enable: DISABLED> ]  ;
            [ TEXT <cText>          ;
                 [ COLOR <nColor>] [ FONT <font> ] ;
                 [ COORDINATES  <xt>, <yt> ] ;
            ] ;
            [ BITMAP <bmp>  [<res: FROM RESOURCE>] [<ltr: TRANSPARENT> [COLOR  <trcolor> ]] ;
                 [ COORDINATES  <xb>, <yb>, <widthb>, <heightb> ] ;
            ] ;
            [ STYLE <nStyle> ]      ;
          => ;
    [<oShBtn> :=] HSHADEBUTTON():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
          <nHeight>,<bInit>,<bSize>,<bPaint>, ;
          <bClick>,<.flat.>, ;
              <cText>,<nColor>,<font>,<xt>, <yt>, ;
              <bmp>,<.res.>,<xb>,<yb>,<widthb>,<heightb>,<.ltr.>,<trcolor>, ;
              <cTooltip>,!<.enable.>,<shadeID>,<palet>,<granul>,<highl>,<coloring>,<shcolor> );
    [; hwg_SetCtrlName( <oShBtn>,<(oShBtn)> )]
