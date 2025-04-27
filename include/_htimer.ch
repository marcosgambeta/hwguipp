// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand SET TIMER <oTimer> [ OF <oWnd> ] [ ID <id> ] ;
             VALUE <value> ACTION <bAction> [ <lOnce: ONCE> ];
             [ <class: CLASS> <classname> ]       ;
          => ;
    <oTimer> := __IIF(<.class.>, <classname>, HTimer)():New( <oWnd>, <id>, <value>, <bAction>, <.lOnce.> );
    [; hwg_SetCtrlName( <oTimer>,<(oTimer)> )]
