/*By Vitor Maclung */
// Commands for Listbox handling

#xcommand @ <nX>, <nY> LISTBOX [ <oListbox> ITEMS ] <aItems> ;
             [ OF <oWnd> ]                 ;
             [ ID <nId> ]                  ;
             [ SIZE <nWidth>, <nHeight> ]    ;
             [ COLOR <nColor> ]          ;
             [ BACKCOLOR <nBackColor> ]     ;
             [ FONT <oFont> ]              ;
             [ TOOLTIP <cTooltip> ]          ;
             [ ON INIT <bInit> ]           ;
             [ ON SIZE <bSize> ]           ;
             [ ON PAINT <bDraw> ]          ;
             [ ON CHANGE <bChange> ]       ;
             [ ON GETFOCUS <bGfocus> ]     ;
             [ ON LOSTFOCUS <bLfocus> ]    ;
             [ ON KEYDOWN <bKeyDown> ]  ;
             [ ON DBLCLICK <bDblClick> ];
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ INIT <nInit> ]              ;
             [ STYLE <nStyle> ]            ;
          => ;
          [<oListbox> := ] HListBox():New( <oWnd>,<nId>,<nInit>,,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<aItems>,<oFont>,<bInit>,<bSize>,<bDraw>,<bChange>,<cTooltip>,;
             <nColor>,<nBackColor>, <bGfocus>,<bLfocus>,<bKeyDown>,<bDblClick>,<bOther> ) ;;
          [; hwg_SetCtrlName( <oListbox>,<(oListbox)> )]

#xcommand REDEFINE LISTBOX [ <oListbox> ITEMS ] <aItems> ;
             [ OF <oWnd> ]                 ;
             ID <nId>                      ;
             [ INIT <nInit>    ]           ;
             [ ON INIT <bInit> ]           ;
             [ ON SIZE <bSize> ]           ;
             [ ON PAINT <bDraw> ]          ;
             [ ON CHANGE <bChange> ]       ;
             [ FONT <oFont> ]              ;
             [ TOOLTIP <cTooltip> ]          ;
             [ ON GETFOCUS <bGfocus> ]     ;
             [ ON LOSTFOCUS <bLfocus> ]    ;
             [ ON KEYDOWN <bKeyDown> ]     ;
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
          => ;
          [<oListbox> := ] HListBox():Redefine( <oWnd>,<nId>,<nInit>,,<aItems>,<oFont>,<bInit>, ;
             <bSize>,<bDraw>,<bChange>,<cTooltip>,<bGfocus>,<bLfocus>, <bKeyDown>,<bOther> ) ;;
          [; hwg_SetCtrlName( <oListbox>,<(oListbox)> )]

#xcommand @ <nX>, <nY> GET LISTBOX [ <oListbox> VAR ] <vari> ITEMS <aItems> ;
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
             [ ON CHANGE <bChange> ]    ;
             [ WHEN <bGFocus> ]         ;
             [ VALID <bLFocus> ]        ;
             [ ON KEYDOWN <bKeyDown> ]  ;
             [ ON DBLCLICK <bDblClick> ];
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ STYLE <nStyle> ]         ;
          => ;
          [<oListbox> := ] HListBox():New( <oWnd>,<nId>,<vari>,;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<aItems>,<oFont>,<bInit>,<bSize>,<bDraw>, ;
             <bChange>,<cTooltip>,<nColor>,<nBackColor>,<bGFocus>,<bLFocus>,<bKeyDown>,<bDblClick>,<bOther>);;
          [; hwg_SetCtrlName( <oListbox>,<(oListbox)> )]
