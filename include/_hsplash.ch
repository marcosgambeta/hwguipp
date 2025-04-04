// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

/* Add Sandro R. R. Freire */

#xcommand SPLASH [<osplash> TO]  <oBitmap> ;
            [<res: FROM RESOURCE>]         ;
            [ TIME <otime> ]               ;
            [WIDTH <w>];
            [HEIGHT <h>];
          => ;
   [ <osplash> := ] HSplash():Create(<oBitmap>,<otime>,<.res.>,<w>,<h>);
