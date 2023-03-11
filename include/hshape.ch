#xcommand @ <nX>, <nY> SHAPE [<oShape>] [OF <oWnd>] ;
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
          => ;
          [ <oShape> := ] HShape():New(<oWnd>, <nId>, <nX>, <nY>, <nWidth>, <nHeight>, ;
             <nBorder>, <nCurvature>, <nbStyle>,<nfStyle>, <tcolor>, <nBackColor>, <bSize>,<bInit>,<nbackStyle>);
          [; hwg_SetCtrlName( <oShape>,<(oShape)> )]
