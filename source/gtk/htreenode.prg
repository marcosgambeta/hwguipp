/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HBrowse class - browse databases and arrays
 *
 * Copyright 2013 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "gtk.ch"
#include "hwgui.ch"
#include "inkey.ch"
#include "dbstruct.ch"
#include "hbclass.ch"

CLASS HTreeNode INHERIT HObject

   DATA handle
   DATA oTree
   DATA oParent
   DATA nLevel
   DATA lExpanded INIT .F.
   DATA title
   DATA aImages
   DATA aItems INIT {}
   DATA bClick

   METHOD New( oTree, oParent, oPrev, oNext, cTitle, bClick, aImages )
   METHOD AddNode( cTitle, oPrev, oNext, bClick, aImages )
   METHOD DELETE(lInternal)
   METHOD GetText() INLINE ::title
   METHOD SetText( cText ) INLINE ::title := cText
   METHOD getNodeIndex()
   METHOD PrevNode( nNode, lSkip )
   METHOD NextNode( nNode, lSkip )

ENDCLASS

METHOD HTreeNode:New( oTree, oParent, oPrev, oNext, cTitle, bClick, aImages )

   LOCAL aItems
   LOCAL i
   LOCAL h
   LOCAL op
   LOCAL nPos

   // Variables not used
   // LOCAL im1, im2, cImage

   ::oTree := oTree
   ::oParent := oParent
   ::nLevel := iif(__ObjHasMsg( oParent, "NLEVEL" ), oParent:nLevel + 1, 1)
   ::bClick := bClick
   ::title := iif(Empty(cTitle), "", cTitle)
   ::handle := ++ oTree:nNodeCount

   IF aImages != NIL .AND. !Empty(aImages)
      ::aImages := {}
      FOR i := 1 TO Len(aImages)
         AAdd(::aImages, iif(oTree:Type, hwg_BmpFromRes(aImages[i]), hwg_Openimage(AddPath(aImages[i], HBitmap():cPath))))
      NEXT
   ENDIF

   nPos := iif(oPrev == NIL, 2, 0)
   IF oPrev == NIL .AND. oNext != NIL
      op := iif(oNext:oParent == NIL, oNext:oTree, oNext:oParent)
      FOR i := 1 TO Len(op:aItems)
         IF op:aItems[i]:handle == oNext:handle
            EXIT
         ENDIF
      NEXT
      IF i > 1
         oPrev := op:aItems[i - 1]
         nPos := 0
      ELSE
         nPos := 1
      ENDIF
   ENDIF

   aItems := iif(oParent == NIL, oTree:aItems, oParent:aItems)
   IF nPos == 2
      AAdd(aItems, Self)
   ELSEIF nPos == 1
      AAdd(aItems, NIL)
      AIns( aItems, 1 )
      aItems[1] := Self
   ELSE
      AAdd(aItems, NIL)
      h := oPrev:handle
      IF ( i := AScan( aItems, { | o | o:handle == h } ) ) == 0
         aItems[Len(aItems)] := Self
      ELSE
         AIns( aItems, i + 1 )
         aItems[i + 1] := Self
      ENDIF
   ENDIF

   RETURN Self

METHOD HTreeNode:AddNode( cTitle, oPrev, oNext, bClick, aImages )
   
   LOCAL oParent := Self
   LOCAL oNode := HTreeNode():New(::oTree, oParent, oPrev, oNext, cTitle, bClick, aImages)

   RETURN oNode

METHOD HTreeNode:DELETE( lInternal )
   
   LOCAL h := ::handle
   LOCAL j
   LOCAL alen
   LOCAL aItems

   IF !Empty(::aItems)
      alen := Len(::aItems)
      FOR j := 1 TO alen
         ::aItems[j]:Delete( .T. )
         ::aItems[j] := NIL
      NEXT
   ENDIF
   IF lInternal == NIL
      aItems := iif(::oParent == NIL, ::oTree:aItems, ::oParent:aItems)
      j := AScan( aItems, { | o | o:handle == h } )
      ADel( aItems, j )
      ASize( aItems, Len(aItems) - 1 )
   ENDIF

   RETURN NIL

METHOD HTreeNode:getNodeIndex()
   
   LOCAL aItems := ::oParent:aItems
   LOCAL nNode

   FOR nNode := 1 TO Len(aItems)
      IF aItems[nNode] == Self
         EXIT
      ENDIF
   NEXT

   RETURN nNode

METHOD HTreeNode:PrevNode( nNode, lSkip )
   
   LOCAL oNode

   IF nNode == NIL
      nNode := ::getNodeIndex()
   ENDIF

   IF nNode == 1
      IF ::nLevel == 1
         RETURN NIL
      ELSE
         oNode := ::oParent
         nNode := oNode:getNodeIndex()
      ENDIF
   ELSE
      nNode --
      oNode := ::oParent:aItems[nNode]
      IF oNode:lExpanded .AND. Empty(lSkip)
         nNode := Len(oNode:aItems)
         oNode := oNode:aItems[nNode]
      ENDIF
   ENDIF

   RETURN oNode

METHOD HTreeNode:NextNode( nNode, lSkip )
   
   LOCAL oNode

   IF nNode == NIL
      nNode := ::getNodeIndex()
   ENDIF
   IF ::lExpanded .AND. Empty(lSkip)
      nNode := 1
      oNode := ::aItems[nNode]
   ELSEIF nNode < Len(::oParent:aItems)
      oNode := ::oParent:aItems[++nNode]
   ELSEIF ::nLevel > 1
      nNode := ::oParent:getNodeIndex()
      oNode := ::oParent:NextNode( @nNode, .T. )
   ELSE
      RETURN NIL
   ENDIF

   RETURN oNode

STATIC PROCEDURE ReleaseTree( aItems, lDelImages )
   
   LOCAL i
   LOCAL j
   LOCAL iLen := Len(aItems)

   FOR i := 1 TO iLen
      IF lDelImages .AND. !Empty(aItems[i]:aImages)
         FOR j := 1 TO Len(aItems[i]:aImages)
            IF aItems[i]:aImages[j] != NIL
               hwg_Deleteobject( aItems[i]:aImages[j] )
               aItems[i]:aImages[j] := NIL
            ENDIF
         NEXT
      ENDIF
      ReleaseTree( aItems[i]:aItems, lDelImages )
   NEXT

   RETURN
