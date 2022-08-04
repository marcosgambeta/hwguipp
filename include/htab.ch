#xcommand @ <x>,<y> TAB [ <oTab> ITEMS ] <aItems> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ STYLE <nStyle> ]         ;
            [ FONT <oFont> ]           ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ON CHANGE <bChange> ]    ;
            [ ON CLICK <bClick> ]      ;
            [ ON GETFOCUS <bGetFocus> ];
            [ ON LOSTFOCUS <bLostFocus>];
            [ BITMAP <aBmp>  [<res: FROM RESOURCE>] [ BITCOUNT <nBC> ] ]  ;
          => ;
    [<oTab> := ] HTab():New( <oWnd>,<nId>,<nStyle>,<x>,<y>,<width>, ;
             <height>,<oFont>,<bInit>,<bSize>,<bDraw>,<aItems>,<bChange>, <aBmp>, <.res.>,<nBC>,;
             <bClick>, <bGetFocus>, <bLostFocus> );
    [; hwg_SetCtrlName( <oTab>,<(oTab)> )]

#xcommand BEGIN PAGE <cname> OF <oTab> ;
          => ;
    <oTab>:StartPage( <cname> )

#xcommand END PAGE OF <oTab> ;
          => ;
    <oTab>:EndPage()

#xcommand ENDPAGE OF <oTab> ;
          => ;
    <oTab>:EndPage()

#xcommand REDEFINE TAB  <oTab>  ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ COLOR <color> ]          ;
            [ BACKCOLOR <bcolor> ]     ;
          => ;
    [<oTab> := ] Htab():Redefine( <oWnd>,<nId>,,  ,<bInit>,<bSize>,<bDraw>, ,<color>,<bcolor>, , );
    [; hwg_SetCtrlName( <oTab>,<(oTab)> )]
