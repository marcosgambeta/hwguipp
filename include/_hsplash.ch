
/* Add Sandro R. R. Freire */

#xcommand SPLASH [<osplash> TO]  <oBitmap> ;
            [<res: FROM RESOURCE>]         ;
            [ TIME <otime> ]               ;
            [WIDTH <w>];
            [HEIGHT <h>];
          => ;
   [ <osplash> := ] HSplash():Create(<oBitmap>,<otime>,<.res.>,<w>,<h>);
