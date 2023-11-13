#ifndef GUILIB_H_
#define GUILIB_H_

#include <hbapi.hpp>

#define WND_DLG_RESOURCE      10
#define WND_DLG_NORESOURCE    11
#define ST_ALIGN_HORIZ        0     // Icon/bitmap on the left, text on the right
#define ST_ALIGN_VERT         1     // Icon/bitmap on the top, text on the bottom
#define ST_ALIGN_HORIZ_RIGHT  2     // Icon/bitmap on the right, text on the left
#define ST_ALIGN_OVERLAP      3     // Icon/bitmap on the same space as text

#define HB_RETHANDLE( h )        hb_retptr( ( void * ) ( h ) ) // deprecated
#define HB_PARHANDLE( n )        hb_parptr( n ) // deprecated
#define HB_STOREHANDLE( h, n )   hb_storptr( ( void * ) ( h ), n )
#define HB_PUTHANDLE( i, h )     hb_itemPutPtr( i, ( void * ) ( h ) )
#define HB_GETHANDLE( i )        hb_itemGetPtr( i )
#define HB_GETPTRHANDLE( i ,n )  hb_arrayGetPtr( i , n )
#define HB_PUSHITEM( i )         hb_vmPushPointer( ( void * )i )

#ifndef HB_SIZEOFARRAY
   #define HB_SIZEOFARRAY( var )    ( sizeof( var ) / sizeof( *var ) )
#endif

#ifndef HB_PATH_MAX
   #define HB_PATH_MAX 264
#endif

#if !defined( FHANDLE ) && ( __HARBOUR__ - 0 < 0x020000 )
   typedef FHANDLE HB_FHANDLE;
#endif
#if defined( __XHARBOUR__ ) || ( __HARBOUR__ - 0 < 0x020000 )
   #define hb_storvni      hb_storni

   #define HB_LONG         LONG
   #define HB_ULONG        ULONG

   typedef unsigned char   HB_BYTE;
   typedef int             HB_BOOL;
   typedef unsigned short  HB_USHORT;
   //typedef ULONG           HB_SIZE;
   #if defined( HB_OS_WIN_64 )
#  if defined( HB_SIZE_SIGNED )
      typedef LONGLONG         HB_SIZE;
#  else
      typedef ULONGLONG        HB_SIZE;       
#  endif
 
#else
#  if defined( HB_SIZE_SIGNED )
      typedef LONG             HB_SIZE;
#  else
      typedef ULONG            HB_SIZE;       
#  endif
 
#endif
#endif

#if !defined( HB_FALSE )
   #define HB_FALSE      0
#endif
#if !defined( HB_TRUE )
   #define HB_TRUE       (!0)
#endif
#if !defined( HB_ISNIL )
   #define HB_ISNIL( n )         ISNIL( n )
   #define HB_ISCHAR( n )        ISCHAR( n )
   #define HB_ISNUM( n )         ISNUM( n )
   #define HB_ISLOG( n )         ISLOG( n )
   #define HB_ISDATE( n )        ISDATE( n )
   #define HB_ISMEMO( n )        ISMEMO( n )
   #define HB_ISBYREF( n )       ISBYREF( n )
   #define HB_ISARRAY( n )       ISARRAY( n )
   #define HB_ISOBJECT( n )      ISOBJECT( n )
   #define HB_ISBLOCK( n )       ISBLOCK( n )
   #define HB_ISPOINTER( n )     ISPOINTER( n )
   #define HB_ISHASH( n )        ISHASH( n )
   #define HB_ISSYMBOL( n )      ISSYMBOL( n )
#endif

#if defined( __XHARBOUR__ ) && !defined( hb_itemPutCLPtr )
   #define hb_dynsymIsFunction( h ) ( ( h )->pSymbol->value.pFunPtr != NULL )
   #define hb_itemPutCLPtr( pItem, szText, ulLen ) hb_itemPutCPtr( pItem, szText, ulLen )
#endif
#endif

// macros for parameters /* TODO: remover casts desnecessários) */
#define hwg_par_HWND(n) static_cast<HWND>(hb_parptr(n))
#define hwg_par_WPARAM(n) static_cast<WPARAM>(hb_parni(n))
#define hwg_par_int(n) static_cast<int>(hb_parni(n))
#define hwg_par_LPARAM(n) static_cast<LPARAM>(hb_parnl(n))
#define hwg_par_HICON(n) static_cast<HICON>(hb_parptr(n))
#define hwg_par_HDC(n) static_cast<HDC>(hb_parptr(n))
#define hwg_par_HRGN(n) static_cast<HRGN>(hb_parptr(n))
#define hwg_par_HBRUSH(n) static_cast<HBRUSH>(hb_parptr(n))
#define hwg_par_HBITMAP(n) static_cast<HBITMAP>(hb_parptr(n))
#define hwg_par_HIMAGELIST(n) static_cast<HIMAGELIST>(hb_parptr(n))
#define hwg_par_UINT(n) static_cast<UINT>(hb_parni(n))
#define hwg_par_DWORD(n) static_cast<DWORD>(hb_parnl(n))
#define hwg_par_COLORREF(n) static_cast<COLORREF>(hb_parnl(n))
#define hwg_par_HMENU(n) static_cast<HMENU>(hb_parptr(n))
#define hwg_par_BYTE(n) static_cast<BYTE>(hb_parni(n))
#define hwg_par_UINT_PTR(n) static_cast<UINT_PTR>(hb_parni(n))
#define hwg_par_HGDIOBJ(n) static_cast<HGDIOBJ>(hb_parptr(n))
