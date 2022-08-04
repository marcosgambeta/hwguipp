#xcommand @ <x>,<y> TOOLBAR [ <oTool> ] ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ STYLE <nStyle> ]         ;
            [ ITEMS <aItems> ] ;
          => ;
    [<oTool> := ] Htoolbar():New( <oWnd>,<nId>,<nStyle>,<x>,<y>,<width>, <height>,,,,,,,,,,,<aItems>  );
    [; hwg_SetCtrlName( <oTool>,<(oTool)> )]

#xcommand REDEFINE TOOLBAR  <oTool>    ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ITEM <aitem>];
          => ;
    [<oTool> := ] Htoolbar():Redefine( <oWnd>,<nId>,,  ,<bInit>,<bSize>,<bDraw>, , , , ,<aitem> );
    [; hwg_SetCtrlName( <oTool>,<(oTool)> )]

#xcommand TOOLBUTTON  <O> ;
          ID <nId> ;
          [ BITMAP <nBitIp> ];
          [ STYLE <bstyle> ];
          [ STATE <bstate>];
          [ TEXT <ctext> ] ;
          [ TOOLTIP <c> ];
          [ MENU <d>];
           ON CLICK <bclick>;
          =>;
          <O>:AddButton(<nBitIp>,<nId>,<bstate>,<bstyle>,<ctext>,<bclick>,<c>,<d>)

#xcommand ADD TOOLBUTTON  <O> ;
          ID <nId> ;
          [ BITMAP <nBitIp> ];
          [ STYLE <bstyle> ];
          [ STATE <bstate>];
          [ TEXT <ctext> ] ;
          [ TOOLTIP <c> ];
          [ MENU <d>];
           ON CLICK <bclick>;
          =>;
          aadd(<O> ,\{<nBitIp>,<nId>,<bstate>,<bstyle>,,<ctext>,<bclick>,<c>,<d>,\})
