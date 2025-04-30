// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

/* Add Sandro R. R. Freire */

#xcommand SPLASH [ <osplash> TO ]  <oBitmap> ;
            [ <res: FROM RESOURCE> ]         ;
            [ TIME <otime> ]               ;
            [ WIDTH <w> ];
            [ HEIGHT <h> ];
            [ <class: CLASS> <classname> ]       ;
          => ;
          [ <osplash> := ] __IIF(<.class.>, <classname>, HSplash)():Create(<oBitmap>,<otime>,<.res.>,<w>,<h>);
