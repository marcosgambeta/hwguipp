// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> HCEDIT [ <oTEdit> ] ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ON GETFOCUS <bGfocus> ]  ;
            [ ON LOSTFOCUS <bLfocus> ] ;
            [ <lNoVScr: NO VSCROLL> ]  ;
            [ <lNoBord: NO BORDER> ]   ;
            [ STYLE <nStyle> ]         ;
            [ <class: CLASS> <classname> ]       ;
          => ;
          [ <oTEdit> := ] __IIF(<.class.>, <classname>, HCEdit)():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>,<nHeight>, ;
          <oFont>,<bInit>,<bSize>,<bDraw>,<nColor>,<nBackColor>,<bGfocus>,<bLfocus>, ;
          <.lNoVScr.>,<.lNoBord.> )
