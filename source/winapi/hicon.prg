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

CLASS HIcon INHERIT HObject

   CLASS VAR cPath SHARED
   CLASS VAR aIcons INIT {}
   CLASS VAR lSelFile INIT .F.

   DATA handle
   DATA name
   DATA nWidth
   DATA nHeight
   DATA nCounter INIT 1

   METHOD AddResource(name, nWidth, nHeight, nFlags, lOEM)
   METHOD AddFile(name, nWidth, nHeight)
   METHOD AddString(name, cVal, nWidth, nHeight)
   METHOD Draw(hDC, x, y)
   METHOD RELEASE()

ENDCLASS

METHOD HIcon:AddResource(name, nWidth, nHeight, nFlags, lOEM)

   LOCAL lPreDefined := .F.
   LOCAL i
   LOCAL aIconSize
   LOCAL oResCnt := hwg_GetResContainer()

   IF nWidth == NIL
      nWidth := 0
   ENDIF
   IF nHeight == NIL
      nHeight := 0
   ENDIF
   IF nFlags == NIL
      nFlags := 0
   ENDIF
   IF lOEM == NIL
      lOEM := .F.
   ENDIF
   // hwg_writelog("HIcon:AddResource " + Str(nWidth) + "/" + str(nHeight))
   IF HB_ISNUMERIC(name)
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
         //hwg_writelog(Str(Len(i)) + "/" + Iif(Empty(::handle), "Err", "Ok"))
      ENDIF
   ELSEIF lOEM // LR_SHARED is required for OEM images
      ::handle := hwg_Loadimage(0, Val(name), IMAGE_ICON, nWidth, nHeight, hb_bitor(nFlags, LR_SHARED))
   ELSE
      ::handle := hwg_Loadimage(NIL, iif(lPreDefined, Val(name), name), IMAGE_ICON, nWidth, nHeight, nFlags)
   ENDIF
   IF Empty(::handle)
      RETURN NIL
   ENDIF
   ::name   := name
   aIconSize := hwg_Geticonsize(::handle)
   ::nWidth  := aIconSize[1]
   ::nHeight := aIconSize[2]
   //hwg_writelog(Str(::nWidth) + "/" + str(::nHeight))

   AAdd(::aIcons, Self)

RETURN Self

/* Added by DF7BE
name : Name of resource
cVal : Binary contents of *.ico file
*/
METHOD HIcon:AddString(name, cVal, nWidth, nHeight)

   LOCAL cTmp //, oreturn
   LOCAL aIconSize

   IF nWidth == NIL
      nWidth := 0
   ENDIF
   IF nHeight == NIL
      nHeight := 0
   ENDIF

   // Write contents into temporary file
   hb_memowrit(cTmp := hwg_CreateTempfileName(NIL, ".ico"), cVal)
   // Load icon from temporary file
   ::handle := hwg_Loadimage(0, cTmp, IMAGE_ICON, nWidth, nHeight, LR_DEFAULTSIZE + LR_LOADFROMFILE + LR_SHARED)
   ::name := name
   aIconSize := hwg_Geticonsize(::handle)
   ::nWidth  := aIconSize[1]
   ::nHeight := aIconSize[2]

   AAdd(::aIcons, Self)

   // oreturn := ::AddFile(name)
   FERASE(cTmp)

RETURN Self // oreturn

METHOD HIcon:AddFile(name, nWidth, nHeight)

   LOCAL i
   LOCAL aIconSize
   LOCAL cname := CutPath(name)
   LOCAL cCurDir

   IF nWidth == NIL
      nWidth := 0
   ENDIF
   IF nHeight == NIL
      nHeight := 0
   ENDIF
   FOR EACH i IN ::aIcons
      IF i:name == cname .AND. (nWidth == NIL .OR. i:nWidth == nWidth) .AND. (nHeight == NIL .OR. i:nHeight == nHeight)
         i:nCounter++
         RETURN i
      ENDIF
   NEXT

   name := AddPath(name, ::cPath)
   name := iif(!File(name) .AND. File(cname), cname, name)
   IF ::lSelFile .AND. !File(name)
      cCurDir  := DiskName() + ":\" + CurDir()
      name := hwg_Selectfile("Image Files( *.jpg;*.gif;*.bmp;*.ico )", CutPath(name), FilePath(name), "Locate " + name) // "*.jpg;*.gif;*.bmp;*.ico"
      DirChange(cCurDir)
   ENDIF
   IF Empty(hb_fNameExt(name))
      name += ".ico"
   ENDIF
   ::handle := hwg_Loadimage(0, name, IMAGE_ICON, nWidth, nHeight, LR_DEFAULTSIZE + LR_LOADFROMFILE + LR_SHARED)
   ::name := cname
   aIconSize := hwg_Geticonsize(::handle)
   ::nWidth  := aIconSize[1]
   ::nHeight := aIconSize[2]

   AAdd(::aIcons, Self)

RETURN Self

METHOD HIcon:RELEASE()

   LOCAL i
   LOCAL nlen := Len(::aIcons)

   ::nCounter--
   IF ::nCounter == 0
      FOR i := 1 TO nlen // TODO: FOR EACH
         IF ::aIcons[i]:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aIcons, i)
            ASize(::aIcons, nlen - 1)
            EXIT
         ENDIF
      NEXT
   ENDIF

RETURN NIL

#pragma BEGINDUMP

#define OEMRESOURCE

#include "hwingui.hpp"
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include <hbstack.hpp>
#include <hbapicls.hpp>
#include "missing.hpp"
#include <math.h>
#include "incomp_pointer.hpp"

HB_FUNC_STATIC( HICON_DRAW )
{
   DrawIcon(hwg_par_HDC(1), hwg_par_int(2), hwg_par_int(3), static_cast<HICON>(hb_objDataGetPtr(hb_stackSelfItem(), "HANDLE")));
}

#pragma ENDDUMP
