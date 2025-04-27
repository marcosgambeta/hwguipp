// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> TOOLBAR [ <oTool> ] ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ STYLE <nStyle> ]         ;
            [ ITEMS <aItems> ] ;
            [ <class: CLASS> <classname> ]       ;
          => ;
    [ <oTool> := ] __IIF(<.class.>, <classname>, Htoolbar)():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, <nHeight>,,,,,,,,,,,<aItems>  );
    [; hwg_SetCtrlName( <oTool>,<(oTool)> )]

#xcommand REDEFINE TOOLBAR  <oTool>    ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ITEM <aitem>];
          => ;
    [ <oTool> := ] Htoolbar():Redefine( <oWnd>,<nId>,,  ,<bInit>,<bSize>,<bDraw>, , , , ,<aitem> );
    [; hwg_SetCtrlName( <oTool>,<(oTool)> )]

#xcommand TOOLBUTTON  <O> ;
          ID <nId> ;
          [ BITMAP <nBitIp> ];
          [ STYLE <bstyle> ];
          [ STATE <bstate>];
          [ TEXT <ctext> ] ;
          [ TOOLTIP <cTooltip> ];
          [ MENU <d>];
           ON CLICK <bclick>;
          =>;
          <O>:AddButton(<nBitIp>,<nId>,<bstate>,<bstyle>,<ctext>,<bclick>,<cTooltip>,<d>)

#xcommand ADD TOOLBUTTON  <O> ;
          ID <nId> ;
          [ BITMAP <nBitIp> ];
          [ STYLE <bstyle> ];
          [ STATE <bstate>];
          [ TEXT <ctext> ] ;
          [ TOOLTIP <cTooltip> ];
          [ MENU <d>];
           ON CLICK <bclick>;
          =>;
          aadd(<O> ,\{<nBitIp>,<nId>,<bstate>,<bstyle>,,<ctext>,<bclick>,<cTooltip>,<d>,\})
