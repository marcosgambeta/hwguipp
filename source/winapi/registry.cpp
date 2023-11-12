/*
 * HWGUI - Harbour Win32 GUI library source code:
 * Registry handling functions
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#define HB_OS_WIN_32_USED

#define _WIN32_WINNT 0x0400
#define OEMRESOURCE

#include <windows.h>
#include "guilib.hpp"
#include <hbapi.hpp>
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include <hbstack.hpp>
#include "incomp_pointer.hpp"
#include <hbwinuni.hpp>

/*
 * Regcreatekey(handle, cKeyName) --> handle
*/

HB_FUNC( HWG_REGCREATEKEY )
{
   void * str;
   HKEY hkResult = nullptr;
   DWORD dwDisposition;

   if( RegCreateKeyEx(reinterpret_cast<HKEY>(hb_parnl(1)), HB_PARSTR(2, &str, nullptr), 0, nullptr, 0, KEY_ALL_ACCESS, nullptr, &hkResult, &dwDisposition) == ERROR_SUCCESS ) {
      hb_retnl(reinterpret_cast<ULONG>(hkResult));
   } else {
      hb_retnl(-1);
   }
   hb_strfree(str);
}

/*
 * RegOpenKey(handle, cKeyName) --> handle
*/

HB_FUNC( HWG_REGOPENKEY )
{
   void * str;
   HKEY hkResult = nullptr;

   if( RegOpenKeyEx(reinterpret_cast<HKEY>(hb_parnl(1)), HB_PARSTR(2, &str, nullptr), 0, KEY_ALL_ACCESS, &hkResult) == ERROR_SUCCESS ) {
      hb_retnl(reinterpret_cast<ULONG>(hkResult));
   } else {
      hb_retnl(-1);
   }
   hb_strfree(str);
}

/*
 * RegCloseKey(handle)
*/

HB_FUNC( HWG_REGCLOSEKEY )
{
   RegCloseKey((HKEY)hb_parnl(1));
}

/*
 * RegSetString(handle, cKeyName, cKeyValue) --> 0 (Success) or -1 (Error)
*/

HB_FUNC( HWG_REGSETSTRING )
{
   void * str;

   if( RegSetValueEx(reinterpret_cast<HKEY>(hb_parnl(1)), HB_PARSTR(2, &str, nullptr), 0, REG_SZ, ( BYTE * ) hb_parc(3), hb_parclen(3) + 1) == ERROR_SUCCESS ) {
      hb_retnl(0);
   } else {
      hb_retnl(-1);
   }

   hb_strfree(str);
}

HB_FUNC( HWG_REGSETBINARY )
{
   void * str;

   if( RegSetValueEx(reinterpret_cast<HKEY>(hb_parnl(1)), HB_PARSTR(2, &str, nullptr), 0, REG_BINARY, ( BYTE * ) hb_parc(3), hb_parclen(3) + 1) == ERROR_SUCCESS )
   {
      hb_retnl(0);
   } else {
      hb_retnl(-1);
   }

   hb_strfree(str);
}

HB_FUNC( HWG_REGGETVALUE )
{
   auto hKey = reinterpret_cast<HKEY>(hb_parnl(1));
   LPTSTR lpValueName = ( LPTSTR ) hb_parc(2);
   DWORD lpType = 0;
   LPBYTE lpData;
   DWORD lpcbData;
   int length;

   if( RegQueryValueEx(hKey, lpValueName, nullptr, nullptr, nullptr, &lpcbData) == ERROR_SUCCESS ) {
      length = ( int ) lpcbData;
      lpData = static_cast<LPBYTE>(hb_xgrab(length + 1));
      if( RegQueryValueEx(hKey, lpValueName, nullptr, &lpType, lpData, &lpcbData) == ERROR_SUCCESS ) {
         hb_retclen(( char * ) lpData, (lpType == REG_SZ || lpType == REG_MULTI_SZ || lpType == REG_EXPAND_SZ) ? length - 1 : length);
         if( hb_pcount() > 2 ) {
            hb_stornl(static_cast<LONG>(lpType), 3);
         }
      } else {
         hb_ret();
      }
      hb_xfree(lpData);
   } else {
      hb_ret();
   }
}
