//
// HWGUI - Harbour Win32 GUI library source code:
// HDC Class
//
// Copyright 2005 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HDC

   DATA m_hDC
   DATA m_hAttribDC

   METHOD NEW()
   METHOD SetAttribDC(hDC)
   METHOD ATTACH(hDc)
   METHOD Moveto(x1, y1)
   METHOD Lineto(x1, y1)
   METHOD fillsolidrect(lpRect, clr)
   METHOD Fillrect(lpRect, clr)
   METHOD Selectcliprgn(pRgn)
   METHOD Settextcolor(xColor)
   METHOD Setbkmode(xMode)
   METHOD Setbkcolor(clr) INLINE    hwg_Setbkcolor(::m_hDC, clr)
   METHOD Selectobject(xMode) // xObject
   METHOD Drawtext(strText, Rect, dwFlags)
   METHOD Createcompatibledc(x)
   METHOD Patblt(a, s, d, f, g) INLINE hwg_Patblt(::m_hDc, a, s, d, f, g)
   METHOD Savedc()
   METHOD Restoredc(nSavedDC)
   METHOD Setmapmode(nMapMode)
   METHOD SetWindowOrg(x, y)
   METHOD SetWindowExt(x, y)
   METHOD SetViewportOrg(x, y)
   METHOD SetViewportExt(x, y)
   METHOD Setarcdirection(nArcDirection)
   METHOD Gettextmetric() INLINE hwg_Gettextmetric(::m_hDC)
   METHOD Setrop2(nDrawMode)
   METHOD Bitblt(x, y, nWidth, nHeight, pSrcDC, xSrc, ySrc, dwRop) INLINE hwg_Bitblt(::m_hDc, x, y, nWidth, nHeight, pSrcDC, xSrc, ySrc, dwRop)
   METHOD Pie(arect, apt1, apt2)
   METHOD Deletedc()

ENDCLASS

METHOD HDC:NEW()

   ::m_hDC := NIL
   ::m_hAttribDC := NIL

   RETURN Self

METHOD HDC:Moveto(x1, y1)
   hwg_Moveto(::m_hDC, x1, y1)
   RETURN Self

METHOD HDC:Lineto(x1, y1)
   hwg_Lineto(::m_hDC, x1, y1)
   RETURN Self

METHOD HDC:Attach(hDC)

   IF Empty(hDC)
      RETURN .F.
   ENDIF

   ::m_hDC := hDC

   ::SetAttribDC(::m_hDC)
   return.T.

METHOD HDC:Deletedc()
   hwg_Deletedc(::m_hDC)
   ::m_hDC := NIL
   ::m_hAttribDC := NIL
   RETURN NIL

METHOD HDC:SetAttribDC(hDC)

   ::m_hAttribDC := hDC
   RETURN NIL

METHOD HDC:Selectcliprgn(pRgn)

   LOCAL nRetVal := - 1

   IF (::m_hDC != ::m_hAttribDC)
      nRetVal := hwg_Selectcliprgn(::m_hDC, pRgn)
   ENDIF

   IF !Empty(::m_hAttribDC)
      nRetVal := hwg_Selectcliprgn(::m_hAttribDC, pRgn)
   ENDIF

   RETURN nRetVal

METHOD HDC:fillsolidrect(lpRect, clr)

   hwg_Setbkcolor(::m_hDC, clr)
   hwg_Exttextout(::m_hDC, 0, 0, lpRect[1], lpRect[2], lpRect[3], lpRect[4], NIL)

   RETURN NIL

METHOD HDC:Settextcolor(xColor)

   RETURN hwg_Settextcolor(::m_hDc, xColor)

METHOD HDC:Setbkmode(xMode)

   RETURN hwg_Setbkmode(::m_hDc, xMode)

METHOD HDC:Selectobject(xMode)

   RETURN hwg_Selectobject(::m_hDc, xMode)

METHOD HDC:Drawtext(strText, Rect, dwFlags)

   hwg_Drawtext(::m_hDC, strText, Rect[1], Rect[2], Rect[3], Rect[4], dwFlags)

   RETURN NIL

METHOD HDC:Fillrect(lpRect, clr)

   hwg_Fillrect(::m_hDC, lpRect[1], lpRect[2], lpRect[3], lpRect[4], clr)

   RETURN NIL

METHOD HDC:Createcompatibledc(x)
   RETURN ::Attach(hwg_Createcompatibledc(x))

METHOD HDC:Savedc()
   
   LOCAL nRetVal := 0

   IF ( !Empty(::m_hAttribDC) )
      nRetVal := hwg_Savedc(::m_hAttribDC)
   ENDIF
   IF (::m_hDC != ::m_hAttribDC .AND. hwg_Savedc(::m_hDC) != 0)
      nRetVal := - 1   // -1 is the only valid restore value for complex DCs
   ENDIF
   RETURN nRetVal

METHOD HDC:Restoredc(nSavedDC)

   // if two distinct DCs, nSavedDC can only be -1

   LOCAL bRetVal := .T.
   
   IF (::m_hDC != ::m_hAttribDC)
      bRetVal := hwg_Restoredc(::m_hDC, nSavedDC)
   ENDIF
   IF ( !Empty(::m_hAttribDC) )
      bRetVal := (bRetVal .AND. hwg_Restoredc(::m_hAttribDC, nSavedDC))
   ENDIF
   RETURN bRetVal

METHOD HDC:Setmapmode(nMapMode)

   LOCAL nRetVal := 0

   IF (::m_hDC != ::m_hAttribDC)
      nRetVal := ::Setmapmode(::m_hDC, nMapMode)
   ENDIF
   IF !Empty(::m_hAttribDC)
      nRetVal := hwg_Setmapmode(::m_hAttribDC, nMapMode)
   ENDIF
   RETURN nRetVal

METHOD HDC:SetWindowOrg(x, y)

   LOCAL point

   IF (::m_hDC != ::m_hAttribDC)
      hwg_Setwindoworgex(::m_hDC, x, y, @point)
   ENDIF
   IF !Empty(::m_hAttribDC)
      hwg_Setwindoworgex(::m_hAttribDC, x, y, @point)
   ENDIF
   RETURN point

METHOD HDC:SetWindowExt(x, y)

   LOCAL point

   IF (::m_hDC != ::m_hAttribDC)
      hwg_Setwindowextex(::m_hDC, x, y, @point)
   ENDIF
   IF !Empty(::m_hAttribDC)
      hwg_Setwindowextex(::m_hAttribDC, x, y, @point)
   ENDIF
   RETURN point

METHOD HDC:SetViewportOrg(x, y)

   LOCAL point

   IF (::m_hDC != ::m_hAttribDC)
      hwg_Setviewportorgex(::m_hDC, x, y, @point)
   ENDIF
   IF !Empty(::m_hAttribDC)
      hwg_Setviewportorgex(::m_hAttribDC, x, y, @point)
   ENDIF
   RETURN point

METHOD HDC:SetViewportExt(x, y)

   LOCAL point

   IF (::m_hDC != ::m_hAttribDC)
      hwg_Setviewportextex(::m_hDC, x, y, @point)
   ENDIF
   IF !Empty(::m_hAttribDC)
      hwg_Setviewportextex(::m_hAttribDC, x, y, @point)
   ENDIF
   RETURN point

METHOD HDC:Setarcdirection(nArcDirection)

   LOCAL nResult := 0
   
   IF (::m_hDC != ::m_hAttribDC)
      nResult := hwg_Setarcdirection(::m_hDC, nArcDirection)
   ENDIF
   IF !Empty(::m_hAttribDC)
      nResult := hwg_Setarcdirection(::m_hAttribDC, nArcDirection)
   ENDIF
   RETURN nResult

METHOD HDC:Pie(arect, apt1, apt2)
   RETURN hwg_Pie(::m_hdc, arect[1], arect[2], arect[3], arect[4], apt1[1], apt1[2], apt2[1], apt2[2])

METHOD HDC:Setrop2(nDrawMode)

   LOCAL nRetVal := 0

   IF (::m_hDC != ::m_hAttribDC)
      nRetVal := hwg_Setrop2(::m_hDC, nDrawMode)
   ENDIF
   IF !Empty(::m_hAttribDC)
      nRetVal := hwg_Setrop2(::m_hAttribDC, nDrawMode)
   ENDIF
   RETURN nRetVal
