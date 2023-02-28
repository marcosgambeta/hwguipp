/*
 * Harbour Project source code:
 * Registry functions for Harbour
 *
 * Copyright 2001-2002 Luiz Rafael Culik<culikr@uol.com.br>
 * www - http://www.harbour-project.org
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include "hwingui.hpp"
#include <shlobj.h>
#include <hbvm.hpp>
#include <hbstack.hpp>
#include <hbapiitm.hpp>
#include <winreg.h>

HB_FUNC( HWG_REGCLOSEKEY )
{
   HKEY hwHandle = static_cast<HKEY>(hb_parnl(1));

   if( RegCloseKey(hwHandle) == ERROR_SUCCESS )
   {
      hb_retnl(ERROR_SUCCESS);
   }
   else
   {
      hb_retnl(-1);
   }
}

HB_FUNC( HWG_REGOPENKEYEX )
{
   HKEY hwKey = static_cast<HKEY>(hb_parnl(1));
   void * hValue;
   LPCTSTR lpValue = HB_PARSTRDEF(2, &hValue, nullptr);
   HKEY phwHandle;

   LONG lError = RegOpenKeyEx(static_cast<HKEY>(hwKey), lpValue, 0, KEY_ALL_ACCESS, &phwHandle);

   if( lError > 0 )
   {
      hb_retni(-1);
   }
   else
   {
      hb_stornl(PtrToLong(phwHandle), 5);
      hb_retni(0);
   }

   hb_strfree(hValue);
}

HB_FUNC( HWG_REGQUERYVALUEEX )
{
   HKEY hwKey = static_cast<HKEY>(hb_parnl(1));
   DWORD lpType = hb_parnl(4);
   DWORD lpcbData = 0;
   void * hValue;
   LPCTSTR lpValue = HB_PARSTRDEF(2, &hValue, nullptr);

   LONG lError = RegQueryValueEx(hwKey, lpValue, nullptr, &lpType, nullptr, &lpcbData);

   if( lError == ERROR_SUCCESS )
   {
      BYTE * lpData = static_cast<BYTE*>(memset(hb_xgrab(lpcbData + 1), 0, lpcbData + 1));
      lError = RegQueryValueEx(hwKey, lpValue, nullptr, &lpType, lpData, &lpcbData);
      if( lError > 0 )
      {
         hb_retni(-1);
      }
      else
      {
         hb_storc(static_cast<char*>(lpData), 5);
         hb_retni(0);
      }

      hb_xfree(lpData);
   }

   hb_strfree(hValue);
}

/*
RegEnumKeyEx(nKey, nPar2, cBuffer, nBuffSize, NIL, cClass, nClass) --> numeric
*/
HB_FUNC( HWG_REGENUMKEYEX )
{
   FILETIME ft;
   TCHAR Buffer[255];
   DWORD dwBuffSize = 255;
   TCHAR Class[255];
   DWORD dwClass = 255;

   long nErr = RegEnumKeyEx(static_cast<HKEY>(hb_parnl(1)), hb_parnl(2), Buffer, &dwBuffSize, nullptr, Class, &dwClass, &ft);

   if( nErr == ERROR_SUCCESS )
   {
      HB_STORSTR(Buffer, 3);
      hb_stornl(static_cast<long>(dwBuffSize), 4);
      HB_STORSTR(Class, 6);
      hb_stornl(static_cast<long>(dwClass), 7);
   }

   hb_retnl(nErr);
}

/*
RegSetValueEx(nKey, cValue, 0, nPar4, cPar5) --> numeric
*/
HB_FUNC( HWG_REGSETVALUEEX )
{
   void * hValue;

   hb_retnl(RegSetValueEx(static_cast<HKEY>(hb_parnl(1)), HB_PARSTRDEF(2, &hValue, nullptr), 0, hb_parnl(4), static_cast<const BYTE*>(hb_parcx(5)), hb_parclen(5) + 1));

   hb_strfree(hValue);
}

/*
RegCreateKey(nKey, cValue, nPar3) --> numeric
*/
HB_FUNC( HWG_REGCREATEKEY )
{
   HKEY hKey;
   void * hValue;

   LONG nErr = RegCreateKey(static_cast<HKEY>(hb_parnl(1)), HB_PARSTRDEF(2, &hValue, nullptr), &hKey);

   if( nErr == ERROR_SUCCESS )
   {
      hb_stornl(PtrToLong(hKey), 3);
   }

   hb_retnl(nErr);
   hb_strfree(hValue);
}

/*
RegCreateKeyEx(nKey, cSubKey, NIL, cClass, nOptions, nSamDesired, cSecurityAttributes, nHkResult, nDisposition) --> numeric
*/
HB_FUNC( HWG_REGCREATEKEYEX )
{
   HKEY hkResult;
   DWORD dwDisposition;
   SECURITY_ATTRIBUTES * sa = nullptr;
   void * hValue, * hClass;

   if( HB_ISCHAR(7) )
   {
      sa = static_cast<SECURITY_ATTRIBUTES*>(hb_parc(7));
   }

   LONG nErr = RegCreateKeyEx(static_cast<HKEY>(hb_parnl(1)),
                              HB_PARSTRDEF(2, &hValue, nullptr),
                              static_cast<DWORD>(0),
                              static_cast<LPTSTR>(HB_PARSTRDEF(4, &hClass, nullptr)),
                              hwg_par_DWORD(5),
                              hwg_par_DWORD(6),
                              sa,
                              &hkResult,
                              &dwDisposition);

   if( nErr == ERROR_SUCCESS )
   {
      hb_stornl(static_cast<LONG>(hkResult), 8);
      hb_stornl(static_cast<LONG>(dwDisposition), 9);
   }

   hb_retnl(nErr);
   hb_strfree(hValue);
   hb_strfree(hClass);
}

/*
RegDeleteKey(nKey, cValue) --> numeric
*/
HB_FUNC( HWG_REGDELETEKEY )
{
   void * hValue;
   hb_retni(RegDeleteKey(static_cast<HKEY>(hb_parnl(1)), HB_PARSTRDEF(2, &hValue, nullptr)) == ERROR_SUCCESS ? 0 : -1);
   hb_strfree(hValue);
}

// TODO: conferir funcionamento da função
// For strange reasons this function is not working properly
// May be I am missing something. Pritpal Bedi.

/*
RegDeleteValue(nKey, cValue) --> numeric
*/
HB_FUNC( HWG_REGDELETEVALUE )
{
   void * hValue;
   hb_retni(RegDeleteValue(static_cast<HKEY>(hb_parnl(1)), HB_PARSTRDEF(2, &hValue, nullptr)) == ERROR_SUCCESS ? 0 : -1);
   hb_strfree(hValue);
}
