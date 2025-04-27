// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY HWG_EXTCTRL.CH

#xcommand @ <nX>, <nY> BROWSEEX [ <oBrw> ] ;
             [ <lArr: ARRAY> ]          ;
             [ <lDb: DATABASE> ]        ;
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
             [ ON CLICK <bEnter> ]      ;
             [ ON RIGHTCLICK <bRClick> ];
             [ ON GETFOCUS <bGfocus> ][WHEN <bGfocus> ]   ;
             [ ON LOSTFOCUS <bLfocus> ][ VALID <bLfocus> ] ;
             [ <lNoVScr: NO VSCROLL> ]  ;
             [ <lNoBord: NOBORDER> ]    ;
             [ <lAppend: APPEND> ]      ;
             [ <lAutoedit: AUTOEDIT> ]  ;
             [ ON UPDATE <bUpdate> ]    ;
             [ ON KEYDOWN <bKeyDown> ]  ;
             [ ON POSCHANGE <bPosChg> ] ;
             [ ON CHANGEROWCOL <bChgrowcol> ] ;
             [ <lMulti: MULTISELECT> ]  ;
             [ <lDescend: DESCEND> ]    ; // By Marcelo Sturm (marcelo.sturm@gmail.com)
             [ WHILE <bWhile> ]         ; // By Luiz Henrique dos Santos (luizhsantos@gmail.com)
             [ FIRST <bFirst> ]         ; // By Luiz Henrique dos Santos (luizhsantos@gmail.com)
             [ LAST <bLast> ]           ; // By Marcelo Sturm (marcelo.sturm@gmail.com)
             [ FOR <bFor> ]             ; // By Luiz Henrique dos Santos (luizhsantos@gmail.com)
             [ ON OTHER MESSAGES <bOther> ] ;
             [ ON OTHERMESSAGES <bOther>  ] ;
             [ <class: CLASS> <classname> ] ;
             [ STYLE <nStyle> ]         ;
             [ <class: CLASS> <classname> ]       ;
          => ;
          [<oBrw> :=] __IIF(<.class.>, <classname>, HBrowseEx)():New( Iif(<.lDb.>,BRW_DATABASE,Iif(<.lArr.>,BRW_ARRAY,0)),;
             <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,<bSize>, ;
             <bDraw>,<bEnter>,<bGfocus>,<bLfocus>,<.lNoVScr.>,<.lNoBord.>, <.lAppend.>,;
             <.lAutoedit.>, <bUpdate>, <bKeyDown>, <bPosChg>, <.lMulti.>, <.lDescend.>,;
             <bWhile>, <bFirst>, <bLast>, <bFor>, <bOther>, <nColor>, <nBackColor>, <bRClick>,<bChgrowcol>, <cTooltip>  );;
          [; hwg_SetCtrlName( <oBrw>,<(oBrw)> )]


#xcommand ADD COLUMNEX <block> TO <oBrw> ;
             [ HEADER <cHeader> ]       ;
             [ TYPE <cType> ]           ;
             [ LENGTH <nLen> ]          ;
             [ DEC <nDec>    ]          ;
             [ <lEdit: EDITABLE> ]      ;
             [ JUSTIFY HEAD <nJusHead> ];
             [ JUSTIFY LINE <nJusLine> ];
             [ PICTURE <cPict> ]        ;
             [ COLOR <nColor> ]          ;
             [ BACKCOLOR <nBackColor> ]     ;
             [ VALID <bValid> ]         ;
             [ WHEN <bWhen> ]           ;
             [ ON CLICK <bClick> ]      ;
             [ ITEMS <aItem> ]          ;
             [ [ON] COLORBLOCK <bClrBlck> ]  ;
             [ [ON] BHEADCLICK <bHeadClick> ]  ;
          => ;
          <oBrw>:AddColumn( HColumnEx():New( <cHeader>,<block>,<cType>,<nLen>,<nDec>,<.lEdit.>,;
             <nJusHead>, <nJusLine>, <cPict>, <{bValid}>, <{bWhen}>, <aItem>, <{bClrBlck}>, <{bHeadClick}>, <nColor>, <nBackColor>, <bClick> ) )

#xcommand INSERT COLUMNEX <block> TO <oBrw> ;
             [ HEADER <cHeader> ]       ;
             [ TYPE <cType> ]           ;
             [ LENGTH <nLen> ]          ;
             [ DEC <nDec>    ]          ;
             [ <lEdit: EDITABLE> ]      ;
             [ JUSTIFY HEAD <nJusHead> ];
             [ JUSTIFY LINE <nJusLine> ];
             [ PICTURE <cPict> ]        ;
             [ VALID <bValid> ]         ;
             [ WHEN <bWhen> ]           ;
             [ ITEMS <aItem> ]          ;
             [ BITMAP <oBmp> ]          ;
             [ COLORBLOCK <bClrBlck> ]  ;
             INTO <nPos>                ;
          => ;
          <oBrw>:InsColumn( HColumnEx():New( <cHeader>,<block>,<cType>,<nLen>,<nDec>,<.lEdit.>,;
             <nJusHead>, <nJusLine>, <cPict>, <{bValid}>, <{bWhen}>, <aItem>, <oBmp>, <{bClrBlck}> ),<nPos> )
