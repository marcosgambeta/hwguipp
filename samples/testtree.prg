/*
 * This sample demonstrates the using of a TREE control
 * 
 */

#include "hwguipp.ch"

Function Main
Local oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Example" ;
     AT 200,0 SIZE 400,150

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION hwg_EndWindow()
      MENUITEM "&Tree" ACTION DlgGet()
   ENDMENU

   ACTIVATE WINDOW oMainWindow
Return NIL

Function DlgGet
Local oDlg, oFont := HFont():Add( "MS Sans Serif",0,-13 )
Local oTree, oSplit, oSay, oPopup

   INIT DIALOG oDlg TITLE "TreeView control sample"  ;
   AT 210,10  SIZE 430,300                  ;
   FONT oFont                               ;
   ON INIT {||BuildTree(oDlg,oTree,oSay)}

   CONTEXT MENU oPopup
      MENUITEM "Add child"  ACTION {||AddNode( oTree,0 )}
      MENUITEM "Add after"  ACTION {||AddNode( oTree,1 )}
      MENUITEM "Add before" ACTION {||AddNode( oTree,2 )}
   ENDMENU

   @ 10,10 TREE oTree OF oDlg SIZE 200,280 ;
        EDITABLE ;
        BITMAP { "..\image\cl_fl.bmp","..\image\op_fl.bmp" } ;
        ON SIZE {|o,x,y|o:Move(,,,y-20)}

   oTree:bRClick := {|ot,on|TreeMenuShow( ot, oPopup, on )}

   @ 214,10 SAY oSay CAPTION "" SIZE 206,280 STYLE WS_BORDER ;
        ON SIZE {|o,x,y|o:Move(,,x-oSplit:nLeft-oSplit:nWidth-10,y-20)}

   @ 210,10 SPLITTER oSplit SIZE 4,260 ;
         DIVIDE {oTree} FROM {oSay} ;
         ON SIZE {|o,x,y|o:Move(,,,y-20)}

   oSplit:bEndDrag := {||hwg_Redrawwindow( oSay:handle,RDW_ERASE+RDW_INVALIDATE+RDW_INTERNALPAINT+RDW_UPDATENOW)}

   ACTIVATE DIALOG oDlg
   oFont:Release()

Return NIL

Function BuildTree( oDlg,oTree,oSay )
Local oNode

   INSERT NODE "First" TO oTree ON CLICK {||NodeOut(1,oSay)}
   INSERT NODE "Second" TO oTree ON CLICK {||NodeOut(2,oSay)}
   INSERT NODE oNode CAPTION "Third" TO oTree ON CLICK {||NodeOut(0,oSay)}
      INSERT NODE "Third-1" TO oNode BITMAP {"..\image\book.bmp"} ON CLICK {||NodeOut(3,oSay)}
      INSERT NODE "Third-2" TO oNode BITMAP {"..\image\book.bmp"} ON CLICK {||NodeOut(4,oSay)}
   INSERT NODE "Forth" TO oTree ON CLICK {||NodeOut(5,oSay)}

   oTree:bExpand := {||.T.}

Return NIL

Static Function NodeOut( n, oSay )
Local aText := { ;
  "This is a sample application, which demonstrates using of TreeView control in HwGUI.", ;
  "'Second' item is selected", ;
  "'Third-1' item is selected", ;
  "'Third-2' item is selected", ;
  "'Forth' item is selected", ;
               }

   IF n == 0
      oSay:SetText("")
   ELSE
      oSay:SetText(aText[n])
   ENDIF

Return NIL

Static Function TreeMenuShow( oTree, oPopup, oNode )

   oTree:Select( oNode )
   oPopup:Show( oTree:oParent )

Return NIL

Static Function AddNode( oTree, nType )

   LOCAL cName, oTo

   IF !Empty(cName := hwg_MsgGet( "Node name" ))
      oTo := Iif( oTree:oSelected:oParent == NIL, oTree, oTree:oSelected:oParent )
      IF nType == 0
         INSERT NODE cName TO oTree:oSelected
      ELSEIF nType == 1
         INSERT NODE cName TO oTo AFTER oTree:oSelected
      ELSE
         INSERT NODE cName TO oTo BEFORE oTree:oSelected
      ENDIF
   ENDIF
Return NIL
