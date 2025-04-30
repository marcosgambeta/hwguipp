// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> RADIOBUTTON [ <oRadio> CAPTION ] <caption> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ON CLICK <bClick> ]      ;
            [ <lTransp: TRANSPARENT> ]   ;
            [ STYLE <nStyle> ]         ;
            [ <class: CLASS> <classname> ]       ;
          => ;
          [ <oRadio> := ] __IIF(<.class.>, <classname>, HRadioButton)():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>, ;
          <nWidth>,<nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<bClick>,<cTooltip>,<nColor>,<nBackColor>,<.lTransp.> );
          [; hwg_SetCtrlName( <oRadio>,<(oRadio)> )]

#xcommand REDEFINE RADIOBUTTON [ <oRadio> ] ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ON CLICK <bClick> ]      ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
          => ;
          [ <oRadio> := ] HRadioButton():Redefine( <oWnd>,<nId>,<oFont>,<bInit>,<bSize>, ;
          <bDraw>,<bClick>,<cTooltip>,<nColor>,<nBackColor> );
          [; hwg_SetCtrlName( <oRadio>,<(oRadio)> )]
