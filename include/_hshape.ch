// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> SHAPE [ <oShape> ] [ OF <oWnd> ] ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ BORDERWIDTH <nBorder> ]  ;
             [ CURVATURE <nCurvature>]  ;
             [ COLOR <tcolor> ]         ;
             [ BACKCOLOR <nBackColor> ]     ;
             [ BORDERSTYLE <nbStyle>]   ;
             [ FILLSTYLE <nfStyle>]     ;
             [ BACKSTYLE <nbackStyle>]  ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ <class: CLASS> <classname> ]       ;
          => ;
          [ <oShape> := ] __IIF(<.class.>, <classname>, HShape)():New(<oWnd>, <nId>, <nX>, <nY>, <nWidth>, <nHeight>, ;
          <nBorder>, <nCurvature>, <nbStyle>,<nfStyle>, <tcolor>, <nBackColor>, <bSize>,<bInit>,<nbackStyle>);
          [; hwg_SetCtrlName( <oShape>,<(oShape)> )]
