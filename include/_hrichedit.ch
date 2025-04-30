// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> RICHEDIT [ <oEdit> TEXT ] <vari> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ <lallowtabs: ALLOWTABS> ]  ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON GETFOCUS <bGfocus> ]  ;
            [ ON LOSTFOCUS <bLfocus> ] ;
            [ ON CHANGE <bChange>]     ;
            [ ;
              [ ON OTHER MESSAGES <bOther> ] ;
              [ ON OTHERMESSAGES <bOther>] ;
            ] ;
            [ STYLE <nStyle> ]         ;
            [ <class: CLASS> <classname> ]       ;
          => ;
          [ <oEdit> := ] __IIF(<.class.>, <classname>, HRichEdit)():New( <oWnd>,<nId>,<vari>,<nStyle>,<nX>,<nY>,<nWidth>, ;
          <nHeight>,<oFont>,<bInit>,<bSize>,<bGfocus>, ;
          <bLfocus>,<cTooltip>,<nColor>,<nBackColor>,<bOther>,<.lallowtabs.>,<bChange> );
          [; hwg_SetCtrlName( <oEdit>,<(oEdit)> )]
