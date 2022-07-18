/*
 * HWGUI - Harbour Win32 GUI library source code:
 * Pens, brushes, fonts, bitmaps, icons handling
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "hbclass.ch"
#include "windows.ch"
#include "guilib.ch"

Static oResCnt

// TODO: mover classes para arquivos individuais

   //- HBitmap

CLASS HBitmap INHERIT HObject

   CLASS VAR cPath SHARED
   CLASS VAR aBitmaps   INIT { }
   CLASS VAR lSelFile   INIT .F.
   DATA handle
   DATA name
   DATA nFlags
   DATA nTransparent    INIT -1
   DATA nWidth, nHeight
   DATA nCounter   INIT 1

   METHOD AddResource(name, nFlags, lOEM, nWidth, nHeight)
   METHOD AddStandard(nId)
   METHOD AddFile(name, hDC, lTransparent, nWidth, nHeight)
   METHOD AddString( name, cVal , nWidth, nHeight)
   METHOD AddWindow(oWnd, x1, y1, width, height)
   METHOD Draw(hDC, x1, y1, width, height)
   METHOD RELEASE()
   METHOD OBMP2FILE(cfilename, name)
 
ENDCLASS

/*
 Stores a bitmap in a file from object
*/
METHOD OBMP2FILE(cfilename, name) CLASS HBitmap

LOCAL i , hbmp

   hbmp := NIL
   * Search for bitmap in object
   FOR EACH i IN ::aBitmaps
      IF i:name == name
         hbmp := i:handle
      ELSE
        * not found
        RETURN NIL
      ENDIF
   NEXT

   hwg_SaveBitMap(cfilename, hbmp )

RETURN NIL

METHOD AddResource(name, nFlags, lOEM, nWidth, nHeight) CLASS HBitmap
   LOCAL lPreDefined := .F. , i, aBmpSize

   IF nFlags == nil
      nFlags := LR_DEFAULTCOLOR
   ENDIF
   IF lOEM == nil
      lOEM := .F.
   ENDIF
   IF ValType(name) == "N"
      name := LTrim(Str(name))
      lPreDefined := .T.
   ENDIF
   FOR EACH i IN ::aBitmaps
      IF i:name == name .AND. i:nFlags == nFlags .AND. ((nWidth == nil .OR. nHeight == nil) .OR. (i:nWidth == nWidth .AND. i:nHeight == nHeight))
         i:nCounter++
         RETURN i
      ENDIF
   NEXT

   IF !Empty(oResCnt)
      IF !Empty(i := oResCnt:Get(name))
         ::handle := hwg_OpenImage(i, .T.)
      ENDIF
   ELSEIF lOEM
      ::handle := hwg_Loadimage(0, Val(name), IMAGE_BITMAP, nil, nil, Hwg_bitor(nFlags, LR_SHARED))
   ELSE
      ::handle := hwg_Loadimage(nil, iif(lPreDefined, Val(name), name), IMAGE_BITMAP, nWidth, nHeight, nFlags)
   ENDIF
   IF Empty(::handle)
      RETURN Nil
   ENDIF
   ::name    := name
   aBmpSize  := hwg_Getbitmapsize(::handle)
   ::nWidth  := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   ::nFlags  :=  nFlags
   AAdd(::aBitmaps, Self)

   RETURN Self

METHOD AddStandard(nId) CLASS HBitmap
   LOCAL i, aBmpSize, name := "s" + LTrim(Str(nId))

   FOR EACH i  IN  ::aBitmaps
      IF i:name == name
         i:nCounter++
         RETURN i
      ENDIF
   NEXT

   ::handle := hwg_Loadbitmap( nId, .T. )
   IF Empty(::handle)
      RETURN Nil
   ENDIF
   ::name   := name
   aBmpSize  := hwg_Getbitmapsize(::handle)
   ::nWidth  := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, Self)

   RETURN Self

METHOD AddFile(name, hDC, lTransparent, nWidth, nHeight) CLASS HBitmap
   LOCAL i, aBmpSize, cname := CutPath( name ), cCurDir

   IF nWidth == nil
      nWidth := 0
   ENDIF
   IF nHeight == nil
      nHeight := 0
   ENDIF

   FOR EACH i IN ::aBitmaps
      IF i:name == cname .AND. ( nWidth == Nil .OR. nHeight == Nil )
         i:nCounter++
         RETURN i
      ENDIF
   NEXT

   name := AddPath( name, ::cPath )
   name := iif( !File(name) .AND. File(cname), cname, name )
   IF ::lSelFile .AND. !File(name)
      cCurDir  := DiskName() + ":\" + CurDir()
      name := hwg_Selectfile("Image Files( *.jpg;*.gif;*.bmp;*.ico )", CutPath(name), FilePath(name), "Locate " + name) // "*.jpg;*.gif;*.bmp;*.ico"
      DirChange(cCurDir)
   ENDIF

   IF Lower(Right(name, 4)) != ".bmp" .OR. ( nWidth == nil .AND. nHeight == nil .AND. lTransparent == Nil )
      IF Lower(Right(name, 4)) == ".bmp"
         ::handle := hwg_Openbitmap( name, hDC )
      ELSE
         ::handle := hwg_Openimage(name)
      ENDIF
   ELSE
      IF lTransparent != Nil .AND. lTransparent
         ::handle := hwg_Loadimage(nil, name, IMAGE_BITMAP, nWidth, nHeight, LR_LOADFROMFILE + LR_LOADTRANSPARENT + LR_LOADMAP3DCOLORS)
      ELSE
         ::handle := hwg_Loadimage(nil, name, IMAGE_BITMAP, nWidth, nHeight, LR_LOADFROMFILE)
      ENDIF
   ENDIF
   IF Empty(::handle)
      RETURN Nil
   ENDIF
   ::name := cname
   aBmpSize  := hwg_Getbitmapsize(::handle)
   ::nWidth  := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, Self)

   RETURN Self

METHOD AddString( name, cVal , nWidth, nHeight ) CLASS HBitmap
   LOCAL oBmp, aBmpSize

   IF nWidth == nil
      nWidth := 0
   ENDIF
   IF nHeight == nil
      nHeight := 0
   ENDIF

   For EACH oBmp IN ::aBitmaps
      IF oBmp:name == name
         oBmp:nCounter++
         RETURN oBmp
      ENDIF
   NEXT

   ::handle := hwg_Openimage(cVal, .T.)
   IF !Empty(::handle)
      ::name := name
      aBmpSize  := hwg_Getbitmapsize(::handle)
      ::nWidth  := aBmpSize[1]
      ::nHeight := aBmpSize[2]
      AAdd(::aBitmaps, Self)
   ELSE
      RETURN Nil
   ENDIF

   RETURN Self

METHOD AddWindow(oWnd, x1, y1, width, height) CLASS HBitmap
   LOCAL aBmpSize

   IF x1 == Nil .OR. y1 == Nil
      x1 := 0
      y1 := 0
      width := oWnd:nWidth - 1
      height := oWnd:nHeight - 1
   ENDIF

   ::handle := hwg_Window2bitmap( oWnd:handle, x1, y1, width, height )
   ::name := LTrim(hb_valToStr(oWnd:handle))
   aBmpSize  := hwg_Getbitmapsize(::handle)
   ::nWidth  := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, Self)

   RETURN Self

METHOD Draw(hDC, x1, y1, width, height) CLASS HBitmap

   IF ::nTransparent < 0
      hwg_Drawbitmap(hDC, ::handle, , x1, y1, width, height)
   ELSE
      hwg_Drawtransparentbitmap(hDC, ::handle, x1, y1, ::nTransparent)
   ENDIF

   RETURN Nil

METHOD RELEASE() CLASS HBitmap
   LOCAL i, nlen := Len(::aBitmaps)

   ::nCounter--
   IF ::nCounter == 0
#ifdef __XHARBOUR__
      FOR EACH i IN ::aBitmaps
         IF i:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aBitmaps, hB_enumIndex())
            ASize(::aBitmaps, nlen - 1)
            EXIT
         ENDIF
      NEXT
#else
      FOR i := 1 TO nlen
         IF ::aBitmaps[i]:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aBitmaps, i)
            ASize(::aBitmaps, nlen - 1)
            EXIT
         ENDIF
      NEXT
#endif
   ENDIF

   RETURN Nil

   //- HIcon

CLASS HIcon INHERIT HObject

   CLASS VAR cPath SHARED
   CLASS VAR aIcons     INIT { }
   CLASS VAR lSelFile   INIT .F.
   DATA handle
   DATA name
   DATA nWidth, nHeight
   DATA nCounter   INIT 1

   METHOD AddResource(name, nWidth, nHeight, nFlags, lOEM)
   METHOD AddFile(name, nWidth, nHeight)
   METHOD AddString( name, cVal , nWidth, nHeight )
   METHOD Draw(hDC, x, y)   INLINE hwg_Drawicon(hDC, ::handle, x, y)
   METHOD RELEASE()

ENDCLASS

METHOD AddResource(name, nWidth, nHeight, nFlags, lOEM) CLASS HIcon
   LOCAL lPreDefined := .F. , i, aIconSize

   IF nWidth == nil
      nWidth := 0
   ENDIF
   IF nHeight == nil
      nHeight := 0
   ENDIF
   IF nFlags == nil
      nFlags := 0
   ENDIF
   IF lOEM == nil
      lOEM := .F.
   ENDIF
   // hwg_writelog( "HIcon:AddResource " + Str(nWidth)+"/"+str(nHeight) )
   IF ValType(name) == "N"
      name := LTrim(Str(name))
      lPreDefined := .T.
   ENDIF
   FOR EACH i IN ::aIcons
      IF i:name == name
         i:nCounter++
         RETURN i
      ENDIF
   NEXT
   IF !Empty(oResCnt)
      IF !Empty(i := oResCnt:Get(name))
         ::handle := hwg_OpenImage(i, .T., IMAGE_CURSOR)
         //hwg_writelog( Str(Len(i))+"/"+Iif(Empty(::handle),"Err","Ok") )
      ENDIF
   ELSEIF lOEM // LR_SHARED is required for OEM images
      ::handle := hwg_Loadimage(0, Val(name), IMAGE_ICON, nWidth, nHeight, Hwg_bitor(nFlags, LR_SHARED))
   ELSE
      ::handle := hwg_Loadimage(nil, iif(lPreDefined, Val(name), name), IMAGE_ICON, nWidth, nHeight, nFlags)
   ENDIF
   IF Empty(::handle)
      RETURN Nil
   ENDIF
   ::name   := name
   aIconSize := hwg_Geticonsize(::handle)
   ::nWidth  := aIconSize[1]
   ::nHeight := aIconSize[2]
   //hwg_writelog( Str(::nWidth)+"/"+str(::nHeight) )

   AAdd(::aIcons, Self)

   RETURN Self



 /* Added by DF7BE
 name : Name of resource
 cVal : Binary contents of *.ico file
 */
METHOD AddString( name, cVal , nWidth, nHeight) CLASS HIcon
 LOCAL cTmp    // , oreturn
 LOCAL aIconSize

   IF nWidth == nil
      nWidth := 0
   ENDIF
   IF nHeight == nil
      nHeight := 0
   ENDIF

 * Write contents into temporary file
 hb_memowrit(cTmp := hwg_CreateTempfileName(, ".ico"), cVal)
 * Load icon from temporary file
 ::handle := hwg_Loadimage(0, cTmp, IMAGE_ICON, nWidth, nHeight, LR_DEFAULTSIZE + LR_LOADFROMFILE + LR_SHARED)
 ::name := name
  aIconSize := hwg_Geticonsize(::handle)
 ::nWidth  := aIconSize[1]
 ::nHeight := aIconSize[2]

   AAdd(::aIcons, Self)

  * oreturn := ::AddFile(name)
 FERASE(cTmp)

RETURN  Self   // oreturn


METHOD AddFile(name, nWidth, nHeight) CLASS HIcon
   LOCAL i, aIconSize, cname := CutPath( name ), cCurDir

   IF nWidth == nil
      nWidth := 0
   ENDIF
   IF nHeight == nil
      nHeight := 0
   ENDIF
   FOR EACH i IN  ::aIcons
      IF i:name == cname .AND. (nWidth == Nil .OR. i:nWidth == nWidth) .AND. (nHeight == Nil .OR. i:nHeight == nHeight)
         i:nCounter++
         RETURN i
      ENDIF
   NEXT

   name := AddPath( name, ::cPath )
   name := iif( !File(name) .AND. File(cname), cname, name )
   IF ::lSelFile .AND. !File(name)
      cCurDir  := DiskName() + ":\" + CurDir()
      name := hwg_Selectfile("Image Files( *.jpg;*.gif;*.bmp;*.ico )", CutPath(name), FilePath(name), "Locate " + name) // "*.jpg;*.gif;*.bmp;*.ico"
      DirChange(cCurDir)
   ENDIF
   #ifdef __XHARBOUR__
   hb_FNameSplit( name,, , @cFext )
   IF Empty(cFext)
   #else
   IF Empty(hb_fNameExt(name))
   #endif
      name += ".ico"
   ENDIF
   ::handle := hwg_Loadimage(0, name, IMAGE_ICON, nWidth, nHeight, LR_DEFAULTSIZE + LR_LOADFROMFILE + LR_SHARED)
   ::name := cname
   aIconSize := hwg_Geticonsize(::handle)
   ::nWidth  := aIconSize[1]
   ::nHeight := aIconSize[2]

   AAdd(::aIcons, Self)

   RETURN Self

METHOD RELEASE() CLASS HIcon
   LOCAL i, nlen := Len(::aIcons)

   ::nCounter--
   IF ::nCounter == 0
#ifdef __XHARBOUR__
      FOR EACH i IN ::aIcons
         IF i:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aIcons, hb_enumindex())
            ASize(::aIcons, nlen - 1)
            EXIT
         ENDIF
      NEXT
#else
      FOR i := 1 TO nlen
         IF ::aIcons[i]:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aIcons, i)
            ASize(::aIcons, nlen - 1)
            EXIT
         ENDIF
      NEXT
#endif
   ENDIF

   RETURN Nil

FUNCTION hwg_aCompare(arr1, arr2)

   LOCAL i, nLen

   IF arr1 == Nil .AND. arr2 == Nil
      RETURN .T.
   ELSEIF Valtype(arr1) == Valtype(arr2) .AND. Valtype(arr1) == "A" .AND. (nLen := Len(arr1)) == Len(arr2)
      FOR i := 1 TO nLen
         IF !( Valtype(arr1[i]) == Valtype(arr2[i]) ) .OR. !( arr1[i] == arr2[i] )
            RETURN .F.
         ENDIF
      NEXT
      RETURN .T.
   ENDIF

   RETURN .F.

FUNCTION hwg_BmpFromRes( cBmp )

   LOCAL handle, cBuff

   IF !Empty(oResCnt)
      IF !Empty(cBuff := oResCnt:Get(cBmp))
         handle := hwg_OpenImage(cBuff, .T.)
      ENDIF
   ELSE
      handle := hwg_Loadbitmap( cBmp )
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
* Returns .T., if container is opened successfully

   IF Empty(cName)
      IF !Empty(oResCnt)
         oResCnt:Close()
         oResCnt := Nil
      ENDIF
   ELSE
      IF Empty(oResCnt := HBinC():Open(cName))
         RETURN .F.
      ENDIF
   ENDIF
   RETURN .T.

FUNCTION hwg_GetResContainerOpen()
* Returns .T., if a container is open
IF !Empty(oResCnt)
 RETURN .T.
ENDIF
RETURN .F.

FUNCTION hwg_GetResContainer()
* Returns the object of opened container,
* otherwise NIL
* (because the object variable is static)
IF !Empty(oResCnt)
 RETURN oResCnt
ENDIF
RETURN NIL

FUNCTION hwg_ExtractResContItem2file(cfilename,cname)
* Extracts an item with name cname of an opened
* container to file cfilename
* (get file extension with function
* hwg_ExtractResContItemType() before)
* Returns .T., if success, otherwise .F.
* for example if no match.
LOCAL n
n := hwg_ResContItemPosition(cname)
IF n > 0
    hb_MemoWrit( cfilename, oResCnt:Get( oResCnt:aObjects[n, 1] ) )
    RETURN .T.
ENDIF
RETURN .F.


FUNCTION hwg_ExtractResContItemType(cname)
* Extracts the type of item with name cname of an opened
* container 
* Returns the type (bmp,png,ico,jpg)
* as a string.
* Empty string "", of container not open or no match
LOCAL  cItemType := ""
IF hwg_GetResContainerOpen()
 cItemType := oResCnt:GetType(cname)
ENDIF
RETURN cItemType

FUNCTION hwg_ResContItemPosition(cname)
* Extracts the position number of item with name cname of an opened
* container
* Returns the position name of item in the container,
* 0 , if no match or container not open.
LOCAL i := 0
IF hwg_GetResContainerOpen()
   i := oResCnt:GetPos(cname)
ENDIF
RETURN i

FUNCTION hwg_Bitmap2tmpfile(objBitmap , cname , cfextn)
* Creates a temporary file from a bitmap object
* Avoids trouble with imcompatibility of image displays.
* Almost needed for binary container.
* objBitmap : object from resource container (from HBitmap class)
* cname     : resource name of object
* cfextn    : file extension, for example "bmp" (Default)
* Returns:
* The temporary file name,
* empty string, if error occured.
* Don't forget to delete the temporary file after usage.
* LOCAL ctmpbmpf
* ctmpbmpf := hwg_Bitmap2tmpfile(obitmap , "sample" , "bmp")
* hwg_MsgInfo(ctmpbmpf,"Temporary image file")
* IF .NOT. EMPTY(ctmpbmpf)
*  ...
* ENDIF
* ERASE &ctmpbmpf
*
* Read more about the usage of this function in the documentation
* of the Binary Container Manager in the utils/bincnt directory.
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

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* End of Binary Container functions
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   

EXIT PROCEDURE CleanDrawWidg
   LOCAL i

   FOR i := 1 TO Len(HPen():aPens)
      hwg_Deleteobject(HPen():aPens[i]:handle)
   NEXT
   FOR i := 1 TO Len(HBrush():aBrushes)
      hwg_Deleteobject(HBrush():aBrushes[i]:handle)
   NEXT
   FOR i := 1 TO Len(HFont():aFonts)
      hwg_Deleteobject(HFont():aFonts[i]:handle)
   NEXT
   FOR i := 1 TO Len(HBitmap():aBitmaps)
      hwg_Deleteobject(HBitmap():aBitmaps[i]:handle)
   NEXT
   FOR i := 1 TO Len(HIcon():aIcons)
      hwg_Deleteobject(HIcon():aIcons[i]:handle)
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
   LOCAL i, nlen := Len(oFont:aFonts)

   IF nCharSet == NIL .OR. nCharSet == -1
    RETURN oFont
   ENDIF

   oFont:charset := nCharSet

 FOR i := 1 TO nlen
        oFont:aFonts[i]:CharSet := nCharSet
 NEXT

RETURN oFont

FUNCTION hwg_LoadCursorFromString(cVal, nx , ny)
LOCAL cTmp , hCursor
* Parameter x and y not used on WinApi
 HB_SYMBOL_UNUSED(nx)
 HB_SYMBOL_UNUSED(ny)

 * Write contents into temporary file
 hb_memowrit( cTmp := hwg_CreateTempfileName(, ".cur"), cVal)
 * Load cursor from temporary file
 hCursor := hwg_LoadCursorFromFile(cTmp) // for GTK add parameters nx, ny
 FERASE(cTmp)
RETURN hCursor
