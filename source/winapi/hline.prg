/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HLine class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HLine INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"

   DATA lVert
   DATA oPenLight, oPenGray

   METHOD New( oWndParent, nId, lVert, nLeft, nTop, nLength, bSize )
   METHOD Activate()
   METHOD Paint( lpdis )

ENDCLASS

METHOD New( oWndParent, nId, lVert, nLeft, nTop, nLength, bSize ) CLASS HLine

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, nLeft, nTop, , , , , bSize, {|o, lp|o:Paint(lp)})

   ::title := ""
   ::lVert := iif( lVert == NIL, .F. , lVert )
   IF ::lVert
      ::nWidth  := 10
      ::nHeight := iif( nLength == NIL, 20, nLength )
   ELSE
      ::nWidth  := iif( nLength == NIL, 20, nLength )
      ::nHeight := 10
   ENDIF

   ::oPenLight := HPen():Add(BS_SOLID, 1, hwg_Getsyscolor(COLOR_3DHILIGHT))
   ::oPenGray  := HPen():Add(BS_SOLID, 1, hwg_Getsyscolor(COLOR_3DSHADOW))

   ::Activate()

   RETURN Self

METHOD Activate() CLASS HLine

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatic(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD Paint( lpdis ) CLASS HLine
   LOCAL drawInfo := hwg_Getdrawiteminfo( lpdis )
   LOCAL hDC := drawInfo[3]
   LOCAL x1  := drawInfo[4], y1 := drawInfo[5]
   LOCAL x2  := drawInfo[6], y2 := drawInfo[7]

   hwg_Selectobject( hDC, ::oPenLight:handle )
   IF ::lVert
      // hwg_Drawedge( hDC,x1,y1,x1+2,y2,EDGE_SUNKEN,BF_RIGHT )
      hwg_Drawline( hDC, x1 + 1, y1, x1 + 1, y2 )
   ELSE
      // hwg_Drawedge( hDC,x1,y1,x2,y1+2,EDGE_SUNKEN,BF_RIGHT )
      hwg_Drawline( hDC, x1 , y1 + 1, x2, y1 + 1 )
   ENDIF

   hwg_Selectobject( hDC, ::oPenGray:handle )
   IF ::lVert
      hwg_Drawline( hDC, x1, y1, x1, y2 )
   ELSE
      hwg_Drawline( hDC, x1, y1, x2, y1 )
   ENDIF

   RETURN NIL
