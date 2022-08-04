
//New Control
#xcommand @ <x>,<y> SAY [ <oSay> CAPTION ] <caption> ;
            [ OF <oWnd> ]              ;
            LINK <cLink>               ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ COLOR <color> ]          ;
            [ BACKCOLOR <bcolor> ]     ;
            [<lTransp: TRANSPARENT>]   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ STYLE <nStyle> ]         ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <ctoolt> ]       ;
            [ VISITCOLOR <vcolor> ]    ;
            [ LINKCOLOR <lcolor> ]     ;
            [ HOVERCOLOR <hcolor> ]    ;
          => ;
    [<oSay> := ] HStaticLink():New( <oWnd>, <nId>, <nStyle>, <x>, <y>, <width>, ;
        <height>, <caption>, <oFont>, <bInit>, <bSize>, <bDraw>, <ctoolt>, ;
        <color>, <bcolor>, <.lTransp.>, <cLink>, <vcolor>, <lcolor>, <hcolor> );
    [; hwg_SetCtrlName( <oSay>,<(oSay)> )]


#xcommand REDEFINE SAY [ <oSay> CAPTION ] <cCaption>      ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            LINK <cLink>               ;
            [ COLOR <color> ]          ;
            [ BACKCOLOR <bcolor> ]     ;
            [<lTransp: TRANSPARENT>]   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <ctoolt> ]       ;
            [ VISITCOLOR <vcolor> ]    ;
            [ LINKCOLOR <lcolor> ]     ;
            [ HOVERCOLOR <hcolor> ]    ;
          => ;
    [<oSay> := ] HStaticLink():Redefine( <oWnd>, <nId>, <cCaption>, ;
        <oFont>, <bInit>, <bSize>, <bDraw>, <ctoolt>, <color>, <bcolor>,;
        <.lTransp.>, <cLink>, <vcolor>, <lcolor>, <hcolor> );
    [; hwg_SetCtrlName( <oSay>,<(oSay)> )]
