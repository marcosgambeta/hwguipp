// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> TAB [ <oTab> ITEMS ] <aItems> ;
            [ OF <oWnd> ]                            ;
            [ ID <nId> ]                             ;
            [ SIZE <nWidth>, <nHeight> ]             ;
            [ STYLE <nStyle> ]                       ;
            [ FONT <oFont> ]                         ;
            [ ON INIT <bInit> ]                      ;
            [ ON SIZE <bSize> ]                      ;
            [ ON PAINT <bDraw> ]                     ;
            [ ON CHANGE <bChange> ]                  ;
            [ ON CLICK <bClick> ]                    ;
            [ ON GETFOCUS <bGetFocus> ]              ;
            [ ON LOSTFOCUS <bLostFocus> ]            ;
            [ BITMAP <aBmp>                          ;
              [ <res: FROM RESOURCE> ]               ;
              [ BITCOUNT <nBC> ]                     ;
            ]                                        ;
            [ <class: CLASS> <classname> ]           ;
          => ;
          [ <oTab> := ] __IIF(<.class.>, <classname>, HTab)():New(<oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
          <nHeight>,<oFont>,<bInit>,<bSize>,<bDraw>,<aItems>,<bChange>, <aBmp>, <.res.>,<nBC>,;
          <bClick>, <bGetFocus>, <bLostFocus>);
          [; hwg_SetCtrlName(<oTab>,<(oTab)>)]

#xcommand BEGIN PAGE <cname> OF <oTab> ;
          => ;
          <oTab>:StartPage(<cname>)

#xcommand END PAGE OF <oTab> ;
          => ;
          <oTab>:EndPage()

#xcommand ENDPAGE OF <oTab> ;
          => ;
          <oTab>:EndPage()

#xcommand REDEFINE TAB <oTab>          ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ COLOR <nColor> ]         ;
            [ BACKCOLOR <nBackColor> ] ;
          => ;
          [ <oTab> := ] Htab():Redefine(<oWnd>,<nId>,,  ,<bInit>,<bSize>,<bDraw>, ,<nColor>,<nBackColor>, ,);
          [; hwg_SetCtrlName(<oTab>,<(oTab)>)]
