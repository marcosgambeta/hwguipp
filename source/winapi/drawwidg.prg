//
// HWGUI - Harbour Win32 GUI library source code:
// Pens, brushes, fonts, bitmaps, icons handling
//
// Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

STATIC s_oResCnt

FUNCTION hwg_aCompare(arr1, arr2)

   LOCAL i
   LOCAL nLen

   IF arr1 == NIL .AND. arr2 == NIL
      RETURN .T.
   ELSEIF Valtype(arr1) == Valtype(arr2) .AND. hb_IsArray(arr1) .AND. (nLen := Len(arr1)) == Len(arr2)
      FOR i := 1 TO nLen
         IF !(Valtype(arr1[i]) == Valtype(arr2[i])) .OR. !(arr1[i] == arr2[i])
            RETURN .F.
         ENDIF
      NEXT
      RETURN .T.
   ENDIF

RETURN .F.

FUNCTION hwg_BmpFromRes(cBmp)

   LOCAL handle
   LOCAL cBuff

   IF !Empty(s_oResCnt)
      IF !Empty(cBuff := s_oResCnt:Get(cBmp))
         handle := hwg_OpenImage(cBuff, .T.)
      ENDIF
   ELSE
      handle := hwg_Loadbitmap(cBmp)
   ENDIF

RETURN handle

// Functions for Binary Container handling
// List of array elements:
// OBJ_NAME      1
// OBJ_TYPE      2
// OBJ_VAL       3
// OBJ_SIZE      4
// OBJ_ADDR      5

// Returns .T., if container is opened successfully
FUNCTION hwg_SetResContainer(cName)

   IF Empty(cName)
      IF !Empty(s_oResCnt)
         s_oResCnt:Close()
         s_oResCnt := NIL
      ENDIF
   ELSE
      IF Empty(s_oResCnt := HBinC():Open(cName))
         RETURN .F.
      ENDIF
   ENDIF

RETURN .T.

// Returns .T., if a container is open
FUNCTION hwg_GetResContainerOpen()

   IF !Empty(s_oResCnt)
      RETURN .T.
   ENDIF

RETURN .F.

// Returns the object of opened container,
// otherwise NIL
// (because the object variable is static)
FUNCTION hwg_GetResContainer()

   IF !Empty(s_oResCnt)
      RETURN s_oResCnt
   ENDIF

RETURN NIL

// Extracts an item with name cname of an opened
// container to file cfilename
// (get file extension with function
// hwg_ExtractResContItemType() before)
// Returns .T., if success, otherwise .F.
// for example if no match.
FUNCTION hwg_ExtractResContItem2file(cfilename,cname)

   LOCAL n

   n := hwg_ResContItemPosition(cname)

   IF n > 0
      hb_MemoWrit(cfilename, s_oResCnt:Get(s_oResCnt:aObjects[n, 1]))
      RETURN .T.
   ENDIF

RETURN .F.

// Extracts the type of item with name cname of an opened
// container
// Returns the type (bmp,png,ico,jpg)
// as a string.
// Empty string "", of container not open or no match
FUNCTION hwg_ExtractResContItemType(cname)

   LOCAL cItemType := ""

   IF hwg_GetResContainerOpen()
      cItemType := s_oResCnt:GetType(cname)
   ENDIF

RETURN cItemType

// Extracts the position number of item with name cname of an opened
// container
// Returns the position name of item in the container,
// 0, if no match or container not open.
FUNCTION hwg_ResContItemPosition(cname)

   LOCAL i := 0

   IF hwg_GetResContainerOpen()
      i := s_oResCnt:GetPos(cname)
   ENDIF

RETURN i

// Creates a temporary file from a bitmap object
// Avoids trouble with imcompatibility of image displays.
// Almost needed for binary container.
// objBitmap : object from resource container (from HBitmap class)
// cname     : resource name of object
// cfextn    : file extension, for example "bmp" (Default)
// Returns:
// The temporary file name,
// empty string, if error occured.
// Don't forget to delete the temporary file after usage.
// LOCAL ctmpbmpf
// ctmpbmpf := hwg_Bitmap2tmpfile(obitmap, "sample", "bmp")
// hwg_MsgInfo(ctmpbmpf, "Temporary image file")
// IF !Empty(ctmpbmpf)
//  ...
// ENDIF
// ERASE &ctmpbmpf
//
// Read more about the usage of this function in the documentation
// of the Binary Container Manager in the utils/bincnt directory.
FUNCTION hwg_Bitmap2tmpfile(objBitmap, cname, cfextn)

   LOCAL ctmpfilename

   IF cfextn == NIL
      cfextn := "bmp"
   ENDIF

   ctmpfilename := hwg_CreateTempfileName("img","." + cfextn )
   objBitmap:OBMP2FILE(ctmpfilename, cname)

   IF !FILE(ctmpfilename)
      RETURN ""
   ENDIF

RETURN ctmpfilename

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// End of Binary Container functions
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

EXIT PROCEDURE CleanDrawWidg

   LOCAL oItem

   FOR EACH oItem IN HPen():aPens
      hwg_Deleteobject(oItem:handle)
   NEXT
   FOR EACH oItem IN HBrush():aBrushes
      hwg_Deleteobject(oItem:handle)
   NEXT
   FOR EACH oItem IN HFont():aFonts
      hwg_Deleteobject(oItem:handle)
   NEXT
   FOR EACH oItem IN HBitmap():aBitmaps
      hwg_Deleteobject(oItem:handle)
   NEXT
   FOR EACH oItem IN HIcon():aIcons
      hwg_Deleteobject(oItem:handle)
   NEXT
   IF !Empty(s_oResCnt)
      s_oResCnt:Close()
   ENDIF

RETURN

// DF7BE: only needed for WinAPI, on GTK/LINUX charset is UTF-8 forever.
// All other attributes are not modified.
FUNCTION hwg_FontSetCharset(oFont, nCharSet)

   LOCAL oItem

   IF nCharSet == NIL .OR. nCharSet == -1
      RETURN oFont
   ENDIF

   oFont:charset := nCharSet

   FOR EACH oItem IN oFont:aFonts
      oItem:CharSet := nCharSet
   NEXT

RETURN oFont

FUNCTION hwg_LoadCursorFromString(cVal, nx, ny)

   LOCAL cTmp
   LOCAL hCursor

   // Parameter x and y not used on WinApi
   HB_SYMBOL_UNUSED(nx)
   HB_SYMBOL_UNUSED(ny)

   // Write contents into temporary file
   hb_memowrit(cTmp := hwg_CreateTempfileName(NIL, ".cur"), cVal)
   // Load cursor from temporary file
   hCursor := hwg_LoadCursorFromFile(cTmp) // for GTK add parameters nx, ny
   FERASE(cTmp)

RETURN hCursor
