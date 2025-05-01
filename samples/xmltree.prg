#include "hwguipp.ch"

MEMVAR oFont

Function Main
Local oMainWindow
Private oFont := HFont():Add("MS Sans Serif", 0, -13)

   INIT WINDOW oMainWindow MAIN TITLE "Example" ;
     AT 200, 0 SIZE 400, 150

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION hwg_EndWindow()
      MENUITEM "&Open" ACTION DlgGet()
   ENDMENU

   ACTIVATE WINDOW oMainWindow
RETURN NIL

Function DlgGet
Local oDlg
Local oTree, oXmlDoc
Local fname := hwg_Selectfile( "All files( *.* )", "*.*" )
Local oSplit, oSay

   IF Empty(fname)
      RETURN NIL
   ENDIF

   IF ( oXmlDoc := HXMLDoc():Read(fname) ) = NIL
   ENDIF

   INIT DIALOG oDlg TITLE CutPath(fname)    ;
   AT 210, 10 SIZE 430, 300                  ;
   FONT oFont                               ;
   ON INIT {||BuildTree(oTree,oXmlDoc:aItems,oSay)}

   @ 10, 10 TREE oTree OF oDlg SIZE 200, 280 ;
        EDITABLE ;
        BITMAP { "..\image\cl_fl.bmp","..\image\op_fl.bmp" } ;
        ON SIZE {|o,x,y|o:Move(,,,y-20)}

   @ 214, 10 SAY oSay CAPTION "" SIZE 206, 280 STYLE WS_BORDER ;
        ON SIZE {|o,x,y|o:Move(,,x-oSplit:nLeft-oSplit:nWidth-10,y-20)}

   @ 214, 10 EDITBOX oSay CAPTION "" SIZE 206, 280 STYLE WS_VSCROLL+WS_HSCROLL+ES_MULTILINE+ES_READONLY ;
        ON SIZE {|o,x,y|o:Move(,,x-oSplit:nLeft-oSplit:nWidth-10,y-20)} ;
        ON GETFOCUS {||hwg_Sendmessage(oSay:handle,EM_SETSEL, 0, 0)}

   @ 210, 10 SPLITTER oSplit SIZE 4, 260 ;
         DIVIDE {oTree} FROM {oSay} ;
         ON SIZE {|o,x,y|o:Move(,,,y-20)}

   oSplit:bEndDrag := {||hwg_Redrawwindow( oSay:handle,RDW_ERASE+RDW_INVALIDATE+RDW_INTERNALPAINT+RDW_UPDATENOW)}

   ACTIVATE DIALOG oDlg NOMODAL

RETURN NIL

Function BuildTree( oParent,aItems,oSay )
Local oNode, i, j, alen := Len(aItems), cText

   FOR i := 1 TO alen
      IF hb_IsChar(aItems[i])
         IF ( cText := Utf82Ansi( aItems[i] ) ) != NIL
            oParent:cargo += Chr(13)+Chr(10)+cText
         ELSE
            oParent:cargo += Chr(13)+Chr(10)+aItems[i]
         ENDIF
      ELSE
         INSERT NODE oNode CAPTION aItems[i]:title TO oParent ON CLICK {|o|NodeOut(o,oSay)}
         oNode:cargo := ""
         FOR j := 1 TO Len(aItems[i]:aAttr)
            IF ( cText := Utf82Ansi( aItems[i]:aAttr[j, 2] ) ) != NIL
               oNode:cargo += aItems[i]:aAttr[j, 1]+" = "+cText+Chr(13)+Chr(10)
            ELSE
               oNode:cargo += aItems[i]:aAttr[j, 1]+" = "+aItems[i]:aAttr[j, 2]+Chr(13)+Chr(10)
            ENDIF
         NEXT
         IF !Empty(aItems[i]:aItems)
            BuildTree( oNode,aItems[i]:aItems,oSay )
         ENDIF
      ENDIF
   NEXT

RETURN NIL

Static Function NodeOut( o,oSay )

   IF o == NIL
      oSay:SetText("")
   ELSE
      oSay:SetText(o:cargo)
   ENDIF

RETURN NIL

#pragma BEGINDUMP

#include <hbapi.hpp>
#include "hbapiitm.h"
#include "hbvm.h"
#include "hbstack.h"
#include "item.api"


#ifdef OS_UNIX_COMPATIBLE

#include <iconv.h>

static iconv_t it_koi2utf = NULL;
static iconv_t it_utf2koi = NULL;
static iconv_t it_8662utf = NULL;
static iconv_t it_utf2866 = NULL;

static char * utfConvert( char * psz1, short int b2Utf, short int bKoi )
{
   char * psz2, * ptr;
   char * codePage = (bKoi)? "KOI8-R" : "CP866";
   iconv_t it;
   int nLen1 = strlen( psz1 );
   int nLen2, nLen;

   if( b2Utf )
   {
      it = (bKoi)? it_koi2utf : it_8662utf;
      if( !it )
      {
         if( bKoi )
            it = it_koi2utf = iconv_open("UTF-8", codePage);
         else
            it = it_8662utf = iconv_open("UTF-8", codePage);
      }
      if( it == (iconv_t)-1 )
      {
         psz2 = ( char * ) hb_xgrab( nLen1+1 );
         memcpy( psz2, psz1, nLen1+1 );
         return psz2;
      }
      nLen2 = nLen1 * 3;
      nLen = nLen2;
      psz2 = ( char * ) hb_xgrab( nLen2+1 );
      ptr = psz2;
      iconv( it, &psz1, &nLen1, &ptr, &nLen );
      nLen2 -= nLen;
      psz2 = (char*) hb_xrealloc( psz2, nLen2+1 );
      psz2[nLen2] = 0;
   }
   else
   {
      it = (bKoi)? it_utf2koi : it_utf2866;
      if( !it )
         it = it_utf2koi = iconv_open(codePage, "UTF-8");
      else
         it = it_utf2866 = iconv_open(codePage, "UTF-8");
      if( it == (iconv_t)-1 )
      {
         psz2 = ( char * ) hb_xgrab( nLen1+1 );
         memcpy( psz2, psz1, nLen1+1 );
         return psz2;
      }
      nLen = nLen2 = nLen1;
      ptr = psz2 = ( char * ) hb_xgrab( nLen2+1 );
      iconv( it, &psz1, &nLen1, &ptr, &nLen );
      nLen2 -= nLen;
      psz2 = (char*) hb_xrealloc( psz2, nLen2+1 );
      psz2[nLen2] = 0;
   }

   return psz2;
}

#else

#include <windows.h>

static char * utfConvert( const char * psz1, short int b2Utf, short int bAnsi )
{
   LPWSTR pszUni;
   UINT codePage = (bAnsi)? CP_ACP : CP_OEMCP;
   int nUniLen = MultiByteToWideChar( (b2Utf)? codePage:CP_UTF8, 0, psz1, -1, NULL, 0 );
   char * psz2;
   int nLen2;

   pszUni = ( LPWSTR ) malloc( nUniLen*2 );
   MultiByteToWideChar( (b2Utf)? codePage:CP_UTF8, 0, psz1, -1, pszUni, nUniLen );

   nLen2 = WideCharToMultiByte( (b2Utf)? CP_UTF8:codePage, 0, pszUni, -1, NULL, 0, NULL, NULL );
   psz2 = ( char * ) hb_xgrab( nLen2 );
   WideCharToMultiByte( (b2Utf)? CP_UTF8:codePage, 0, pszUni, -1, (LPSTR)psz2, nLen2, NULL, NULL );

   free( pszUni );
   return psz2;
}

#endif

HB_FUNC( ANSI2UTF8 )
{
   char * pszUtf = utfConvert( hb_parc(1), 1, 1 );
   hb_retc_buffer( pszUtf );

}

HB_FUNC( UTF82ANSI )
{
   char * pszAnsi = utfConvert( hb_parc(1), 0, 1 );
   if( pszAnsi )
      hb_retc_buffer( pszAnsi );
   else
      hb_ret();

}

HB_FUNC( OEM2UTF8 )
{
   char * pszUtf = utfConvert( hb_parc(1), 1, 0 );
   hb_retc_buffer( pszUtf );

}

HB_FUNC( UTF82OEM )
{
   char * pszAnsi = utfConvert( hb_parc(1), 0, 0 );
   hb_retc_buffer( pszAnsi );

}

HB_FUNC( ICONV_CLOSE )
{
#ifdef OS_UNIX_COMPATIBLE
   if( it_koi2utf )
      iconv_close(it_koi2utf);
   if( it_utf2koi )
      iconv_close(it_utf2koi);
   if( it_8662utf )
      iconv_close(it_8662utf);
   if( it_utf2866 )
      iconv_close(it_utf2866);
#endif
}

#pragma ENDDUMP
