#xcommand @ <x>,<y> EDITBOX [ <oEdit> CAPTION ] <caption> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ COLOR <color> ]          ;
            [ BACKCOLOR <bcolor> ]     ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON GETFOCUS <bGfocus> ]  ;
            [ ON LOSTFOCUS <bLfocus> ] ;
            [ ON KEYDOWN <bKeyDown>]   ;
            [ ON CHANGE <bChange> ]    ;
            [ STYLE <nStyle> ]         ;
            [<lnoborder: NOBORDER>]    ;
            [<lPassword: PASSWORD>]    ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <ctoolt> ]       ;
          => ;
    [<oEdit> := ] HEdit():New( <oWnd>,<nId>,<caption>,,<nStyle>,<x>,<y>,<width>, ;
                    <height>,<oFont>,<bInit>,<bSize>,<bGfocus>, ;
                    <bLfocus>,<ctoolt>,<color>,<bcolor>,,<.lnoborder.>,,<.lPassword.>, <bKeyDown>, <bChange> );
    [; hwg_SetCtrlName( <oEdit>,<(oEdit)> )]


#xcommand REDEFINE EDITBOX [ <oEdit> ] ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ COLOR <color> ]          ;
            [ BACKCOLOR <bcolor> ]     ;
            [ FONT <oFont> ]           ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON GETFOCUS <bGfocus> ]  ;
            [ ON LOSTFOCUS <bLfocus> ] ;
            [ TOOLTIP <ctoolt> ]       ;
          => ;
    [<oEdit> := ] HEdit():Redefine( <oWnd>,<nId>,,,<oFont>,<bInit>,<bSize>, ;
                   <bGfocus>,<bLfocus>,<ctoolt>,<color>,<bcolor> );
    [; hwg_SetCtrlName( <oEdit>,<(oEdit)> )]

/* SAY ... GET system     */

#xcommand @ <x>,<y> GET [ <oEdit> VAR ]  <vari>  ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ COLOR <color> ]          ;
            [ BACKCOLOR <bcolor> ]     ;
            [ PICTURE <cPicture> ]     ;
            [ WHEN  <bGfocus> ]        ;
            [ VALID <bLfocus> ]        ;
            [ ON KEYDOWN <bKeyDown>]   ;
            [ ON CHANGE <bChange> ]    ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [<lPassword: PASSWORD>]    ;
            [ MAXLENGTH <nMaxLength> ] ;
            [ STYLE <nStyle> ]         ;
            [<lnoborder: NOBORDER>]    ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <ctoolt> ]       ;
          => ;
    [<oEdit> := ] HEdit():New( <oWnd>,<nId>,<vari>,               ;
                   {|v|Iif(v==Nil,<vari>,<vari>:=v)},             ;
                   <nStyle>,<x>,<y>,<width>,<height>,<oFont>,<bInit>,<bSize>,  ;
                   <bGfocus>,<bLfocus>,<ctoolt>,<color>,<bcolor>,<cPicture>,<.lnoborder.>,<nMaxLength>,<.lPassword.>,<bKeyDown>,<bChange> );
    [; hwg_SetCtrlName( <oEdit>,<(oEdit)> )]

#xcommand REDEFINE GET [ <oEdit> VAR ] <vari>  ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ COLOR <color> ]          ;
            [ BACKCOLOR <bcolor> ]     ;
            [ PICTURE <cPicture> ]     ;
            [ WHEN  <bGfocus> ]        ;
            [ VALID <bLfocus> ]        ;
            [ MAXLENGTH <nMaxLength> ] ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <ctoolt> ]       ;
          => ;
    [<oEdit> := ] HEdit():Redefine( <oWnd>,<nId>,<vari>, ;
                   {|v|Iif(v==Nil,<vari>,<vari>:=v)},    ;
                   <oFont>,,,<{bGfocus}>,<{bLfocus}>,<ctoolt>,<color>,<bcolor>,<cPicture>,<nMaxLength>,<(vari)> );
    [; hwg_SetCtrlName( <oEdit>,<(oEdit)> )]
