// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

//New Control

#xcommand @ <nX>, <nY> SAY [ <oSay> CAPTION ] <caption> ;
            [ OF <oWnd> ]              ;
            LINK <cLink>               ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ <lTransp: TRANSPARENT> ]   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ STYLE <nStyle> ]         ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ VISITCOLOR <vcolor> ]    ;
            [ LINKCOLOR <lcolor> ]     ;
            [ HOVERCOLOR <hcolor> ]    ;
            [ <class: CLASS> <classname> ]       ;
          => ;
          [ <oSay> := ] __IIF(<.class.>, <classname>, HStaticLink)():New( <oWnd>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, ;
          <nHeight>, <caption>, <oFont>, <bInit>, <bSize>, <bDraw>, <cTooltip>, ;
          <nColor>, <nBackColor>, <.lTransp.>, <cLink>, <vcolor>, <lcolor>, <hcolor> );
          [; hwg_SetCtrlName( <oSay>,<(oSay)> )]

#xcommand REDEFINE SAY [ <oSay> CAPTION ] <cCaption>      ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            LINK <cLink>               ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ <lTransp: TRANSPARENT> ]   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ VISITCOLOR <vcolor> ]    ;
            [ LINKCOLOR <lcolor> ]     ;
            [ HOVERCOLOR <hcolor> ]    ;
          => ;
          [ <oSay> := ] HStaticLink():Redefine( <oWnd>, <nId>, <cCaption>, ;
          <oFont>, <bInit>, <bSize>, <bDraw>, <cTooltip>, <nColor>, <nBackColor>,;
          <.lTransp.>, <cLink>, <vcolor>, <lcolor>, <hcolor> );
          [; hwg_SetCtrlName( <oSay>,<(oSay)> )]
