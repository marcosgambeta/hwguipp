// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> EDITBOX [ <oEdit> CAPTION ] <caption> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]      ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON GETFOCUS <bGfocus> ]  ;
            [ ON LOSTFOCUS <bLfocus> ] ;
            [ ON KEYDOWN <bKeyDown>]   ;
            [ ON CHANGE <bChange> ]    ;
            [<lnoborder: NOBORDER>]    ;
            [<lPassword: PASSWORD>]    ;
            [ STYLE <nStyle> ]         ;
            [ <class: CLASS> <classname> ]       ;
          => ;
    [<oEdit> := ] __IIF(<.class.>, <classname>, HEdit)():New( <oWnd>,<nId>,<caption>,,<nStyle>,<nX>,<nY>,<nWidth>, ;
                    <nHeight>,<oFont>,<bInit>,<bSize>,<bGfocus>, ;
                    <bLfocus>,<cTooltip>,<nColor>,<nBackColor>,,<.lnoborder.>,,<.lPassword.>, <bKeyDown>, <bChange> );
    [; hwg_SetCtrlName( <oEdit>,<(oEdit)> )]


#xcommand REDEFINE EDITBOX [ <oEdit> ] ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON GETFOCUS <bGfocus> ]  ;
            [ ON LOSTFOCUS <bLfocus> ] ;
          => ;
    [<oEdit> := ] HEdit():Redefine( <oWnd>,<nId>,,,<oFont>,<bInit>,<bSize>, ;
                   <bGfocus>,<bLfocus>,<cTooltip>,<nColor>,<nBackColor> );
    [; hwg_SetCtrlName( <oEdit>,<(oEdit)> )]

/* SAY ... GET system     */

#xcommand @ <nX>, <nY> GET [ <oEdit> VAR ]  <vari>  ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ PICTURE <cPicture> ]     ;
            [ WHEN  <bGfocus> ]        ;
            [ VALID <bLfocus> ]        ;
            [ ON KEYDOWN <bKeyDown>]   ;
            [ ON CHANGE <bChange> ]    ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [<lPassword: PASSWORD>]    ;
            [ MAXLENGTH <nMaxLength> ] ;
            [<lnoborder: NOBORDER>]    ;
            [ STYLE <nStyle> ]         ;
            [ <class: CLASS> <classname> ]       ;
          => ;
    [<oEdit> := ] __IIF(<.class.>, <classname>, HEdit)():New( <oWnd>,<nId>,<vari>,               ;
                   {|v|Iif(v==Nil,<vari>,<vari>:=v)},             ;
                   <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,<bSize>,  ;
                   <bGfocus>,<bLfocus>,<cTooltip>,<nColor>,<nBackColor>,<cPicture>,<.lnoborder.>,<nMaxLength>,<.lPassword.>,<bKeyDown>,<bChange> );
    [; hwg_SetCtrlName( <oEdit>,<(oEdit)> )]

#xcommand REDEFINE GET [ <oEdit> VAR ] <vari>  ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ COLOR <nColor> ]          ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <cTooltip> ]       ;
            [ PICTURE <cPicture> ]     ;
            [ WHEN  <bGfocus> ]        ;
            [ VALID <bLfocus> ]        ;
            [ MAXLENGTH <nMaxLength> ] ;
          => ;
    [<oEdit> := ] HEdit():Redefine( <oWnd>,<nId>,<vari>, ;
                   {|v|Iif(v==Nil,<vari>,<vari>:=v)},    ;
                   <oFont>,,,<{bGfocus}>,<{bLfocus}>,<cTooltip>,<nColor>,<nBackColor>,<cPicture>,<nMaxLength>,<(vari)> );
    [; hwg_SetCtrlName( <oEdit>,<(oEdit)> )]
