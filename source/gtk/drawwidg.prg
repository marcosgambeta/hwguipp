/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * Pens, brushes, fonts, bitmaps, icons handling
 *
 * Copyright 2005 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "hbclass.ch"
#include "windows.ch"
#include "guilib.ch"

Static oResCnt

#ifndef HS_HORIZONTAL
#define HS_HORIZONTAL       0       /* ----- */
#define HS_VERTICAL         1       /* ||||| */
#define HS_FDIAGONAL        2       /* \\\\\ */
#define HS_BDIAGONAL        3       /* ///// */
#define HS_CROSS            4       /* +++++ */
#define HS_DIAGCROSS        5       /* xxxxx */
#endif

   //- HBitmap

CLASS HBitmap INHERIT HObject

   CLASS VAR cPath SHARED
   CLASS VAR aBitmaps INIT {}

   DATA handle
   DATA name
   DATA nWidth
   DATA nHeight
   DATA nTransparent INIT -1
   DATA nCounter     INIT 1

   METHOD AddResource(name)
   METHOD AddFile(name, HDC, lTransparent, nWidth, nHeight)
   METHOD AddString(name, cVal)
   METHOD AddStandard(cId, nSize)
   METHOD AddWindow(oWnd, x1, y1, width, height)
   METHOD Draw(hDC, x1, y1, width, height)
   METHOD Release()
   METHOD OBMP2FILE(cfilename, name)

ENDCLASS

/*
 Stores a bitmap in a file from object
*/
METHOD OBMP2FILE(cfilename, name) CLASS HBitmap

   LOCAL i
   LOCAL hbmp

   hbmp := NIL
   // Search for bitmap in object
   FOR EACH i IN ::aBitmaps
      IF i:name == name 
         hbmp := i:handle
      ELSE
        // not found
        RETURN NIL
      ENDIF
   NEXT
   
   hwg_SaveBitMap(cfilename, hbmp )

RETURN NIL    


METHOD AddResource( name ) CLASS HBitmap
/*
 *  name : resource name in container, not file name.
 *  returns an object to bitmap, if resource successfully added
 */
   LOCAL oBmp   // cVal
   LOCAL i
   LOCAL cTmp

   For EACH oBmp IN ::aBitmaps
      IF oBmp:name == name
         oBmp:nCounter ++
         RETURN oBmp  // go back, if already exists
      ENDIF
   NEXT

   /*
    * DF7BE: AddString method loads image from file or
    * binary container and added it to resource container.
   */

   // oResCnt (Static Memvar) is object of HBinC class
   IF !Empty(oResCnt)
      IF !Empty(i := oResCnt:Get( name ))
       // DF7BE:
       // Store bmp in a temporary file
       // (otherwise the bmp is not loadable)
       // Load from temporary file
       //  ::handle := hwg_OpenImage( i, .T. )
       // Ready for multi platform use
       hb_memowrit(cTmp := hwg_CreateTempfileName(), i)
         ::handle := hwg_OpenImage( cTmp )
      ENDIF
   ENDIF
   
   /*
   IF !Empty(oResCnt) .AND. !Empty(cVal := oResCnt:Get( name ))
      IF !Empty(oBmp := ::AddString( name, cVal ))
          RETURN oBmp
      ENDIF
   ENDIF
   */
   
   IF Empty(::handle)
      hwg_MsgStop("Can not add bitmap to resource container: >" + name + "<" )
      RETURN NIL
   // ELSE
   //     hwg_MsgInfo("Bitmap resource successfully loaded >" + name + "<" )     
   ENDIF
   ::name   := name
   AAdd(::aBitmaps, Self)

   RETURN Self

   // RETURN NIL

METHOD AddFile(name, HDC, lTransparent, nWidth, nHeight) CLASS HBitmap
   
   LOCAL i
   LOCAL aBmpSize

   HB_SYMBOL_UNUSED(HDC)
   HB_SYMBOL_UNUSED(lTransparent)
   HB_SYMBOL_UNUSED(nWidth)
   HB_SYMBOL_UNUSED(nHeight)

   For EACH i IN ::aBitmaps
      IF i:name == name
         i:nCounter ++
         RETURN i
      ENDIF
   NEXT

   name := AddPath( name, ::cPath )
   ::handle := hwg_Openimage( name )
   IF !Empty(::handle)
      ::name := name
      aBmpSize  := hwg_Getbitmapsize(::handle)
      ::nWidth  := aBmpSize[1]
      ::nHeight := aBmpSize[2]
      AAdd(::aBitmaps, Self)
   ELSE
      RETURN NIL
   ENDIF

   RETURN Self

METHOD AddString( name, cVal ) CLASS HBitmap
/*
  Add name to resource container (array ::aBitmaps)
  and add image to resource container.
  name : Name of resource in container
  cVal : Contents of image
*/

   LOCAL oBmp
   LOCAL aBmpSize
   LOCAL cTmp

   For EACH oBmp IN ::aBitmaps
      IF oBmp:name == name
         oBmp:nCounter ++
         // already existing, nothing to add
         RETURN oBmp
      ENDIF
   NEXT

   /* Try to load image from file */
   ::handle := hwg_Openimage( cVal  )  // 2nd parameter not .T. !
   IF Empty(::handle)
      // Otherwise:
      // Write image from binary container into temporary file
      // (as a bitmap file)

//      hb_memowrit( cTmp := "/tmp/e" + Ltrim(Str(Int(Seconds()*100))), cVal )
//      DF7BE: Ready for multi platform use
       hb_memowrit(cTmp := hwg_CreateTempfileName(), cVal)
      ::handle := hwg_Openimage( cTmp )
      FErase(cTmp)
   ENDIF
   IF !Empty(::handle)
      // hwg_Msginfo("Bitmap successfully loaded: >" + name + "<")
      ::name := name
      aBmpSize  := hwg_Getbitmapsize(::handle)
      ::nWidth  := aBmpSize[1]
      ::nHeight := aBmpSize[2]
      AAdd(::aBitmaps, Self)
   ELSE
      hwg_MsgStop("Bitmap not loaded >" + name + "<" )
      RETURN NIL
   ENDIF

   RETURN Self

METHOD AddStandard( cId, nSize ) CLASS HBitmap
   
   LOCAL i
   LOCAL aBmpSize
   LOCAL cName

   cName := cId + Iif(nSize==NIL, "", Str(nSize,1))
   FOR EACH i IN ::aBitmaps
      IF i:name == cName
         i:nCounter ++
         RETURN i
      ENDIF
   NEXT

   ::handle := hwg_StockBitmap( cId, nSize )
   IF Empty(::handle)
      RETURN NIL
   ENDIF
   ::name    := cName
   aBmpSize  := hwg_Getbitmapsize(::handle)
   ::nWidth  := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, Self)

   RETURN Self

METHOD AddWindow( oWnd, x1, y1, width, height ) CLASS HBitmap
   
   LOCAL aBmpSize
   LOCAL handle := hwg_GetDrawing( oWnd:handle )
   // Variables not used
   // i

   IF x1 == NIL .OR. y1 == NIL
      x1 := 0; y1 := 0; width := oWnd:nWidth - 1; height := oWnd:nHeight - 1
   ENDIF
   ::handle := hwg_Window2Bitmap( Iif(Empty(handle),oWnd:handle,handle),x1,y1,width,height )
   ::name := LTrim(hb_valToStr(oWnd:handle))
   aBmpSize  := hwg_Getbitmapsize(::handle)
   ::nWidth  := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, Self)

   RETURN Self

METHOD Draw(hDC, x1, y1, width, height) CLASS HBitmap

   IF ::nTransparent < 0
      hwg_Drawbitmap(hDC, ::handle, NIL, x1, y1, width, height)
   ELSE
      hwg_Drawtransparentbitmap(hDC, ::handle, x1, y1, ::nTransparent)
   ENDIF

   RETURN NIL

METHOD Release() CLASS HBitmap
   
   LOCAL i
   LOCAL nlen := Len(::aBitmaps)

   ::nCounter --
   IF ::nCounter == 0
#ifdef __XHARBOUR__
      For EACH i IN ::aBitmaps
         IF i:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aBitmaps, hb_EnumIndex())
            ASize(::aBitmaps, nlen - 1)
            EXIT
         ENDIF
      NEXT
#else
      For i := 1 TO nlen
         IF ::aBitmaps[i]:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aBitmaps, i)
            ASize(::aBitmaps, nlen - 1)
            EXIT
         ENDIF
      NEXT
#endif
   ENDIF

   RETURN NIL

   //- HIcon

CLASS HIcon INHERIT HObject

   CLASS VAR cPath SHARED
   CLASS VAR aIcons INIT {}

   DATA handle
   DATA name
   DATA nCounter INIT 1
   DATA nWidth
   DATA nHeight

   METHOD AddResource(name, nWidth, nHeight, nFlags, lOEM)
   METHOD AddFile(name, nWidth, nHeight)
   METHOD AddString(name, cVal, nWidth, nHeight)
   METHOD RELEASE()

ENDCLASS

METHOD AddResource(name, nWidth, nHeight, nFlags, lOEM) CLASS HIcon
// For compatibility to WinAPI the parameters nFlags and lOEM are dummys
   
   LOCAL i
   LOCAL cTmp

   // Variables not used
   // lPreDefined := .F.

   HB_SYMBOL_UNUSED(nWidth)
   HB_SYMBOL_UNUSED(nHeight)
   HB_SYMBOL_UNUSED(nFlags)
   HB_SYMBOL_UNUSED(lOEM)

/*
   IF nWidth == NIL
      nWidth := 0
   ENDIF
   IF nHeight == NIL
      nHeight := 0
   ENDIF
*/
   IF HB_ISNUMERIC(name)
      name := LTrim(Str(name))
      // lPreDefined := .T.
   ENDIF

   For EACH i IN ::aIcons
      IF i:name == name
         i:nCounter ++
         // resource always existing, nothing to do
         RETURN i
      ENDIF
   NEXT
   // oResCnt (Static Memvar) is object of HBinC class
   IF !Empty(oResCnt)
      IF !Empty(i := oResCnt:Get( name ))
       // DF7BE:
       // Store icon in a temporary file
       // (otherwise the icon is not loadable)
       // Load from temporary file
       //  ::handle := hwg_OpenImage( i, .T. )
       // Ready for multi platform use
       hb_memowrit(cTmp := hwg_CreateTempfileName(), i)
         ::handle := hwg_OpenImage( cTmp )
      ENDIF
   ENDIF
   IF Empty(::handle)
      hwg_MsgStop("Can not add icon to resource container: >" + name + "<" )
      RETURN NIL
   ENDIF
   ::name   := name
   AAdd(::aIcons, Self)

   RETURN Self

METHOD AddFile(name, nWidth, nHeight) CLASS HIcon

   LOCAL i
   LOCAL aBmpSize

   IF nWidth == NIL
      nWidth := 0
   ENDIF
   IF nHeight == NIL
      nHeight := 0
   ENDIF

   For EACH i IN  ::aIcons
      IF i:name == name
         i:nCounter ++
         RETURN i
      ENDIF
   NEXT

   name := AddPath( name, ::cPath )
   IF Empty(hb_fNameExt( name ))
      name += ".png"
   ENDIF
   ::handle := hwg_Openimage( name )
   IF !Empty(::handle)
      ::name := name
      aBmpSize  := hwg_Getbitmapsize(::handle)

//      ::nWidth  := aBmpSize[1]
//      ::nHeight := aBmpSize[2]
      IF  nWidth > 0
       ::nWidth := nWidth
      ELSE
       ::nWidth  := aBmpSize[1]
      ENDIF
      IF nHeight > 0
       ::nHeight := nHeight
      ELSE
       ::nHeight := aBmpSize[2]
      ENDIF

      AAdd(::aIcons, Self)
   ELSE
      hwg_MsgStop("Can not load icon: >" + name + "<")
      RETURN NIL
   ENDIF

   RETURN Self


 /* Added by DF7BE
 name : Name of resource
 cVal : Binary contents of *.ico file
 */
METHOD AddString(name, cVal, nWidth, nHeight) CLASS HIcon

   LOCAL i
   LOCAL cTmp
   LOCAL aBmpSize

   IF nWidth == NIL
      nWidth := 0
   ENDIF
   IF nHeight == NIL
      nHeight := 0
   ENDIF

   For EACH i IN ::aIcons
      IF i:name == name
         i:nCounter ++
         // resource always existing, nothing to do
         RETURN i
      ENDIF
   NEXT
   // DF7BE:
   // Write contents into temporary file
       hb_memowrit(cTmp := hwg_CreateTempfileName(), cVal)
       ::handle := hwg_OpenImage( cTmp )
       FERASE(cTmp)
   IF !Empty(::handle)
      ::name := name
      aBmpSize  := hwg_Getbitmapsize(::handle)
      ::nWidth  := aBmpSize[1]
      ::nHeight := aBmpSize[2]
      AAdd(::aIcons, Self)
   ELSE
      hwg_MsgStop("Can not load icon: >" + name + "<")
      RETURN NIL
   ENDIF

   RETURN Self


METHOD RELEASE() CLASS HIcon
   
   LOCAL i
   LOCAL nlen := Len(::aIcons)

   ::nCounter --
   IF ::nCounter == 0
#ifdef __XHARBOUR__
      For EACH i IN ::aIcons
         IF i:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aIcons, hb_EnumIndex())
            ASize(::aIcons, nlen - 1)
            EXIT
         ENDIF
      NEXT
#else
      For i := 1 TO nlen
         IF ::aIcons[i]:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aIcons, i)
            ASize(::aIcons, nlen - 1)
            EXIT
         ENDIF
      NEXT
#endif
   ENDIF

   RETURN NIL

FUNCTION hwg_aCompare( arr1, arr2 )

   LOCAL i
   LOCAL nLen

   IF arr1 == NIL .AND. arr2 == NIL
      RETURN .T.
   ELSEIF Valtype( arr1 ) == Valtype( arr2 ) .AND. HB_ISARRAY(arr1) ;
         .AND. ( nLen := Len(arr1) ) == Len(arr2)
      FOR i := 1 TO nLen
         IF !( Valtype(arr1[i]) == Valtype(arr2[i]) ) .OR. !( arr1[i] == arr2[i] )
            RETURN .F.
         ENDIF
      NEXT
      RETURN .T.
   ENDIF

   RETURN .F.

FUNCTION hwg_BmpFromRes( cBmp )

   LOCAL handle
   LOCAL cBuff
   LOCAL cTmp

   IF !Empty(oResCnt)
      IF !Empty(cBuff := oResCnt:Get( cBmp ))
         handle := hwg_OpenImage( cBuff, .T. )
         IF Empty(handle)
            // hb_memowrit( cTmp := "/tmp/e"+Ltrim(Str(Int(Seconds()*100))), cBuff )
            // DF7BE: Ready for multi platform use (also Windows cross development environment)
            hb_memowrit(cTmp := hwg_CreateTempfileName(), cBuff)
            // Load from temporary image file
            handle := hwg_Openimage( cTmp )
            FErase(cTmp)
         ENDIF
     ENDIF
   ENDIF

   RETURN handle

/*

 Functions for Binary Container handling
 List of array elements:
 OBJ_NAME      1
 OBJ_TYPE      2
 OBJ_VAL       3
 OBJ_SIZE      4
 OBJ_ADDR      5
*/

FUNCTION hwg_SetResContainer( cName )
// Returns .T., if container is opened successfully

   IF Empty(cName)
      IF !Empty(oResCnt)
         oResCnt:Close()
         oResCnt := NIL
      ENDIF
   ELSE
      IF Empty(oResCnt := HBinC():Open(cName))
         RETURN .F.
      ENDIF
   ENDIF
   RETURN .T.

FUNCTION hwg_GetResContainerOpen()
// Returns .T., if a container is open
IF !Empty(oResCnt)
 RETURN .T.
ENDIF
RETURN .F.

FUNCTION hwg_GetResContainer()
// Returns the object of opened container,
// otherwise NIL
// (because the object variable is static)
IF !Empty(oResCnt)
 RETURN oResCnt
ENDIF
RETURN NIL

FUNCTION hwg_ExtractResContItem2file(cfilename,cname)
// Extracts an item with name cname of an opened
// container to file cfilename
// (get file extension with function
// hwg_ExtractResContItemType() before)
// Returns .T., if success, otherwise .F.
// for example if no match.

   LOCAL n

n := hwg_ResContItemPosition(cname)
IF n > 0
    hb_MemoWrit( cfilename, oResCnt:Get( oResCnt:aObjects[n,1] ) )
    RETURN .T.
ENDIF
RETURN .F.


FUNCTION hwg_ExtractResContItemType(cname)
// Extracts the type of item with name cname of an opened
// container
// Returns the type (bmp,png,ico,jpg)
// as a string.
// Empty string "", of container not open or no match

   LOCAL cItemType := ""

IF hwg_GetResContainerOpen()
 cItemType := oResCnt:GetType(cname)
ENDIF
RETURN cItemType

FUNCTION hwg_ResContItemPosition(cname)
// Extracts the position number of item with name cname of an opened
// container
// Returns the position name of item in the container,
// 0 , if no match or container not open.

   LOCAL i := 0

IF hwg_GetResContainerOpen()
 i := oResCnt:GetPos( cname )
ENDIF
RETURN i

FUNCTION hwg_Bitmap2tmpfile(objBitmap, cname, cfextn)
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
// hwg_MsgInfo(ctmpbmpf,"Temporary image file")
// IF .NOT. EMPTY(ctmpbmpf)
//  ...
// ENDIF
// ERASE &ctmpbmpf
//
// Read more about the usage of this function in the documentation
// of the Binary Container Manager in the utils/bincnt directory.

   LOCAL ctmpfilename

IF cfextn == NIL
 cfextn := "bmp"
ENDIF

 ctmpfilename := hwg_CreateTempfileName("img","." + cfextn )
 objBitmap:OBMP2FILE(ctmpfilename, cname)


IF .NOT. FILE(ctmpfilename)
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
      // hwg_Deleteobject(oItem:handle)
   NEXT
   IF !Empty(oResCnt)
      oResCnt:Close()
   ENDIF

   RETURN

/*
   DF7BE: only needed for WinAPI, on GTK/LINUX charset is UTF-8 forever.
   All other attributes are not modified.
 */
FUNCTION hwg_FontSetCharset ( oFont, nCharSet  )
   
   LOCAL i
   LOCAL nlen := Len(oFont:aFonts)

   IF nCharSet == NIL .OR. nCharSet == -1
    RETURN oFont
   ENDIF

   oFont:charset := nCharSet

 FOR i := 1 TO nlen
        oFont:aFonts[i]:CharSet := nCharSet
 NEXT

RETURN oFont


FUNCTION hwg_LoadCursorFromString(cVal, nx, ny)

   LOCAL cTmp
   LOCAL hCursor

// Parameter x and y not used on WinApi

 // Write contents into temporary file
 hb_memowrit(cTmp := hwg_CreateTempfileName(NIL, ".cur"), cVal)
 // Load cursor from temporary file
 hCursor := hwg_LoadCursorFromFile(cTmp, nx, ny)
 FERASE(cTmp)
RETURN hCursor
