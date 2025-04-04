// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand RADIOGROUP  ;
          => HRadioGroup():New()

#xcommand GET RADIOGROUP [ <ogr> VAR ] <vari>  ;
          => [<ogr> := ] HRadioGroup():New( <vari>, {|v|Iif(v==Nil,<vari>,<vari>:=v)} )

#xcommand @ <nX>, <nY> GET RADIOGROUP [ <ogr> VAR ] <vari>  ;
             [ CAPTION <caption> ];
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <nColor> ]          ;
             [ BACKCOLOR <nBackColor> ]     ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ STYLE <nStyle> ]         ;
          => [<ogr> := ] HRadioGroup():NewRG( <oWnd>,<nId>,<nStyle>,<vari>,;
                  {|v|Iif(v==Nil,<vari>,<vari>:=v)},<nX>,<nY>,<nWidth>,<nHeight>,<caption>,<oFont>,;
                  <bInit>,<bSize>,<nColor>,<nBackColor> );;

#xcommand END RADIOGROUP [ SELECTED <nSel> ] ;
          => HRadioGroup():EndGroup( <nSel> )
