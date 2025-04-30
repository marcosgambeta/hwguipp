// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> UPDOWN [ <oUpd> INIT ] <nInit> RANGE <nLower>,<nUpper>    ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ WIDTH <nUpDWidth> ]      ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ON GETFOCUS <bGfocus> ]  ;
            [ ON LOSTFOCUS <bLfocus> ] ;
            [ STYLE <nStyle> ]         ;
            [ <class: CLASS> <classname> ]       ;
          => ;
          [ <oUpd> := ] __IIF(<.class.>, <classname>, HUpDown)():New( <oWnd>,<nId>,<nInit>,,<nStyle>,<nX>,<nY>,<nWidth>, ;
          <nHeight>,<oFont>,<bInit>,<bSize>,<bDraw>,<bGfocus>,         ;
          <bLfocus>,<cTooltip>,<nColor>,<nBackColor>,<nUpDWidth>,<nLower>,<nUpper> );
          [; hwg_SetCtrlName( <oUpd>,<(oUpd)> )]

/* SAY ... GET system     */

#xcommand @ <nX>, <nY> GET UPDOWN [ <oUpd> VAR ]  <vari>  RANGE <nLower>,<nUpper>    ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ WIDTH <nUpDWidth> ]      ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ WHEN  <bGfocus> ]        ;
            [ VALID <bLfocus> ]        ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ STYLE <nStyle> ]         ;
            [ <class: CLASS> <classname> ]       ;
          => ;
          [ <oUpd> := ] __IIF(<.class.>, <classname>, HUpDown)():New( <oWnd>,<nId>,<vari>,               ;
          {|v|Iif(v==Nil,<vari>,<vari>:=v)},              ;
          <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,<bSize>,,  ;
          <bGfocus>,<bLfocus>,<cTooltip>,<nColor>,<nBackColor>, ;
          <nUpDWidth>,<nLower>,<nUpper> );
          [; hwg_SetCtrlName( <oUpd>,<(oUpd)> )]
