// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> TREE [ <oTree> ]    ;
            [ OF <oWnd> ]                  ;
            [ ID <nId> ]                   ;
            [ SIZE <nWidth>, <nHeight> ]   ;
            [ COLOR <nColor> ]             ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]               ;
            [ ON INIT <bInit> ]            ;
            [ ON SIZE <bSize> ]            ;
            [ ON CLICK <bClick> ]          ;
            [ <lEdit: EDITABLE> ]          ;
            [ BITMAP <aBmp>                ;
              [ <res: FROM RESOURCE> ]     ;
              [ BITCOUNT <nBC> ]           ;
            ]                              ;
            [ STYLE <nStyle> ]             ;
            [ <class: CLASS> <classname> ] ;
          => ;
          [ <oTree> := ] __IIF(<.class.>, <classname>, HTree)():New(<oWnd>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, ;
          <nHeight>, <oFont>, <bInit>, <bSize>, <nColor>, <nBackColor>, <aBmp>, <.res.>, <.lEdit.>, <bClick>, <nBC>) ;
          [; hwg_SetCtrlName(<oTree>, <(oTree)>)]

#xcommand INSERT NODE [ <oNode> CAPTION ] <cTitle> ;
            TO <oTree>                             ;
            [ AFTER <oPrev> ]                      ;
            [ BEFORE <oNext> ]                     ;
            [ BITMAP <aBmp> ]                      ;
            [ ON CLICK <bClick> ]                  ;
          => ;
          [ <oNode> := ] <oTree>:AddNode(<cTitle>, <oPrev>, <oNext>, <bClick>, <aBmp>)
