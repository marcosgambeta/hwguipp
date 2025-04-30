// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand ADD STATUS [ <oStat> ] [ TO <oWnd> ] ;
            [ ID <nId> ]                       ;
            [ ON INIT <bInit> ]                ;
            [ ON SIZE <bSize> ]                ;
            [ ON PAINT <bDraw> ]               ;
            [ STYLE <nStyle> ]                 ;
            [ FONT <oFont> ]                   ;
            [ PARTS <aparts,...> ]             ;
          => ;
          [ <oStat> := ] HStatus():New( <oWnd>,<nId>,<nStyle>,<oFont>,\{<aparts>\},<bInit>,;
          <bSize>,<bDraw> );
          [; hwg_SetCtrlName( <oStat>,<(oStat)> )]

#xcommand REDEFINE STATUS <oSay>    ;
            [ OF <oWnd> ]           ;
            ID <nId>                ;
            [ ON INIT <bInit> ]     ;
            [ ON SIZE <bSize> ]     ;
            [ ON PAINT <bDraw> ]    ;
            [ PARTS <bChange,...> ] ;
          => ;
          [ <oSay> := ] HStatus():Redefine( <oWnd>,<nId>,,  ,<bInit>,<bSize>,<bDraw>, , , , ,\{<bChange>\} ) ;
          [; hwg_SetCtrlName( <oSay>,<(oSay)> )]
