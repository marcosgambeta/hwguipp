// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> OWNERBUTTON [ <oOwnBtn> ]  ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ TOOLTIP <cTooltip> ]    ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bPaint> ]      ;
            [ ON CLICK <bClick> ]      ;
            [ HSTYLES <aStyles,...> ]  ;
            [ <flat: FLAT> ]           ;
            [ <enable: DISABLED> ]     ;
            [ TEXT <cText>             ;
                 [ COLOR <nColor>] [ FONT <font> ] ;
                 [ COORDINATES  <xt>, <yt>, <widtht>, <heightt> ] ;
            ] ;
            [ BITMAP <bmp>  [<res: FROM RESOURCE>] [<ltr: TRANSPARENT> [COLOR  <trcolor> ]] ;
                 [ COORDINATES  <xb>, <yb>, <widthb>, <heightb> ] ;
            ] ;
            [ <lCheck: CHECK> ]     ;
          => ;
    [<oOwnBtn> :=] HOWNBUTTON():New( <oWnd>,<nId>,\{<aStyles>\},<nX>,<nY>,<nWidth>, ;
          <nHeight>,<bInit>,<bSize>,<bPaint>, ;
          <bClick>,<.flat.>, ;
              <cText>,<nColor>,<font>,<xt>, <yt>,<widtht>,<heightt>, ;
              <bmp>,<.res.>,<xb>,<yb>,<widthb>,<heightb>,<.ltr.>,<trcolor>, <cTooltip>,!<.enable.>,<.lCheck.>,<nBackColor> );
    [; hwg_SetCtrlName( <oOwnBtn>,<(oOwnBtn)> )]


#xcommand REDEFINE OWNERBUTTON [ <oOwnBtn> ]  ;
            [ OF <oWnd> ]                     ;
            ID <nId>                          ;
            [ ON INIT <bInit> ]     ;
            [ ON SIZE <bSize> ]     ;
            [ ON PAINT <bPaint> ]   ;
            [ ON CLICK <bClick> ]   ;
            [ <flat: FLAT> ]        ;
            [ TEXT <cText>          ;
                 [ COLOR <nColor>] [ FONT <font> ] ;
                 [ COORDINATES  <xt>, <yt>, <widtht>, <heightt> ] ;
            ] ;
            [ BITMAP <bmp>  [<res: FROM RESOURCE>] [<ltr: TRANSPARENT>] ;
                 [ COORDINATES  <xb>, <yb>, <widthb>, <heightb> ] ;
            ] ;
            [ TOOLTIP <cTooltip> ]    ;
            [ <enable: DISABLED> ]        ;
          => ;
    [<oOwnBtn> :=] HOWNBUTTON():Redefine( <oWnd>,<nId>, ;
          <bInit>,<bSize>,<bPaint>, ;
          <bClick>,<.flat.>, ;
              <cText>,<nColor>,<font>,<xt>, <yt>,<widtht>,<heightt>, ;
              <bmp>,<.res.>,<xb>, <yb>,<widthb>,<heightb>,<.ltr.>, <cTooltip>, !<.enable.>);
    [; hwg_SetCtrlName( <oOwnBtn>,<(oOwnBtn)> )]
