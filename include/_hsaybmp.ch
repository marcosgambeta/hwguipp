// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> BITMAP [ <oBmp> SHOW ] <bitmap> ;
            [ <res: FROM RESOURCE> ]     ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ TOOLTIP <cTooltip> ]       ;
            [ STRETCH <nStretch>]      ;
            [ <lTransp: TRANSPARENT> ;
              [ COLOR <trcolor> ] ;
            ] ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON CLICK <bClick> ]      ;
            [ ON DBLCLICK <bDblClick> ];
            [ <class: CLASS> <classname> ]       ;
          => ;
          [ <oBmp> := ] __IIF(<.class.>, <classname>, HSayBmp)():New( <oWnd>,<nId>,<nX>,<nY>,<nWidth>, ;
          <nHeight>,<bitmap>,<.res.>,<bInit>,<bSize>,<cTooltip>,<bClick>,<bDblClick>,<.lTransp.>,<nStretch>,<trcolor>,<nBackColor> );
          [; hwg_SetCtrlName( <oBmp>,<(oBmp)> )]

#xcommand REDEFINE BITMAP [ <oBmp> SHOW ] <bitmap> ;
            [ <res: FROM RESOURCE> ]     ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ TOOLTIP <cTooltip> ]       ;
          => ;
          [ <oBmp> := ] HSayBmp():Redefine( <oWnd>,<nId>,<bitmap>,<.res.>, ;
          <bInit>,<bSize>,<cTooltip> );
          [; hwg_SetCtrlName( <oBmp>,<(oBmp)> )]
