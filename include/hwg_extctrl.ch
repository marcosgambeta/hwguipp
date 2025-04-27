#ifndef HWG_EXTCTRL_CH
#define HWG_EXTCTRL_CH

#include "_hbrowseex.ch"

#xcommand @ <nX>, <nY> SAY [ <lExt: EXTENDED,EXT> ] [ <oSay> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <nColor> ]          ;
             [ BACKCOLOR <nBackColor> ]     ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ <lTransp: TRANSPARENT> ]   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON DBLCLICK <bDblClick> ];
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ STYLE <nStyle> ]         ;
          => ;
          [ <oSay> := ] HStaticEx():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
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

#xcommand @ <nX>, <nY>  CONTAINER [ <oCnt> ] [OF <oWnd>] ;
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
          [ <oCnt> := ] HContainerEx():New(<oWnd>, <nId>,IIF(<.lTabStop.>,WS_TABSTOP,),;
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
             [ <lTransp: TRANSPARENT> ]   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ STYLE <nStyle> ]         ;
          => ;
          [ <oGroup> := ] HGroupEx():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<nColor>,<nBackColor>,<.lTransp.>);;
          [; hwg_SetCtrlName( <oGroup>,<(oGroup)> )]

#xcommand ADD STATUSEX [ <oStat> ] [ TO <oWnd> ] ;
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
          [ <oCombo> := ] HCheckComboBox():New( <oWnd>,<nId>,<vari>,    ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},      ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,      ;
             <aItems>,<oFont>,,,,<bChange>,<cTooltip>, ;
             <.edit.>,<.text.>,<bWhen>,<nColor>,<nBackColor>, ;
                   <bValid>,<acheck>,<nDisplay>,<nhItem>,<ncWidth>, <aImages> );;
          [; hwg_SetCtrlName( <oCombo>,<(oCombo)> )]

#endif // HWG_EXTCTRL_CH
