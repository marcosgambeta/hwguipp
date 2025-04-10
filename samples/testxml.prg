/*
 * This sample demonstrates reading/writing XML file and handling menu items
 * while run-time.
 */
 
    * Status:
    *  WinAPI   :  Yes
    *  GTK/Linux:  Yes
    *  GTK/Win  :  Yes
/*
  Modifications by DF7BE:
  - Ready for GTK
  - GET problem fixed
  - Russian charset (windows-1251) modified to windows-1252 / UTF-8 + Euro currency sign
  
  Additional instructions:
  Store XML file with correct coding:
  1.) In header line of XML set encoding:
      <?xml version="1.0" encoding="windows-1252"?>
  2.) In your editor be shure, that
      (if XML file is openend)
      the correct coding is displayed,
      in Notepad++ look at left bottom side:
      Dos\Windows  Windows-1252
  3.) If creating a new XML file with method Save():
      Create object of class cl HXMLDoc , method New(encoding),
      Set for encoding the desired encoding.  
  4.) If using a font ,
      create it with CHARSET clause: 0 for windows1252 and
      204 for windows1251 russian.
  
   Fix as soon as possible:
   Symtom:
   GET ignores here keys only reachable together with "AltGr" key like
   ~{[]}@| !
   Reason:
   The  X Size of the GET control must big enough to display all
   characters of the variable.
   More description look at command documentation vor @ <x>,<y> GET ...   
*/

* reduced from 100:
#define CINFOLEN 40

REQUEST HB_LANG_DE 
REQUEST HB_CODEPAGE_DEWIN
#ifdef __LINUX__
* LINUX Codepage
REQUEST HB_CODEPAGE_UTF8
#endif 


#include "hwguipp.ch"
#include "hxml.ch"

MEMVAR oXmlDoc, lIniChanged, nCurrentItem , oMainWindow, oFont

Function Main
Local oXmlNode
Local i, j, fname := ""
Private oXmlDoc, lIniChanged := .F., nCurrentItem
Private oMainWindow, oFont


#ifdef __LINUX__
     hb_cdpSelect( "UTF8" )
#else
     hb_cdpSelect( "DEWIN" )
#endif
HB_LANGSELECT("DE")

   oXmlDoc := HXMLDoc():Read("testxml.xml")

   PREPARE FONT oFont NAME "Times New Roman" WIDTH 0 HEIGHT -17 // CHARSET 0 // 204 = Russian

   INIT WINDOW oMainWindow MAIN TITLE "XML Sample"  ;
     SYSCOLOR COLOR_3DLIGHT+1                       ;
     AT 200, 0 SIZE 600, 300                       ;
     ON EXIT {||SaveOptions()}                   ;
     FONT oFont

   MENU OF oMainWindow
      MENU TITLE "File"
         MENUITEM "New item" ACTION NewItem(0)
         SEPARATOR
         IF !Empty(oXmlDoc:aItems)
            nCurrentItem := 1
            FOR i := 1 TO Len( oXmlDoc:aItems[1]:aItems )
               oXmlNode := oXmlDoc:aItems[1]:aItems[i]
               fname := oXmlNode:GetAttribute("name")
               Hwg_DefineMenuItem( fname, 1020+i, &( "{||NewItem("+LTrim(Str(i, 2))+")}" ) )
            * other behavior on GTK:
            * the new item was appended at the end of the menu in the recent run.
            * After restart the program (in case of new reading of the
            * XML file) the new item appears at the same position like the WinAPI sample. 
            NEXT
            SEPARATOR
         ENDIF
         MENUITEM "Exit" ACTION hwg_EndWindow()
      ENDMENU

      MENU TITLE "Help"
         MENUITEM "About" ACTION p_about() 
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oMainWindow

Return NIL

Function NewItem( nItem )
Local oDlg, oItemFont, oFontNew
Local oXmlNode, fname, i, j, aMenu, nId
Local cName, cInfo
Local oGet1, oGet2


   IF nItem > 0
      oXmlNode := oXmlDoc:aItems[1]:aItems[nItem]
      cName := oXmlNode:GetAttribute( "name" )
      FOR i := 1 TO Len( oXmlNode:aItems )
         IF hb_IsChar(oXmlNode:aItems[i])
            cInfo := oXmlNode:aItems[i]
         ELSEIF oXmlNode:aItems[i]:title == "font"
            oItemFont := FontFromXML( oXmlNode:aItems[i] )
         ENDIF
      NEXT
      * Trim variables for GET 
      cName := PADR(cName, 30)
      cInfo := PADR(cInfo, CINFOLEN)
   ELSE
      cName := Space(30)
      cInfo := Space(CINFOLEN)
      oItemFont := oFont
   ENDIF
   
    cName := hwg_GET_Helper(cName, 30)
    cInfo := hwg_GET_Helper(cInfo,CINFOLEN)
   

   INIT DIALOG oDlg TITLE Iif( nItem == 0,"New item","Change item" )  ;
   AT 210, 10 SIZE 700, 150 FONT oFont  // old SIZE 300, 150

   @ 20, 20 SAY "Name:" SIZE 60, 22
   
   /*
   @ 80, 20 GET cName SIZE 150, 26    STYLE WS_BORDER
   */    
   
   @ 80, 20 GET oGet1 VAR cName SIZE 500, 26 ;  // old SIZE 150, 26
     STYLE WS_BORDER

   * Old position: 240, 20
   @ 600, 15  BUTTON "Font" SIZE 40, 32 ON CLICK {||oFontNew:=HFont():Select(oItemFont)}

   @ 20, 50 SAY "Info:" SIZE 60, 22
   @ 80, 50 GET oGet2 VAR cInfo SIZE 550, 26 ;  // old SIZE 150, 26
     STYLE WS_BORDER

   @ 20, 110  BUTTON "Ok" SIZE 100, 32 ON CLICK {||oDlg:lResult:=.T.,hwg_EndDialog()}
   @ 180, 110 BUTTON "Cancel" ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDlg
   
   * Trim from GET
   
   cInfo := AllTrim(cInfo)
   cName := AllTrim(cName)
   
    IF oDlg:lResult .AND. !Empty(cName) .AND. !Empty(cInfo)
      IF nItem == 0
         oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New("item") )
         oXmlNode:SetAttribute( "name", cName )
         oXmlNode:Add( cInfo )
         oXMLNode:Add( hwg_Font2XML( Iif( oFontNew != NIL,oFontNew,oFont ) ) )
         lIniChanged := .T.

         aMenu := oMainWindow:menu[1, 1]
         nId := aMenu[1][Len(aMenu[1])-2, 3]+1
         Hwg_AddMenuItem( aMenu, cName, nId, .F., ;
              &( "{||NewItem("+LTrim(Str(nId-1020, 2))+")}" ), Len(aMenu[1])-1 )

      ELSE
         * Modified  
         IF oXmlNode:GetAttribute( "name" ) != cName
            oXmlNode:SetAttribute( "name", cName )
            lIniChanged := .T.
            hwg_Setmenucaption( , 1020+nItem, cName )
         ENDIF
         FOR i := 1 TO Len( oXmlNode:aItems )
            IF hb_IsChar(oXmlNode:aItems[i])
               // hwg_MsgInfo(oXmlNode:aItems[i] + "<>" + cInfo)
               IF ! (cInfo == oXmlNode:aItems[i] )
                /* IF cInfo != oXmlNode:aItems[i] not working correct ! */
                  oXmlNode:aItems[i] := cInfo
                  lIniChanged := .T.
               ENDIF
            ELSEIF oXmlNode:aItems[i]:title == "font"
               IF oFontNew != NIL
                  oXMLNode:aItems[i] := hwg_Font2XML( oFontNew )
                  lIniChanged := .T.
               ENDIF
            ENDIF
         NEXT
      ENDIF
   ENDIF

Return NIL

Function FontFromXML( oXmlNode )
Local width  := oXmlNode:GetAttribute( "width" )
Local height := oXmlNode:GetAttribute( "height" )
Local weight := oXmlNode:GetAttribute( "weight" )
Local charset := oXmlNode:GetAttribute( "charset" )
Local ita   := oXmlNode:GetAttribute( "italic" )
Local under := oXmlNode:GetAttribute( "underline" )

  IF width != NIL
     width := Val(width)
  ENDIF
  IF height != NIL
     height := Val(height)
  ENDIF
  IF weight != NIL
     weight := Val(weight)
  ENDIF
  IF charset != NIL
     charset := Val(charset)
  ENDIF
  IF ita != NIL
     ita := Val(ita)
  ENDIF
  IF under != NIL
     under := Val(under)
  ENDIF
  
  // default charset is NIL 

Return HFont():Add(oXmlNode:GetAttribute("name"), width, height, weight, charset, ita, under)

Function hwg_Font2XML( oFont )
Local aAttr := {}

   Aadd(aAttr, {"name", oFont:name})
   Aadd(aAttr, {"width", Ltrim(Str(oFont:width, 5))})
   Aadd(aAttr, {"height", Ltrim(Str(oFont:height, 5))})
   IF oFont:weight != 0
      Aadd(aAttr, {"weight", Ltrim(Str(oFont:weight, 5))})
   ENDIF
   IF oFont:charset != 0
      Aadd(aAttr, {"charset", Ltrim(Str(oFont:charset, 5))})
   ENDIF
   IF oFont:Italic != 0
      Aadd(aAttr, {"italic", Ltrim(Str(oFont:Italic, 5))})
   ENDIF
   IF oFont:Underline != 0
      Aadd(aAttr, {"underline", Ltrim(Str(oFont:Underline, 5))})
   ENDIF
   
Return HXMLNode():New("font", HBXML_TYPE_SINGLE, aAttr)

Function SaveOptions()
   IF lIniChanged
      oXmlDoc:Save( "testxml.xml" )
   ENDIF
   CLOSE ALL
Return NIL

FUNCTION p_about
#ifdef __GTK__
 hwg_MsgInfo("This sample demonstrates reading/writing" + Chr(10) + ;
 "XML file and handling menu items","HWGUI sample testxml.prg" + Chr(10) + ;
 "while run-time" + ;
 "OS() = " + OS())
#else
 hwg_Shellabout("","")  // Windows only, shows the OS internal Win version display
                      // For multi platform application use OS(), shows
                      // in a short string the OS and it's version number.
                      // Sample output for Windows 10: "Windows 8 6.2" (2020)
#endif
RETURN NIL
