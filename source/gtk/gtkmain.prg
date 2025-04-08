//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// Main prg level functions
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include "hwguipp.ch"

FUNCTION hwg_EndWindow()

   IF HWindow():GetMain() != NIL
      HWindow():aWindows[1]:Close()
   ENDIF

   RETURN NIL

FUNCTION hwg_ColorC2N( cColor )

   LOCAL i
   LOCAL res := 0
   LOCAL n := 1
   LOCAL iValue

   IF Left(cColor, 1) == "#"
      cColor := Substr(cColor, 2)
   ENDIF
   cColor := Trim(cColor)
   FOR i := 1 TO Len(cColor)
      iValue := Asc( SubStr(cColor, i, 1) )
      IF iValue < 58 .AND. iValue > 47
         iValue -= 48
      ELSEIF iValue >= 65 .AND. iValue <= 70
         iValue -= 55
      ELSEIF iValue >= 97 .AND. iValue <= 102
         iValue -= 87
      ELSE
         RETURN 0
      ENDIF
      iValue *= n
      IF i % 2 == 1
         iValue *= 16
      ELSE
         n *= 256
      ENDIF
      res += iValue
   NEXT

   RETURN res

FUNCTION hwg_ColorN2C( nColor )

   LOCAL s := ""
   LOCAL n1
   LOCAL n2
   LOCAL i

   FOR i := 0 to 2
      n1 := hb_BitAnd( hb_BitShift( nColor,-i*8-4 ), 15 )
      n2 := hb_BitAnd( hb_BitShift( nColor,-i*8 ), 15 )
      s += Chr(IIf(n1 < 10, n1 + 48, n1 + 55)) + Chr(IIf(n2 < 10, n2 + 48, n2 + 55))
   NEXT

   RETURN s

FUNCTION hwg_ColorN2RGB(nColor, nr, ng, nb)

   nr := nColor % 256
   ng := Int( nColor/256 ) % 256
   nb := Int( nColor/65536 )

   RETURN { nr, ng, nb }

FUNCTION hwg_MsgGet( cTitle, cText, nStyle, nX, nY, nDlgStyle, cRes )

   LOCAL oModDlg
   LOCAL oFont := HFont():Add( "Sans", 0, 12 )

   IF Empty(cRes)
      cRes := ""
   ENDIF
   nStyle := IIf(nStyle == NIL, 0, nStyle)
   nX := IIf(nX == NIL, 210, nX)
   nY := IIf(nY == NIL, 10, nY)
   nDlgStyle := IIf(nDlgStyle == NIL, 0, nDlgStyle)

   INIT DIALOG oModDlg TITLE cTitle AT nX, nY SIZE 300, 140 ;
      FONT oFont CLIPPER STYLE WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + nDlgStyle

   IF !Empty(cText)
      @ 20, 10 SAY cText SIZE 260, 22
   ENDIF
   @ 20, 35 GET cres  SIZE 260, 26 STYLE WS_DLGFRAME + WS_TABSTOP + nStyle
   Atail( oModDlg:aControls ):Anchor := ANCHOR_TOPABS + ANCHOR_LEFTABS + ANCHOR_RIGHTABS

   @ 20, 95 BUTTON "Ok" ID IDOK SIZE 100, 32 ON CLICK { ||oModDlg:lResult := .T., hwg_EndDialog() } ON SIZE ANCHOR_BOTTOMABS
   @ 180, 95 BUTTON "Cancel" ID IDCANCEL SIZE 100, 32 ON CLICK { ||hwg_EndDialog() } ON SIZE ANCHOR_RIGHTABS + ANCHOR_BOTTOMABS

   ACTIVATE DIALOG oModDlg

   oFont:Release()
   IF oModDlg:lResult
      RETURN Trim(cRes)
   ELSE
      cRes := ""
   ENDIF

   RETURN cRes

FUNCTION hwg_WChoice( arr, cTitle, nX, nY, oFont, clrT, clrB, clrTSel, clrBSel, cOk, cCancel )

   LOCAL oDlg
   LOCAL oBrw
   LOCAL lNewFont := .F.
   LOCAL nChoice := 0
   LOCAL i
   LOCAL aLen := Len(arr)
   LOCAL nLen := 0
   LOCAL addX := 20
   LOCAL addY := 20
   LOCAL minWidth := 0
   LOCAL x1
   LOCAL hDC
   LOCAL aMetr
   LOCAL width
   LOCAL height
   LOCAL screenh

   IF cTitle == NIL
      cTitle := ""
   ENDIF
   IF nX == NIL
      nX := 10
   ENDIF
   IF nY == NIL
      nY := 10
   ENDIF
   IF oFont == NIL
      oFont := HFont():Add( "Times", 0, 14 )
      lNewFont := .T.
   ENDIF
   IF cOk != NIL
      minWidth += 120
      IF cCancel != NIL
         minWidth += 100
      ENDIF
      addY += 36
   ENDIF

   IF HB_ISARRAY(arr[1])
      FOR i := 1 TO aLen
         nLen := Max( nLen, Len(arr[i, 1]) )
      NEXT
   ELSE
      FOR i := 1 TO aLen
         nLen := Max( nLen, Len(arr[i]) )
      NEXT
   ENDIF

   hDC := hwg_Getdc( HWindow():GetMain():handle )
   hwg_Selectobject(hDC, ofont:handle)
   aMetr := hwg_Gettextmetric(hDC)
   hwg_Releasedc( hwg_Getactivewindow(), hDC )
   height := ( aMetr[1] + 5 ) * aLen + 4 + addY
   screenh := hwg_Getdesktopheight()
   IF height > screenh * 2/3
      height := Int( screenh * 2/3 )
      addX := addY := 0
   ENDIF
   width := Max( minWidth, aMetr[2] * 2 * nLen + addX )

   INIT DIALOG oDlg TITLE cTitle AT nX, nY SIZE width, height FONT oFont

   @ 0, 0 BROWSE oBrw ARRAY SIZE width, height - addY FONT oFont STYLE WS_BORDER ;
      ON SIZE {|o,x,y|o:Move( addX/2, 10, x - addX, y - addY )} ;
      ON CLICK { |o|nChoice := o:nCurrent, hwg_EndDialog( o:oParent:handle ) }

   IF HB_ISARRAY(arr[1])
      oBrw:AddColumn(HColumn():New(NIL, {|value, o|HB_SYMBOL_UNUSED(value), o:aArray[o:nCurrent, 1]}, "C", nLen))
   ELSE
      oBrw:AddColumn(HColumn():New(NIL, {|value, o|HB_SYMBOL_UNUSED(value), o:aArray[o:nCurrent]}, "C", nLen))
   ENDIF
   hwg_CREATEARLIST( oBrw, arr )
   oBrw:lDispHead := .F.
   IF clrT != NIL
      oBrw:tcolor := clrT
   ENDIF
   IF clrB != NIL
      oBrw:bcolor := clrB
   ENDIF
   IF clrTSel != NIL
      oBrw:tcolorSel := clrTSel
   ENDIF
   IF clrBSel != NIL
      oBrw:bcolorSel := clrBSel
   ENDIF

   IF cOk != NIL
      x1 := Int( width/2 ) - IIf(cCancel != NIL, 90, 40)
      @ x1, height - 36 BUTTON cOk SIZE 80, 30 ;
            ON CLICK { ||nChoice := oBrw:nCurrent, hwg_EndDialog( oDlg:handle ) } ;
            ON SIZE ANCHOR_BOTTOMABS
      IF cCancel != NIL
         @ x1 + 100, height - 36 BUTTON cCancel SIZE 80, 30 ;
            ON CLICK { ||hwg_EndDialog( oDlg:handle ) } ;
            ON SIZE ANCHOR_BOTTOMABS
      ENDIF
   ENDIF

   oDlg:Activate()
   IF lNewFont
      oFont:Release()
   ENDIF

   RETURN nChoice

FUNCTION hwg_RefreshAllGets( oDlg )

   AEval( oDlg:GetList, { |o|o:Refresh() } )

   RETURN NIL

FUNCTION HWG_Version( n )

   IF !Empty(n)
      SWITCH n
      CASE 1 ; RETURN HWG_VERSION
      CASE 2 ; RETURN HWG_BUILD
      CASE 3 ; RETURN 1
      CASE 4 ; RETURN 1
      ENDSWITCH
   ENDIF

   RETURN "HWGUI++ " + HWG_VERSION // + " Build " + LTrim(Str(HWG_BUILD))

FUNCTION hwg_WriteStatus( oWnd, nPart, cText )

   LOCAL aControls
   LOCAL i

   aControls := oWnd:aControls
   IF ( i := Ascan( aControls, { |o|o:ClassName() == "HSTATUS" } ) ) > 0
      hwg_Writestatuswindow( aControls[i]:handle, 0, cText )
   ELSEIF ( i := Ascan( aControls, { |o|o:ClassName() = "HPANELSTS" } ) ) > 0
      aControls[i]:Write(cText, nPart)
   ENDIF

   RETURN NIL

FUNCTION hwg_FindParent( hCtrl, nLevel )

   LOCAL i
   LOCAL oParent
   LOCAL hParent := hwg_Getparent( hCtrl )

   IF hParent > 0
      IF ( i := Ascan( HDialog():aModalDialogs,{ |o|o:handle == hParent } ) ) != 0
         RETURN HDialog():aModalDialogs[i]
      ELSEIF ( oParent := HDialog():FindDialog( hParent ) ) != NIL
         RETURN oParent
      ELSEIF ( oParent := HWindow():FindWindow( hParent ) ) != NIL
         RETURN oParent
      ENDIF
   ENDIF
   IF nLevel == NIL
      nLevel := 0
   ENDIF
   IF nLevel < 2
      IF ( oParent := hwg_FindParent( hParent,nLevel + 1 ) ) != NIL
         RETURN oParent:FindControl(NIL, hParent)
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION hwg_FindSelf( hCtrl )

   LOCAL oParent

   oParent := hwg_FindParent( hCtrl )
   IF oParent != NIL
      RETURN oParent:FindControl(NIL, hCtrl)
   ENDIF

   RETURN NIL

FUNCTION hwg_getParentForm( o )
   DO WHILE o:oParent != NIL .AND. !__ObjHasMsg( o, "GETLIST" )
      o := o:oParent
   ENDDO
   RETURN o

FUNCTION HWG_ISWINDOWVISIBLE( handle )

   LOCAL o := hwg_GetWindowObject( handle )

   IF o != NIL .AND. o:lHide
      RETURN .F.
   ENDIF

   RETURN .T.
