// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

/*
Command for MonthCalendar Class
Added by Marcos Antonio Gambeta
*/

#xcommand @ <nX>, <nY> MONTHCALENDAR [ <oMonthCalendar> ] ;
            [ OF <oWnd> ]                              ;
            [ ID <nId> ]                               ;
            [ SIZE <nWidth>, <nHeight> ]                ;
            [ FONT <oFont> ]                           ;
            [ TOOLTIP <cTooltip> ]                     ;
            [ ON INIT <bInit> ]                        ;
            [ ON CHANGE <bChange> ]                    ;
            [ <notoday: NOTODAY> ]                  ;
            [ <notodaycircle: NOTODAYCIRCLE> ]      ;
            [ <weeknumbers: WEEKNUMBERS> ]          ;
            [ INIT <dInit> ]                           ;
            [ STYLE <nStyle> ]                         ;
            [ <class: CLASS> <classname> ]       ;
          => ;
    [ <oMonthCalendar> := ] __IIF(<.class.>, <classname>, HMonthCalendar)():New( <oWnd>,<nId>,<dInit>,<nStyle>,;
        <nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,<bChange>,<cTooltip>,;
        <.notoday.>,<.notodaycircle.>,<.weeknumbers.>);
    [; hwg_SetCtrlName( <oMonthCalendar>,<(oMonthCalendar)> )]
