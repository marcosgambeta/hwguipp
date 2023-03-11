// Nice Buttons by Luiz Rafael

#xcommand @ <nX>, <nY> NICEBUTTON [ <oBut> CAPTION ] <caption> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ TOOLTIP <cTooltip> ]       ;
            [ ON INIT <bInit> ]        ;
            [ ON CLICK <bClick> ]      ;
            [ EXSTYLE <nStyleEx> ]         ;
            [ RED <r> ] ;
            [ GREEN <g> ];
            [ BLUE <b> ];
            [ STYLE <nStyle> ]         ;
          => ;
    [<oBut> := ] HNicebutton():New( <oWnd>,<nId>,<nStyle>,<nStyleEx>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<bInit>,<bClick>,<caption>,<cTooltip>,<r>,<g>,<b> );
    [; hwg_SetCtrlName( <oBut>,<(oBut)> )]


#xcommand REDEFINE NICEBUTTON [ <oBut> CAPTION ] <caption> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ ON INIT <bInit> ]        ;
            [ ON CLICK <bClick> ]      ;
            [ EXSTYLE <nStyleEx> ]         ;
            [ TOOLTIP <cTooltip> ]       ;
            [ RED <r> ] ;
            [ GREEN <g> ];
            [ BLUE <b> ];
          => ;
    [<oBut> := ] HNicebutton():Redefine( <oWnd>,<nId>,<nStyleEx>, ;
             <bInit>,<bClick>,<caption>,<cTooltip>,<r>,<g>,<b> );
    [; hwg_SetCtrlName( <oBut>,<(oBut)> )]
