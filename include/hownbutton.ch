#xcommand @ <x>,<y> OWNERBUTTON [ <oOwnBtn> ]  ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ BACKCOLOR <bcolor> ]     ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bPaint> ]      ;
            [ ON CLICK <bClick> ]      ;
            [ HSTYLES <aStyles,...> ]  ;
            [ <flat: FLAT> ]           ;
            [ <enable: DISABLED> ]     ;
            [ TEXT <cText>             ;
                 [ COLOR <color>] [ FONT <font> ] ;
                 [ COORDINATES  <xt>, <yt>, <widtht>, <heightt> ] ;
            ] ;
            [ BITMAP <bmp>  [<res: FROM RESOURCE>] [<ltr: TRANSPARENT> [COLOR  <trcolor> ]] ;
                 [ COORDINATES  <xb>, <yb>, <widthb>, <heightb> ] ;
            ] ;
            [ TOOLTIP <ctoolt> ]    ;
            [ <lCheck: CHECK> ]     ;
          => ;
    [<oOwnBtn> :=] HOWNBUTTON():New( <oWnd>,<nId>,\{<aStyles>\},<x>,<y>,<width>, ;
          <height>,<bInit>,<bSize>,<bPaint>, ;
          <bClick>,<.flat.>, ;
              <cText>,<color>,<font>,<xt>, <yt>,<widtht>,<heightt>, ;
              <bmp>,<.res.>,<xb>,<yb>,<widthb>,<heightb>,<.ltr.>,<trcolor>, <ctoolt>,!<.enable.>,<.lCheck.>,<bcolor> );
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
                 [ COLOR <color>] [ FONT <font> ] ;
                 [ COORDINATES  <xt>, <yt>, <widtht>, <heightt> ] ;
            ] ;
            [ BITMAP <bmp>  [<res: FROM RESOURCE>] [<ltr: TRANSPARENT>] ;
                 [ COORDINATES  <xb>, <yb>, <widthb>, <heightb> ] ;
            ] ;
            [ TOOLTIP <ctoolt> ]    ;
            [ <enable: DISABLED> ]        ;
          => ;
    [<oOwnBtn> :=] HOWNBUTTON():Redefine( <oWnd>,<nId>, ;
          <bInit>,<bSize>,<bPaint>, ;
          <bClick>,<.flat.>, ;
              <cText>,<color>,<font>,<xt>, <yt>,<widtht>,<heightt>, ;
              <bmp>,<.res.>,<xb>, <yb>,<widthb>,<heightb>,<.ltr.>, <ctoolt>, !<.enable.>);
    [; hwg_SetCtrlName( <oOwnBtn>,<(oOwnBtn)> )]