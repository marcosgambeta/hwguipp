#xcommand @ <nX>, <nY> DATEPICKER [ <oPick> ]  ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ ON INIT <bInit> ]        ;
            [ ON GETFOCUS <bGfocus> ]  ;
            [ ON LOSTFOCUS <bLfocus> ] ;
            [ ON CHANGE <bChange> ]    ;
            [ INIT <dInit> ]           ;
            [ STYLE <nStyle> ]         ;
          => ;
    [<oPick> :=] HDatePicker():New( <oWnd>,<nId>,<dInit>,,<nStyle>,<nX>,<nY>, ;
        <nWidth>,<nHeight>,<oFont>,<bInit>,<bGfocus>,<bLfocus>,<bChange>,<cTooltip>, ;
        <nColor>,<nBackColor> );
    [; hwg_SetCtrlName( <oPick>,<(oPick)> )]

/* SAY ... GET system     */

#xcommand @ <nX>, <nY> GET DATEPICKER [ <oPick> VAR ] <vari> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ WHEN <bGfocus> ]         ;
            [ VALID <bLfocus> ]        ;
            [ ON INIT <bInit> ]        ;
            [ ON CHANGE <bChange> ]    ;
            [ STYLE <nStyle> ]         ;
          => ;
    [<oPick> :=] HDatePicker():New( <oWnd>,<nId>,<vari>,    ;
                    {|v|Iif(v==Nil,<vari>,<vari>:=v)},      ;
                    <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,      ;
                    <oFont>,<bInit>,<bGfocus>,<bLfocus>,<bChange>,<cTooltip>,<nColor>,<nBackColor> );
    [; hwg_SetCtrlName( <oPick>,<(oPick)> )]
