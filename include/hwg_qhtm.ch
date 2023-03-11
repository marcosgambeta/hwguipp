#ifndef __HWG_QHTM_CH__
#define __HWG_QHTM_CH__

#define QHTMN_HYPERLINK		1

#xcommand @ <nX>, <nY> QHTM [ <oQhtm> ]    ;
             [ CAPTION  <caption> ]      ;
             [ FILE <fname> ]            ;
             [ RESOURCE <resname> ]      ;
             [ OF <oWnd> ]               ;
             [ ID <nId> ]                ;
             [ SIZE <nWidth>, <nHeight> ]  ;
             [ ON INIT <bInit> ]         ;
             [ ON SIZE <bSize> ]         ;
             [ ON CLICK <bLink> ]        ;
             [ ON SUBMIT <bSubmit> ]     ;
             [ STYLE <nStyle> ]          ;
          => ;
          [<oQhtm> :=] HQhtm():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>,<nHeight>, ;
             <caption>,<bInit>,<bSize>,<bLink>,<bSubmit>,<fname>,<resname> )

#xcommand REDEFINE QHTM [ <oQhtm> ]     ;
             [ CAPTION  <caption> ]      ;
             [ FILE <fname> ]            ;
             [ RESOURCE <resname> ]      ;
             [ OF <oWnd> ]               ;
             ID <nId>                    ;
             [ ON INIT <bInit> ]         ;
             [ ON SIZE <bSize> ]         ;
             [ ON CLICK <bLink> ]        ;
             [ ON SUBMIT <bSubmit> ]     ;
          => ;
          [<oQhtm> :=] HQhtm():Redefine( <oWnd>,<nId>,<caption>, ;
             <bInit>,<bSize>,<bLink>,,<bSubmit><fname>,<resname> )

#xcommand @ <nX>, <nY> QHTMBUTTON [ <oBut> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON CLICK <bClick> ]      ;
             [ STYLE <nStyle> ]         ;
          => ;
          [<oBut> := ] HQhtmButton():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bClick>,<cTooltip> )

#xcommand REDEFINE QHTMBUTTON [ <oBut> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON CLICK <bClick> ]      ;
             [ TOOLTIP <cTooltip> ]       ;
          => ;
          [<oBut> := ] HQhtmButton():Redefine( <oWnd>,<nId>,<caption>,<oFont>,<bInit>,<bSize>, ;
             <bClick>,<cTooltip> )

#endif /* __HWG_QHTM_CH__ */
