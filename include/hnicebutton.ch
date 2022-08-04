
// Nice Buttons by Luiz Rafael
#xcommand @ <x>,<y> NICEBUTTON [ <oBut> CAPTION ] <caption> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ ON INIT <bInit> ]        ;
            [ ON CLICK <bClick> ]      ;
            [ STYLE <nStyle> ]         ;
            [ EXSTYLE <nStyleEx> ]         ;
            [ TOOLTIP <ctoolt> ]       ;
            [ RED <r> ] ;
            [ GREEN <g> ];
            [ BLUE <b> ];
          => ;
    [<oBut> := ] HNicebutton():New( <oWnd>,<nId>,<nStyle>,<nStyleEx>,<x>,<y>,<width>, ;
             <height>,<bInit>,<bClick>,<caption>,<ctoolt>,<r>,<g>,<b> );
    [; hwg_SetCtrlName( <oBut>,<(oBut)> )]


#xcommand REDEFINE NICEBUTTON [ <oBut> CAPTION ] <caption> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ ON INIT <bInit> ]        ;
            [ ON CLICK <bClick> ]      ;
            [ EXSTYLE <nStyleEx> ]         ;
            [ TOOLTIP <ctoolt> ]       ;
            [ RED <r> ] ;
            [ GREEN <g> ];
            [ BLUE <b> ];
          => ;
    [<oBut> := ] HNicebutton():Redefine( <oWnd>,<nId>,<nStyleEx>, ;
             <bInit>,<bClick>,<caption>,<ctoolt>,<r>,<g>,<b> );
    [; hwg_SetCtrlName( <oBut>,<(oBut)> )]
