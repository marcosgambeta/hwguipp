#xcommand @ <x>,<y> HCEDIT [ <oTEdit> ] ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ COLOR <color> ]          ;
            [ BACKCOLOR <bcolor> ]     ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ON GETFOCUS <bGfocus> ]  ;
            [ ON LOSTFOCUS <bLfocus> ] ;
            [ STYLE <nStyle> ]         ;
            [ <lNoVScr: NO VSCROLL> ]  ;
            [ <lNoBord: NO BORDER> ]   ;
            [ FONT <oFont> ]           ;
          => ;
    [<oTEdit> :=] HCEdit():New( <oWnd>,<nId>,<nStyle>,<x>,<y>,<width>,<height>, ;
       <oFont>,<bInit>,<bSize>,<bDraw>,<color>,<bcolor>,<bGfocus>,<bLfocus>, ;
       <.lNoVScr.>,<.lNoBord.> )
