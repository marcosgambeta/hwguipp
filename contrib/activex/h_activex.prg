/*
 * ooHG source code:
 * ActiveX control
 *
 *  Marcelo Torres, Noviembre de 2006.
 *  TActiveX para [x]Harbour Minigui.
 *  Adaptacion del trabajo de:
 *  ---------------------------------------------
 *  Lira Lira Oscar Joel [oSkAr]
 *  Clase TActiveX_FreeWin para Fivewin
 *  Noviembre 8 del 2006
 *  email: oscarlira78@hotmail.com
 *  http://freewin.sytes.net
 *  @CopyRight 2006 Todos los Derechos Reservados
 *  ---------------------------------------------
 *  Implemented by ooHG team.
 *
 * + Soporte de Eventos para los controles activeX [oSkAr] 20070829
 *
 * + Ported to hwgui by FP 20080331
 *
 */

#include "windows.ch"
#include <hbclass.ch>

//-----------------------------------------------------------------------------------------------//
CLASS HActiveX FROM HControl

   CLASS VAR winclass	INIT "ACTIVEX"
   DATA oOle      INIT NIL
   DATA hSink     INIT NIL
   DATA hAtl      INIT NIL
   DATA hObj      INIT NIL

   METHOD Release
   METHOD New

   DELEGATE Set TO oOle
   DELEGATE Get TO oOle
   ERROR HANDLER __Error

   DATA aAxEv        INIT {}              // oSkAr 20070829
   DATA aAxExec      INIT {}              // oSkAr 20070829
   METHOD EventMap( nMsg, xExec, oSelf )  // oSkAr 20070829

ENDCLASS

METHOD HActiveX:New(oWnd, cProgId, nTop, nLeft, nWidth, nHeight, bSize)
   LOCAL nStyle, nExStyle, cClsName, hSink
   LOCAL i,a,h,n
   LOCAL oError, bErrorBlock

   nStyle   := WS_CHILD + WS_VISIBLE //+ WS_CLIPCHILDREN
   nExStyle := 0
   cClsName := "AtlAxWin"

   ::Super:New(oWnd, , nStyle, nLeft, nTop, nWidth, nHeight)   // ,,,,bSize)
   ::title = cProgId

   ::handle := hwg_Createactivex(  nExStyle, cClsName, cProgId, ::style, ;
                              ::nLeft, ::nTop, ::nWidth, ::nHeight, ;
                              ::oParent:handle, ::Id     ;
                            )

   ::Init()

   ::hObj := hwg_Atlaxgetdisp( ::handle )

#ifdef __XHARBOUR__
      bErrorBlock := ErrorBlock({|x|break(x)})
      TRY
         ::oOle := ToleAuto():New(::hObj)
      CATCH oError
         hwg_MsgInfo(oError:Description)
      END
      ErrorBlock( bErrorBlock )
#else
      //hwg_writelog( Valtype(::hObj) + Iif(__oleIsDisp( ::hObj ), " T"," F") )
      ::oOle := win_oleAuto()
      IF __oleIsDisp( ::hObj )
         ::oOle:__hObj := ::hObj
      ENDIF
      IF Empty(::oOle:__hObj)
         hwg_MsgStop("Invalid argument to contructor!")
         RETURN NIL
      ENDIF
#endif

   hwg_Setupconnectionpoint( ::hObj, @hSink, ::aAxEv , ::aAxExec )
   ::hSink := hSink

   RETURN SELF

*-----------------------------------------------------------------------------*
METHOD HActiveX:Release()
*-----------------------------------------------------------------------------*
   hwg_Shutdownconnectionpoint( ::hSink )
   hwg_Releasedispatch( ::hObj )

Return NIL

*-----------------------------------------------------------------------------* 
METHOD HActiveX:__Error( ... )
*-----------------------------------------------------------------------------* 
Local cMessage, uRet 
cMessage := __GetMessage() 

   IF SubStr(cMessage, 1, 1) == "_"
      cMessage := SubStr(cMessage, 2)
   ENDIF

   //hwg_writelog( Valtype(::oOle)+Valtype(cMessage)+Valtype(HB_aParams()) )
   RETURN HB_ExecFromArray( ::oOle, cMessage, HB_aParams() )

//-----------------------------------------------------------------------------------------------//
METHOD HActiveX:EventMap( nMsg, xExec, oSelf )
   LOCAL nAt
   nAt := AScan( ::aAxEv, nMsg )
   IF nAt == 0
      AAdd(::aAxEv, nMsg)
      AAdd(::aAxExec, {NIL, NIL})
      nAt := Len( ::aAxEv )
   ENDIF
   ::aAxExec[nAt] := { xExec, oSelf }
RETURN NIL

