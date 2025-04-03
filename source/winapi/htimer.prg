//
// HWGUI - Harbour Win32 GUI library source code:
// HTimer class
//
// Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

#define TIMER_FIRST_ID 33900

CLASS HTimer INHERIT HObject

   CLASS VAR aTimers INIT {}

   DATA id
   DATA value
   DATA lOnce INIT .F.
   DATA oParent
   DATA bAction
   /*
   ACCESS Interval INLINE ::value
   ASSIGN Interval(x) INLINE ::value := x, IIf(x == 0, ::End(), hwg_SetTimer(::oParent:handle, ::id, x))
   */
   METHOD Interval(n) SETGET
   METHOD New(oParent, nId, value, bAction, lOnce)
   METHOD End()

ENDCLASS

METHOD HTimer:New(oParent, nId, value, bAction, lOnce)

   ::oParent := IIf(oParent == NIL, HWindow():GetMain(), oParent)
   ::id := IIf(nId == NIL, TIMER_FIRST_ID + Len(::aTimers), nId)
   ::value := value
   ::bAction := bAction
   ::lOnce := !Empty(lOnce)

   hwg_Settimer(::oParent:handle, ::id, ::value)
   AAdd(::aTimers, Self)

   RETURN Self

METHOD HTimer:Interval(n)

   LOCAL nOld := ::value

   IF HB_ISNUMERIC(n)
      IF n == 0
         ::End()
      ELSE
         hwg_SetTimer(::oParent:handle, ::id, ::value := n)
      ENDIF
   ENDIF

   RETURN nOld

METHOD HTimer:End()

   LOCAL i

   hwg_Killtimer(::oParent:handle, ::id)
   i := Ascan(::aTimers, {|o|o:id == ::id})
   IF i != 0
      ADel(::aTimers, i)
      ASize(::aTimers, Len(::aTimers) - 1)
   ENDIF

   RETURN NIL

FUNCTION hwg_TimerProc(hWnd, idTimer) //, time )

   LOCAL i := Ascan(HTimer():aTimers, {|o|o:id == idTimer})
   LOCAL b
   LOCAL oParent

   HB_SYMBOL_UNUSED(hWnd)

   IF i != 0
      b := HTimer():aTimers[i]:bAction
      oParent := HTimer():aTimers[i]:oParent
      IF HTimer():aTimers[i]:lOnce
         HTimer():aTimers[i]:End()
      ENDIF
      Eval(b, oParent)
   ENDIF

   RETURN NIL

FUNCTION hwg_ReleaseTimers()

   LOCAL oTimer

   FOR EACH oTimer IN HTimer():aTimers
      hwg_Killtimer(oTimer:oParent:handle, oTimer:id)
   NEXT

   RETURN NIL

EXIT PROCEDURE CleanTimers()

   hwg_ReleaseTimers()

   RETURN
