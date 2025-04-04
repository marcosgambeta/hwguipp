// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> COMBOBOX [ <oCombo> ITEMS ] <aItems> ;
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
            [ ON CHANGE <bChange> ]    ;
            [ ON GETFOCUS <bWhen> ]    ;
            [ ON LOSTFOCUS <bValid> ]  ;
            [ INIT <nInit> ]           ;
            [ <edit: EDIT> ]           ;
            [ <text: TEXT> ]           ;
            [ DISPLAYCOUNT <nDisplay>] ;
            [ STYLE <nStyle> ]         ;
          => ;
    [<oCombo> := ] HComboBox():New( <oWnd>,<nId>,<nInit>,,<nStyle>,<nX>,<nY>,<nWidth>, ;
                  <nHeight>,<aItems>,<oFont>,<bInit>,<bSize>,<bDraw>,<bChange>,<cTooltip>,;
                  <.edit.>,<.text.>,<bWhen>,<nColor>,<nBackColor>,<bValid>,<nDisplay> );
    [; hwg_SetCtrlName( <oCombo>,<(oCombo)> )]

#xcommand REDEFINE COMBOBOX [ <oCombo> ITEMS ] <aItems> ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ INIT <nInit>    ]        ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ON CHANGE <bChange> ]    ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
          => ;
    [<oCombo> := ] HComboBox():Redefine( <oWnd>,<nId>,<nInit>,,<aItems>,<oFont>,<bInit>, ;
             <bSize>,<bDraw>,<bChange>,<cTooltip> );
    [; hwg_SetCtrlName( <oCombo>,<(oCombo)> )]

/* SAY ... GET system     */

#xcommand @ <nX>, <nY> GET COMBOBOX [ <oCombo> VAR ] <vari> ITEMS <aItems> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON CHANGE <bChange> ]    ;
            [ <edit: EDIT> ]           ;
            [ <text: TEXT> ]           ;
            [ WHEN <bWhen> ]           ;
            [ VALID <bValid> ]         ;
            [ DISPLAYCOUNT <nDisplay>] ;
            [ STYLE <nStyle> ]         ;
          => ;
    [<oCombo> := ] HComboBox():New( <oWnd>,<nId>,<vari>,    ;
                    {|v|Iif(v==Nil,<vari>,<vari>:=v)},      ;
                    <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,      ;
                    <aItems>,<oFont>,<bInit>,<bSize>,,<bChange>,<cTooltip>, ;
                    <.edit.>,<.text.>,<bWhen>,<nColor>,<nBackColor>,<bValid>,<nDisplay> );
    [; hwg_SetCtrlName( <oCombo>,<(oCombo)> )]

#xcommand REDEFINE GET COMBOBOX [ <oCombo> VAR ] <vari> ;
            ITEMS  <aItems>            ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON CHANGE <bChange> ]    ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ WHEN <bWhen> ]           ;
          => ;
    [<oCombo> := ] HComboBox():Redefine( <oWnd>,<nId>,<vari>, ;
                    {|v|Iif(v==Nil,<vari>,<vari>:=v)},        ;
                    <aItems>,<oFont>,,,,<bChange>,<cTooltip>, <bWhen> );
    [; hwg_SetCtrlName( <oCombo>,<(oCombo)> )]
