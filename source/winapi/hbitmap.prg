//
// HWGUI - Harbour Win32 GUI library source code:
// Pens, brushes, fonts, bitmaps, icons handling
//
// Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "windows.ch"
#include "guilib.ch"

CLASS HBitmap INHERIT HObject

   CLASS VAR cPath SHARED
   CLASS VAR aBitmaps INIT {}
   CLASS VAR lSelFile INIT .F.

   DATA handle
   DATA name
   DATA nFlags
   DATA nTransparent INIT -1
   DATA nWidth
   DATA nHeight
   DATA nCounter INIT 1

   METHOD AddResource(name, nFlags, lOEM, nWidth, nHeight)
   METHOD AddStandard(nId)
   METHOD AddFile(name, hDC, lTransparent, nWidth, nHeight)
   METHOD AddString(name, cVal, nWidth, nHeight)
   METHOD AddWindow(oWnd, x1, y1, width, height)
   METHOD Draw(hDC, x1, y1, width, height)
   METHOD RELEASE()
   METHOD OBMP2FILE(cfilename, name)

ENDCLASS

/*
 Stores a bitmap in a file from object
*/
METHOD HBitmap:OBMP2FILE(cfilename, name)

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

METHOD HBitmap:AddResource(name, nFlags, lOEM, nWidth, nHeight)

   LOCAL lPreDefined := .F.
   LOCAL i
   LOCAL aBmpSize
   LOCAL oResCnt := hwg_GetResContainer()

   IF nFlags == NIL
      nFlags := LR_DEFAULTCOLOR
   ENDIF
   IF lOEM == NIL
      lOEM := .F.
   ENDIF
   IF HB_ISNUMERIC(name)
      name := LTrim(Str(name))
      lPreDefined := .T.
   ENDIF
   FOR EACH i IN ::aBitmaps
      IF i:name == name .AND. i:nFlags == nFlags .AND. ((nWidth == NIL .OR. nHeight == NIL) .OR. (i:nWidth == nWidth .AND. i:nHeight == nHeight))
         i:nCounter++
         RETURN i
      ENDIF
   NEXT

   IF !Empty(oResCnt)
      IF !Empty(i := oResCnt:Get(name))
         ::handle := hwg_OpenImage(i, .T.)
      ENDIF
   ELSEIF lOEM
      ::handle := hwg_Loadimage(0, Val(name), IMAGE_BITMAP, NIL, NIL, hb_bitor(nFlags, LR_SHARED))
   ELSE
      ::handle := hwg_Loadimage(NIL, iif(lPreDefined, Val(name), name), IMAGE_BITMAP, nWidth, nHeight, nFlags)
   ENDIF
   IF Empty(::handle)
      RETURN NIL
   ENDIF
   ::name := name
   aBmpSize := hwg_Getbitmapsize(::handle)
   ::nWidth := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   ::nFlags :=  nFlags
   AAdd(::aBitmaps, Self)

RETURN Self

METHOD HBitmap:AddStandard(nId)

   LOCAL i
   LOCAL aBmpSize
   LOCAL name := "s" + LTrim(Str(nId))

   FOR EACH i IN ::aBitmaps
      IF i:name == name
         i:nCounter++
         RETURN i
      ENDIF
   NEXT

   ::handle := hwg_Loadbitmap(nId, .T.)
   IF Empty(::handle)
      RETURN NIL
   ENDIF
   ::name := name
   aBmpSize := hwg_Getbitmapsize(::handle)
   ::nWidth := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, Self)

RETURN Self

METHOD HBitmap:AddFile(name, hDC, lTransparent, nWidth, nHeight)

   LOCAL i
   LOCAL aBmpSize
   LOCAL cname := CutPath(name)
   LOCAL cCurDir

   IF nWidth == NIL
      nWidth := 0
   ENDIF
   IF nHeight == NIL
      nHeight := 0
   ENDIF

   FOR EACH i IN ::aBitmaps
      IF i:name == cname .AND. ( nWidth == NIL .OR. nHeight == NIL )
         i:nCounter++
         RETURN i
      ENDIF
   NEXT

   name := AddPath(name, ::cPath)
   name := iif(!File(name) .AND. File(cname), cname, name)
   IF ::lSelFile .AND. !File(name)
      cCurDir := DiskName() + ":\" + CurDir()
      name := hwg_Selectfile("Image Files( *.jpg;*.gif;*.bmp;*.ico )", CutPath(name), FilePath(name), "Locate " + name) // "*.jpg;*.gif;*.bmp;*.ico"
      DirChange(cCurDir)
   ENDIF

   IF Lower(Right(name, 4)) != ".bmp" .OR. ( nWidth == NIL .AND. nHeight == NIL .AND. lTransparent == NIL )
      IF Lower(Right(name, 4)) == ".bmp"
         ::handle := hwg_Openbitmap(name, hDC)
      ELSE
         ::handle := hwg_Openimage(name)
      ENDIF
   ELSE
      IF lTransparent != NIL .AND. lTransparent
         ::handle := hwg_Loadimage(NIL, name, IMAGE_BITMAP, nWidth, nHeight, LR_LOADFROMFILE + LR_LOADTRANSPARENT + LR_LOADMAP3DCOLORS)
      ELSE
         ::handle := hwg_Loadimage(NIL, name, IMAGE_BITMAP, nWidth, nHeight, LR_LOADFROMFILE)
      ENDIF
   ENDIF
   IF Empty(::handle)
      RETURN NIL
   ENDIF
   ::name := cname
   aBmpSize := hwg_Getbitmapsize(::handle)
   ::nWidth := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, Self)

RETURN Self

METHOD HBitmap:AddString(name, cVal, nWidth, nHeight)

   LOCAL oBmp
   LOCAL aBmpSize

   IF nWidth == NIL
      nWidth := 0
   ENDIF
   IF nHeight == NIL
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
      aBmpSize := hwg_Getbitmapsize(::handle)
      ::nWidth := aBmpSize[1]
      ::nHeight := aBmpSize[2]
      AAdd(::aBitmaps, Self)
   ELSE
      RETURN NIL
   ENDIF

RETURN Self

METHOD HBitmap:AddWindow(oWnd, x1, y1, width, height)

   LOCAL aBmpSize

   IF x1 == NIL .OR. y1 == NIL
      x1 := 0
      y1 := 0
      width := oWnd:nWidth - 1
      height := oWnd:nHeight - 1
   ENDIF

   ::handle := hwg_Window2bitmap(oWnd:handle, x1, y1, width, height)
   ::name := LTrim(hb_valToStr(oWnd:handle))
   aBmpSize := hwg_Getbitmapsize(::handle)
   ::nWidth := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, Self)

RETURN Self

METHOD HBitmap:Draw(hDC, x1, y1, width, height)

   IF ::nTransparent < 0
      hwg_Drawbitmap(hDC, ::handle, NIL, x1, y1, width, height)
   ELSE
      hwg_Drawtransparentbitmap(hDC, ::handle, x1, y1, ::nTransparent)
   ENDIF

RETURN NIL

METHOD HBitmap:RELEASE()

   LOCAL i
   LOCAL nlen := Len(::aBitmaps)

   ::nCounter--
   IF ::nCounter == 0
      FOR i := 1 TO nlen // TODO: FOR EACH
         IF ::aBitmaps[i]:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aBitmaps, i)
            ASize(::aBitmaps, nlen - 1)
            EXIT
         ENDIF
      NEXT
   ENDIF

RETURN NIL
