// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> GRID <oGrid>        ;
            [ OF <oWnd> ]                  ;
            [ ID <nId> ]                   ;
            [ SIZE <nWidth>, <nHeight> ]   ;
            [ COLOR <nColor> ]             ;
            [ BACKCOLOR <bkcolor> ]        ;
            [ FONT <oFont> ]               ;
            [ ON INIT <bInit> ]            ;
            [ ON SIZE <bSize> ]            ;
            [ ON PAINT <bPaint> ]          ;
            [ ON CLICK <bEnter> ]          ;
            [ ON GETFOCUS <bGfocus> ]      ;
            [ ON LOSTFOCUS <bLfocus> ]     ;
            [ ON KEYDOWN <bKeyDown> ]      ;
            [ ON POSCHANGE <bPosChg> ]     ;
            [ ON DISPINFO <bDispInfo> ]    ;
            [ ITEMCOUNT <nItemCount> ]     ;
            [ <lNoScroll: NOSCROLL> ]      ;
            [ <lNoBord: NOBORDER> ]        ;
            [ <lNoLines: NOGRIDLINES> ]    ;
            [ <lNoHeader: NO HEADER> ]     ;
            [ BITMAP <aBit> ]              ;
            [ STYLE <nStyle> ]             ;
            [ <class: CLASS> <classname> ] ;
          => ;
          <oGrid> := __IIF(<.class.>, <classname>, HGrid)():New(<oWnd>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>,;
          <oFont>, <{bInit}>, <{bSize}>, <{bPaint}>, <{bEnter}>,;
          <{bGfocus}>, <{bLfocus}>, <.lNoScroll.>, <.lNoBord.>,;
          <{bKeyDown}>, <{bPosChg}>, <{bDispInfo}>, <nItemCount>,;
          <.lNoLines.>, <nColor>, <bkcolor>, <.lNoHeader.> ,<aBit>);
          [; hwg_SetCtrlName(<oGrid>,<(oGrid)>)]

#xcommand ADD COLUMN TO GRID <oGrid>    ;
            [ HEADER <cHeader> ]        ;
            [ WIDTH <nWidth> ]          ;
            [ JUSTIFY HEAD <nJusHead> ] ;
            [ BITMAP <n> ]              ;
          => ;
          <oGrid>:AddColumn(<cHeader>, <nWidth>, <nJusHead> ,<n>)

#xcommand ADDROW TO GRID <oGrid>         ;
            [ HEADER <cHeader> ]         ;
            [ JUSTIFY HEAD <nJusHead> ]  ;
            [ BITMAP <n> ]               ;
            [ HEADER <cHeadern> ]        ;
            [ JUSTIFY HEAD <nJusHeadn> ] ;
            [ BITMAP <nn> ]              ;
          => ;
          <oGrid>:AddRow(<cHeader>,<nJusHead>,<n>) [;<oGrid>:AddRow(<cHeadern>,<nJusHeadn>,<nn>)]

#xcommand REDEFINE GRID <oSay>   ;
            [ OF <oWnd> ]        ;
            ID <nId>             ;
            [ ON INIT <bInit> ]  ;
            [ ON SIZE <bSize> ]  ;
            [ ON PAINT <bDraw> ] ;
            [ ITEM <aitem> ]     ;
          => ;
          [ <oSay> := ] HGRIDex():Redefine(<oWnd>,<nId>,,  ,<bInit>,<bSize>,<bDraw>, , , , ,<aitem>);
          [; hwg_SetCtrlName(<oSay>,<(oSay)>)]
