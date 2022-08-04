
#xcommand SET TIMER <oTimer> [ OF <oWnd> ] [ ID <id> ] ;
             VALUE <value> ACTION <bAction> [<lOnce: ONCE>];
          => ;
    <oTimer> := HTimer():New( <oWnd>, <id>, <value>, <bAction>, <.lOnce.> );
    [; hwg_SetCtrlName( <oTimer>,<(oTimer)> )]
