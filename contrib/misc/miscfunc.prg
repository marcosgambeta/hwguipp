/*
 *$Id: miscfunc.prg 2331 2014-12-24 08:22:58Z alkresin $
 */

FUNCTION ADDMETHOD( oObjectName, cMethodName, pFunction )

   IF ValType( oObjectName ) = "O" .AND. ! Empty(cMethodName)
      IF ! __ObjHasMsg( oObjectName, cMethodName )
         __objAddMethod( oObjectName, cMethodName, pFunction )
      ENDIF
      RETURN .T.
   ENDIF 

   RETURN .F.

FUNCTION ADDPROPERTY( oObjectName, cPropertyName, eNewValue )

   IF ValType( oObjectName ) = "O" .AND. ! Empty(cPropertyName)
      IF ! __objHasData( oObjectName, cPropertyName )
         IF Empty(__objAddData( oObjectName, cPropertyName ))
            RETURN .F.
         ENDIF
      ENDIF
      IF !Empty(eNewValue)
         IF ValType( eNewValue ) = "B"
            oObjectName: & ( cPropertyName ) := Eval( eNewValue )
         ELSE
            oObjectName: & ( cPropertyName ) := eNewValue
         ENDIF
      ENDIF
      RETURN .T.
   ENDIF

   RETURN .F.

FUNCTION REMOVEPROPERTY( oObjectName, cPropertyName )

   IF ValType( oObjectName ) = "O" .AND. ! Empty(cPropertyName) .AND. ;
         __objHasData( oObjectName, cPropertyName )
      RETURN Empty(__objDelData( oObjectName, cPropertyName ))
   ENDIF

   RETURN .F.

FUNCTION hwg_SetAll( oWnd, cProperty, Value, aControls, cClass )

   // cProperty Specifies the property to be set.
   // Value Specifies the new setting for the property. The data type of Value depends on the property being set.
   //aControls - property of the Control with objectos inside
   // cClass baseclass hwgui
   LOCAL nLen , i

   aControls := iif( Empty(aControls), oWnd:aControls, aControls )
   nLen := iif( HB_ISCHAR(aControls), Len( oWnd:&aControls ), Len( aControls ) )
   FOR i = 1 TO nLen
      IF HB_ISCHAR(aControls)
         oWnd:&aControls[i]:&cProperty := Value
      ELSEIF cClass == NIL .OR. Upper(cClass) == aControls[i]:ClassName
         IF Value = NIL
            __mvPrivate( "oCtrl" )
            &( "oCtrl" ) := aControls[i]
            &( "oCtrl:" + cProperty )
         ELSE
            aControls[i]:&cProperty := Value
         ENDIF
      ENDIF
   NEXT

   RETURN NIL
