#ifndef HWG_EXTCTRL_CH
#define HWG_EXTCTRL_CH

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
          => ;
          [<oBrw> :=] HBrowseEx():New( Iif(<.lDb.>,BRW_DATABASE,Iif(<.lArr.>,BRW_ARRAY,0)),;
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

#xcommand @ <nX>, <nY> SAY [ <lExt: EXTENDED,EXT> ] [ <oSay> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <nColor> ]          ;
             [ BACKCOLOR <nBackColor> ]     ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [<lTransp: TRANSPARENT>]   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON DBLCLICK <bDblClick> ];
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ STYLE <nStyle> ]         ;
          => ;
          [<oSay> := ] HStaticEx():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<cTooltip>, ;
             <nColor>,<nBackColor>,<.lTransp.>,<bClick>,<bDblClick>,<bOther> );;
          [; hwg_SetCtrlName( <oSay>,<(oSay)> )]

#include "_hbuttonex.ch"

#xcommand @ <nX>, <nY> GRIDEX <oGrid>      ;
            [ OF <oWnd> ]               ;
            [ ID <nId> ]                ;
            [ SIZE <nWidth>, <nHeight> ]  ;
            [ COLOR <nColor> ]           ;
            [ BACKCOLOR <bkcolor> ]     ;
            [ FONT <oFont> ]            ;
            [ ON INIT <bInit> ]         ;
            [ ON SIZE <bSize> ]         ;
            [ ON PAINT <bPaint> ]       ;
            [ ON CLICK <bEnter> ]       ;
            [ ON GETFOCUS <bGfocus> ]   ;
            [ ON LOSTFOCUS <bLfocus> ]  ;
            [ ON KEYDOWN <bKeyDown> ]   ;
            [ ON POSCHANGE <bPosChg> ]  ;
            [ ON DISPINFO <bDispInfo> ] ;
            [ ITEMCOUNT <nItemCount> ]  ;
            [ <lNoScroll: NOSCROLL> ]   ;
            [ <lNoBord: NOBORDER> ]     ;
            [ <lNoLines: NOGRIDLINES> ] ;
            [ <lNoHeader: NO HEADER> ]  ;
            [BITMAP <aBit>];
            [ ITEMS <a>];
            [ STYLE <nStyle> ]          ;
          => ;
    <oGrid> := HGridEx():New( <oWnd>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>,;
                            <oFont>, <{bInit}>, <{bSize}>, <{bPaint}>, <{bEnter}>,;
                            <{bGfocus}>, <{bLfocus}>, <.lNoScroll.>, <.lNoBord.>,;
                            <{bKeyDown}>, <{bPosChg}>, <{bDispInfo}>, <nItemCount>,;
                             <.lNoLines.>, <nColor>, <bkcolor>, <.lNoHeader.> ,<aBit>,<a>)

#xcommand ADDROWEX TO GRID <oGrid>    ;
            [ HEADER <cHeader> ]        ;
            [ BITMAP <n> ]              ;
            [ COLOR <nColor> ]           ;
            [ BACKCOLOR <bkcolor> ]     ;
            [ HEADER <cHeadern> ]        ;
            [ BITMAP <nn> ]              ;
            [ COLOR <colorn> ]           ;
            [ BACKCOLOR <bkcolorn> ]     ;
            => <oGrid>:AddRow(\{<cHeader>,<n>,<nColor>,<bkcolor> [, <cHeadern>, <nn>,<colorn>,<bkcolorn> ]\})

#xcommand @ <nX>, <nY>  CONTAINER [<oCnt>] [OF <oWnd>] ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ BACKSTYLE <nbackStyle>]    ;
             [ COLOR <tcolor> ]         ;
             [ BACKCOLOR <nBackColor> ]     ;
             [ <lnoBorder: NOBORDER> ]   ;
             [ ON LOAD <bLoad> ]        ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ <lTabStop: TABSTOP> ]   ;
             [ ON REFRESH <bRefresh> ]      ;
             [ ON OTHER MESSAGES <bOther> ] ;
             [ ON OTHERMESSAGES <bOther>  ] ;
             [ STYLE <ncStyle>]          ;
          =>  ;
          [<oCnt> := ] HContainerEx():New(<oWnd>, <nId>,IIF(<.lTabStop.>,WS_TABSTOP,),;
               <nX>, <nY>, <nWidth>, <nHeight>, <ncStyle>, <bSize>, <.lnoBorder.>,<bInit>,<nbackStyle>,<tcolor>,<nBackColor>,;
               <bLoad>,<bRefresh>,<bOther>);;
          [; hwg_SetCtrlName( <oCnt>,<(oCnt)> )]

#xcommand @ <nX>, <nY> GROUPBOX [ <lExt: EXTENDED,EXT> ] [ <oGroup> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <nColor> ]          ;
             [ BACKCOLOR <nBackColor> ]     ;
             [ FONT <oFont> ]           ;
             [<lTransp: TRANSPARENT>]   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ STYLE <nStyle> ]         ;
          => ;
          [<oGroup> := ] HGroupEx():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<nColor>,<nBackColor>,<.lTransp.>);;
          [; hwg_SetCtrlName( <oGroup>,<(oGroup)> )]

#xcommand ADD STATUSEX [<oStat>] [ TO <oWnd> ] ;
             [ ID <nId> ]           ;
             [ HEIGHT <nHeight> ]   ;
             [ ON INIT <bInit> ]    ;
             [ ON SIZE <bSize> ]    ;
             [ ON PAINT <bDraw> ]   ;
             [ ON DBLCLICK <bDblClick> ];
             [ ON RIGHTCLICK <bRClick> ];
             [ STYLE <nStyle> ]     ;
             [ FONT <oFont> ]       ;
             [ PARTS <aparts,...> ] ;
          => ;
          [ <oStat> := ] HStatusEx():New( <oWnd>,<nId>,<nStyle>,<oFont>,\{<aparts>\},<bInit>,;
             <bSize>,<bDraw>, <bRClick>, <bDblClick>, <nHeight> );;
          [; hwg_SetCtrlName( <oStat>,<(oStat)> )]

#xcommand @ <nX>, <nY> GET COMBOBOXEX [ <oCombo> VAR ] <vari> ITEMS  <aItems> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <nColor> ]          ;
             [ BACKCOLOR <nBackColor> ]     ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ DISPLAYCOUNT <nDisplay>] ;
             [ ITEMHEIGHT <nhItem>    ] ;
             [ COLUMNWIDTH <ncWidth>  ] ;
             [ ON CHANGE <bChange> ]    ;
             [ STYLE <nStyle> ]         ;
             [ <edit: EDIT> ]           ;
             [ <text: TEXT> ]           ;
             [ WHEN <bWhen> ]           ;
             [ VALID <bValid> ]         ;
             [ CHECK <acheck> ]         ;
             [ IMAGES <aImages> ]       ;
          => ;
          [<oCombo> := ] HCheckComboBox():New( <oWnd>,<nId>,<vari>,    ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},      ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,      ;
             <aItems>,<oFont>,,,,<bChange>,<cTooltip>, ;
             <.edit.>,<.text.>,<bWhen>,<nColor>,<nBackColor>, ;
						 <bValid>,<acheck>,<nDisplay>,<nhItem>,<ncWidth>, <aImages> );;
          [; hwg_SetCtrlName( <oCombo>,<(oCombo)> )]

#endif // HWG_EXTCTRL_CH
