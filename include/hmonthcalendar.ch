/*
Command for MonthCalendar Class
Added by Marcos Antonio Gambeta
*/

#xcommand @ <x>,<y> MONTHCALENDAR [ <oMonthCalendar> ] ;
            [ OF <oWnd> ]                              ;
            [ ID <nId> ]                               ;
            [ SIZE <nWidth>,<nHeight> ]                ;
            [ INIT <dInit> ]                           ;
            [ ON INIT <bInit> ]                        ;
            [ ON CHANGE <bChange> ]                    ;
            [ STYLE <nStyle> ]                         ;
            [ FONT <oFont> ]                           ;
            [ TOOLTIP <cTooltip> ]                     ;
            [ < notoday : NOTODAY > ]                  ;
            [ < notodaycircle : NOTODAYCIRCLE > ]      ;
            [ < weeknumbers : WEEKNUMBERS > ]          ;
          => ;
    [<oMonthCalendar> :=] HMonthCalendar():New( <oWnd>,<nId>,<dInit>,<nStyle>,;
        <x>,<y>,<nWidth>,<nHeight>,<oFont>,<bInit>,<bChange>,<cTooltip>,;
        <.notoday.>,<.notodaycircle.>,<.weeknumbers.>);
    [; hwg_SetCtrlName( <oMonthCalendar>,<(oMonthCalendar)> )]
