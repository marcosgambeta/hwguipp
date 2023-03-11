#include "hwguipp.ch"

#define CODE39          1
#define CODE39CHECK     2
#define CODE128AUTO     3
#define CODE128A        4
#define CODE128B        5
#define CODE128C        6
#define EAN8            7
#define EAN13           8
#define UPCA            9
#define CODABAR         10
#define SUPLEMENTO5     11
#define INDUST25        12
#define INDUST25CHECK   13
#define INTER25         14
#define INTER25CHECK    15
#define MATRIX25        16
#define MATRIX25CHECK   17

FUNCTION Main()

   LOCAL oWindow
   LOCAL oBC

   oBC := Barcode():New(NIL, "993198042124", 15, 5, 200, 40, EAN13, NIL, NIL, .T., .F., 2)

   oBC:InitEAN13()

   INIT DIALOG oWindow TITLE "Test Barcode" AT 20, 20 SIZE 320, 240 ON PAINT {||oBC:showBarcode()}

   oWindow:bActivate := {||oBC:hDC := hwg_Getdc(oWindow:handle)}

   ACTIVATE DIALOG oWindow

RETURN NIL
