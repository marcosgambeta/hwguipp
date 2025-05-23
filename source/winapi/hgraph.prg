//
// HWGUI - Harbour Win32 GUI library source code:
// HGraph class
//
// Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HGraph INHERIT HControl

   CLASS VAR winclass INIT "STATIC"
   
   DATA aValues                      // Data array
   DATA aSignX, aSignY               // Signs arrays for X and Y axes
   DATA nGraphs INIT 1            // Number of lines in a line chart
   DATA nType                        // Graph type: 1 - line chart, 2 - bar histogram
   DATA nLineType INIT 1            // Connecting lines for ::nType == 1 (line chart):
                                     //   0 - no lines, 1 - between poits, 2 - vertical
   DATA nPointSize INIT 2            // A point width/height for ::nLineType == 1
   DATA lGridX INIT .F.          // Should I draw grid lines for X axis
   DATA lGridY INIT .F.          // Should I draw grid lines for Y axis
   DATA lGridXMid INIT .T.          // Should I shift X axis grid line to a middle of a bar
   DATA lPositive INIT .F.
   DATA x1Def INIT 10           // A left indent
   DATA x2Def INIT 10           // A right indent
   DATA y1Def INIT 10           // A top indent
   DATA y2Def INIT 10           // A bottom indent
   DATA colorCoor INIT 0xffffff      // A color for signs
   DATA colorGrid INIT 0xaaaaaa      // A color for axes and grid lines
   DATA aColors                      // Colors for each line
   DATA ymaxSet, yMinSet
   DATA tbrush
   DATA aPens
   DATA oPen, oPenGrid
   DATA xmax, ymax, xmin, ymin PROTECTED

   METHOD New(oWndParent, nId, aValues, nX, nY, nWidth, nHeight, oFont, bSize, ctooltip, tcolor, bcolor)
   METHOD Activate()
   METHOD Init()
   METHOD CalcMinMax()
   METHOD Paint(lpdis)
   METHOD Rebuild(aValues, nType, nLineType, nPointSize)

ENDCLASS

METHOD HGraph:New(oWndParent, nId, aValues, nX, nY, nWidth, nHeight, oFont, bSize, ctooltip, tcolor, bcolor)

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, nX, nY, nWidth, nHeight, oFont, NIL, ;
              bSize, {|o, lpdis|o:Paint(lpdis)}, ctooltip, ;
              IIf(tcolor == NIL, 0xFFFFFF, tcolor), IIf(bcolor == NIL, 0, bcolor))

   ::aValues := aValues
   ::nType := 1
   ::nGraphs := 1

   ::Activate()

   RETURN Self

METHOD HGraph:Activate()
   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatic(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF
   RETURN NIL

METHOD HGraph:Init()
   IF !::lInit
      ::Super:Init()
   ENDIF
   RETURN NIL

METHOD HGraph:CalcMinMax()
   
   LOCAL i
   LOCAL j
   LOCAL nLen
   LOCAL l1

   IF ::nType == 0 .OR. ::nType > 3 .OR. Empty(::aValues)
      RETURN NIL
   ENDIF
   ::xmax := ::xmin := ::ymax := ::ymin := 0
   IF !Empty(::ymaxSet)
      ::ymax := ::ymaxSet
   ENDIF
   IF !Empty(::yminSet)
      ::ymin := ::yminSet
   ENDIF
   FOR i := 1 TO ::nGraphs
      nLen := Len(::aValues[i])
      l1 := (hb_IsNumeric(::aValues[i, 1]))
      IF ::nType == 1
         FOR j := 1 TO nLen
            IF l1
               ::ymax := Max(::ymax, ::aValues[i, j])
               ::ymin := Min(::ymin, ::aValues[i, j])
            ELSE
               ::xmax := Max(::xmax, ::aValues[i, j, 1])
               ::xmin := Min(::xmin, ::aValues[i, j, 1])
               ::ymax := Max(::ymax, ::aValues[i, j, 2])
               ::ymin := Min(::ymin, ::aValues[i, j, 2])
            ENDIF
         NEXT
      ELSEIF ::nType == 2
         FOR j := 1 TO nLen
            IF l1
               IF ::aValues[i, j] != NIL
                  ::ymax := Max(::ymax, ::aValues[i, j])
                  ::ymin := Min(::ymin, ::aValues[i, j])
               ENDIF
            ELSE
               IF ::aValues[i, j, 2] != NIL
                 ::ymax := Max(::ymax, ::aValues[i, j, 2])
                 ::ymin := Min(::ymin, ::aValues[i, j, 2])
               ENDIF
            ENDIF
         NEXT
         ::xmax := nLen
      ELSEIF ::nType == 3
         FOR j := 1 TO nLen
            IF l1
               ::ymax := Max(::ymax, ::aValues[i, j])
            ELSE
               ::ymax += ::aValues[i, j, 2]
            ENDIF
         NEXT
      ENDIF
      IF l1
         ::xmax := nLen
      ENDIF
   NEXT

   RETURN NIL

METHOD HGraph:Paint(lpdis)

   LOCAL drawInfo := hwg_Getdrawiteminfo(lpdis)
   LOCAL hDC := drawInfo[3]
   LOCAL x1 := 0
   LOCAL y1 := 0
   LOCAL x2 := ::nWidth
   LOCAL y2 := ::nHeight
   LOCAL scaleX
   LOCAL scaleY
   LOCAL i
   LOCAL j
   LOCAL nLen
   LOCAL l1
   LOCAL x0
   LOCAL y0
   LOCAL px1
   LOCAL px2
   LOCAL py1
   LOCAL py2
   LOCAL nWidth

   IF ::nType == 0 .OR. ::nType > 3 .OR. Empty(::aValues)
      RETURN NIL
   ENDIF
   IF ::xmax == NIL
      ::CalcMinMax()
   ENDIF

   x1 += ::x1Def
   x2 -= ::x2Def
   y1 += ::y1Def
   y2 -= ::y2Def

   IF ::nType < 3
      scaleX := (::xmax - ::xmin) / (x2 - x1)
      scaleY := (::ymax - ::ymin) / (y2 - y1)
   ELSE
      scaleX := scaleY := 1
   ENDIF

   IF ::oPenGrid == NIL
      ::oPenGrid := HPen():Add(PS_SOLID, 1, ::colorGrid)
   ENDIF
   IF ::oPen == NIL
      ::oPen := HPen():Add(PS_SOLID, 2, ::tcolor)
   ENDIF
   IF ::nGraphs > 1 .AND. hb_IsArray(::aColors) .AND. ::aPens == NIL
      ::aPens := Array(Len(::aColors))
      FOR i := 1 TO Len(::aColors)
         ::aPens[i] := HPen():Add(PS_SOLID, 2, ::aColors[i])
      NEXT
   ENDIF
   x0 := x1 + (0 - ::xmin) / scaleX
   y0 := IIf(::lPositive, y2, y2 - (0 - ::ymin) / scaleY)

   hwg_Fillrect(hDC, 0, 0, ::nWidth, ::nHeight, ::brush:handle)
   IF ::nType != 3
      hwg_Selectobject(hDC, ::oPenGrid:handle)
      hwg_Drawline(hDC, x0, 3, x0, ::nHeight - 3)
      hwg_Drawline(hDC, 3, y0, ::nWidth - 3, y0)
   ENDIF

   IF ::ymax != ::ymin .OR. ::ymax != 0
      FOR i := 1 TO ::nGraphs
         IF ::aPens == NIL .OR. i > Len(::aPens)
            hwg_Selectobject(hDC, ::oPen:handle)
         ELSE
            hwg_Selectobject(hDC, ::aPens[i]:handle)
         ENDIF
         nLen := Len(::aValues[i])
         l1 := (hb_IsNumeric(::aValues[i, 1]))
         IF ::nType == 1
            FOR j := 2 TO nLen
               px1 := Round(x1 + (IIf(l1, j - 1, ::aValues[i, j - 1, 1]) - ::xmin) / scaleX, 0)
               py1 := Round(y2 - (IIf(l1, ::aValues[i, j - 1], ::aValues[i, j - 1, 2]) - ::ymin) / scaleY, 0)
               px2 := Round(x1 + (IIf(l1, j, ::aValues[i, j, 1]) - ::xmin) / scaleX, 0)
               py2 := Round(y2 - (IIf(l1, ::aValues[i, j], ::aValues[i, j, 2]) - ::ymin) / scaleY, 0)
               IF px2 != px1
                  IF ::nLineType == 0
                     hwg_Rectangle(hDC, px1, py1, px1 + ::nPointSize - 1, py1 + ::nPointSize - 1)
                     hwg_Rectangle(hDC, px2, py2, px2 + ::nPointSize - 1, py2 + ::nPointSize - 1)
                  ELSEIF ::nLineType == 1
                     hwg_Drawline(hDC, px1, py1, px2, py2)
                  ELSEIF ::nLineType == 2
                     hwg_Drawline(hDC, px1, y0, px1, py1)
                     hwg_Drawline(hDC, px2, y0, px2, py2)
                  ENDIF
               ENDIF
            NEXT
         ELSEIF ::nType == 2
            IF ::tbrush == NIL
               ::tbrush := HBrush():Add(::tcolor)
            ENDIF
            nWidth := Round((x2 - x1) / (nLen), 0)
            FOR j := 1 TO nLen
               IF IIf(l1, ::aValues[i, j], ::aValues[i, j, 2]) != NIL
                  px1 := Round(x1 + nWidth * (j - 1) + 1, 0)
                  py1 := Round(y2 - 2 - (IIf(l1, ::aValues[i, j], ::aValues[i, j, 2]) - ::ymin) / scaleY, 0)
                  hwg_Fillrect(hDC, px1, y2 - 2, px1 + nWidth - 1, py1, ::tbrush:handle)
               ENDIF
            NEXT
         ELSEIF ::nType == 3
            IF ::tbrush == NIL
               ::tbrush := HBrush():Add(::tcolor)
            ENDIF
            hwg_Selectobject(hDC, ::oPenGrid:handle)
            hwg_Selectobject(hDC, ::tbrush:handle)
            hwg_Pie(hDC, x1 + 10, y1 + 10, x2 - 10, y2 - 10, x1, Round(y1 + (y2 - y1) / 2, 0), Round(x1 + (x2 - x1) / 2, 0), y1)
         ENDIF
      NEXT
   ENDIF

   hwg_Selectobject(hDC, ::oPenGrid:handle)
   IF !Empty(::aSignY)
      IF ::oFont != NIL
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF
      hwg_Settextcolor(hDC, ::colorCoor)
      FOR i := 1 TO Len(::aSignY)
         py1 := Round(y2 - 2 - (::aSignY[i, 1] - ::ymin) / scaleY, 0)
         IF py1 > y1 .AND. py1 < y2
            hwg_Drawline(hDC, x0 - 4, py1, x0 + 1, py1)
            IF ::aSignY[i, 2] != NIL
               hwg_Drawtext(hDC, IIf(hb_IsChar(::aSignY[i, 2]), ::aSignY[i, 2], Ltrim(Str(::aSignY[i, 2]))), 0, py1 - 8, x0 - 4, py1 + 8, DT_RIGHT)
               IF ::lGridY
                  hwg_Drawline(hDC, x0 + 1, py1, x2, py1)
               ENDIF
            ENDIF
         ENDIF
      NEXT
   ENDIF
   IF !Empty(::aSignX)
      IF ::oFont != NIL
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF
      hwg_Settextcolor(hDC, ::colorCoor)
      FOR i := 1 TO Len(::aSignX)
         px1 := Round(x1 + (::aSignX[i, 1] - ::xmin) / scaleX + IIf(::nType == 2 .AND. ::lGridXMid, nWidth / 2, 0), 0)
         hwg_Drawline(hDC, px1, y0 + 4, px1, y0 - 1)
         IF ::aSignX[i, 2] != NIL
            hwg_Drawtext(hDC, IIf(hb_IsChar(::aSignX[i, 2]), ::aSignX[i, 2], Ltrim(Str(::aSignX[i, 2]))), px1 - 40, y0 + 4, px1 + 40, y0 + 20, DT_CENTER)
            IF ::lGridX
               hwg_Drawline(hDC, px1, y0 - 1, px1, y1)
            ENDIF
         ENDIF
      NEXT
   ENDIF

   RETURN NIL

METHOD HGraph:Rebuild(aValues, nType, nLineType, nPointSize)

   ::aValues := aValues
   IF nType != NIL
      ::nType := nType
   ENDIF
   IF nLineType != NIL
      ::nLineType := nLineType
   ENDIF
   IF nPointSize != NIL
      ::nPointSize := nPointSize
   ENDIF
   IF ::nType != 0
      ::CalcMinMax()
   ENDIF
   hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)

   RETURN NIL
