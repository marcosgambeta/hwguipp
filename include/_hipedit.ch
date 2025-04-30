// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> GET IPADDRESS [ <oIp> VAR ] <vari> ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ BACKCOLOR <nBackColor> ]     ;
            [ FONT <oFont> ]           ;
            [ ON GETFOCUS <bGfocus> ]      ;
            [ ON LOSTFOCUS <bLfocus> ]     ;
            [ STYLE <nStyle> ]         ;
            [ <class: CLASS> <classname> ]       ;
          => ;
          [ <oIp> := ] __IIF(<.class.>, <classname>, HIpEdit)():New( <oWnd>,<nId>,<vari>,{|v| iif(v==Nil,<vari>,<vari>:=v)},<nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>, <bGfocus>, <bLfocus> );
          [; hwg_SetCtrlName( <oIp>,<(oIp)> )]
