// NOTE: DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

/* Hprinter */

#xcommand INIT PRINTER <oPrinter> [ NAME <cPrinter> ] [ <lPixel: PIXEL> ] ;
          => ;
          <oPrinter> := HPrinter():New( <cPrinter>,!<.lPixel.> )

#xcommand INIT DEFAULT PRINTER <oPrinter> [ <lPixel: PIXEL> ] ;
          => ;
          <oPrinter> := HPrinter():New( "",!<.lPixel.> )
