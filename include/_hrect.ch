// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

//Contribution   Ricardo de Moura Marques
#xcommand @ <X>, <Y>, <X2>, <Y2> RECT <oRect> [ <lPress: PRESS> ] [ OF <oWnd> ] [ RECT_STYLE <nST> ];
          [ <class: CLASS> <classname> ]       ;
          => <oRect> := __IIF(<.class.>, <classname>, HRect)():New(<oWnd>,<X>,<Y>,<X2>,<Y2>, <.lPress.>, <nST> );
          [; hwg_SetCtrlName( <oRect>,<(oRect)> )]
