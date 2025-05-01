// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> DATEPICKER [ <oPick> ] ;
            [ OF <oWnd> ]                     ;
            [ ID <nId> ]                      ;
            [ SIZE <nWidth>, <nHeight> ]      ;
            [ COLOR <nColor> ]                ;
            [ BACKCOLOR <nBackColor> ]        ;
            [ FONT <oFont> ]                  ;
            [ TOOLTIP <cTooltip> ]            ;
            [ ON INIT <bInit> ]               ;
            [ ON GETFOCUS <bGfocus> ]         ;
            [ ON LOSTFOCUS <bLfocus> ]        ;
            [ ON CHANGE <bChange> ]           ;
            [ INIT <dInit> ]                  ;
            [ STYLE <nStyle> ]                ;
            [ <class: CLASS> <classname> ]    ;
          => ;
          [ <oPick> := ] __IIF(<.class.>, <classname>, HDatePicker)():New(<oWnd>,<nId>,<dInit>,,<nStyle>,<nX>,<nY>, ;
          <nWidth>,<nHeight>,<oFont>,<bInit>,<bGfocus>,<bLfocus>,<bChange>,<cTooltip>, ;
          <nColor>,<nBackColor>);
          [; hwg_SetCtrlName(<oPick>,<(oPick)>)]

/* SAY ... GET system     */

#xcommand @ <nX>, <nY> GET DATEPICKER [ <oPick> VAR ] <vari> ;
            [ OF <oWnd> ]                                    ;
            [ ID <nId> ]                                     ;
            [ SIZE <nWidth>, <nHeight> ]                     ;
            [ COLOR <nColor> ]                               ;
            [ BACKCOLOR <nBackColor> ]                       ;
            [ FONT <oFont> ]                                 ;
            [ TOOLTIP <cTooltip> ]                           ;
            [ WHEN <bGfocus> ]                               ;
            [ VALID <bLfocus> ]                              ;
            [ ON INIT <bInit> ]                              ;
            [ ON CHANGE <bChange> ]                          ;
            [ STYLE <nStyle> ]                               ;
            [ <class: CLASS> <classname> ]                   ;
          => ;
          [ <oPick> := ] __IIF(<.class.>, <classname>, HDatePicker)():New(<oWnd>,<nId>,<vari>,    ;
          {|v|IIf(v == NIL, <vari>, <vari> := v)},      ;
          <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,      ;
          <oFont>,<bInit>,<bGfocus>,<bLfocus>,<bChange>,<cTooltip>,<nColor>,<nBackColor>);
          [; hwg_SetCtrlName(<oPick>,<(oPick)>)]
