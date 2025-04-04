#ifndef HWINGUI_HPP
#define HWINGUI_HPP

#define HB_OS_WIN_32_USED

#ifndef _WIN32_WINNT
   #define _WIN32_WINNT   0x0502
#endif
#ifndef _WIN32_IE
   #define _WIN32_IE      0x0501
#endif
#ifndef WINVER
/* Ticket #67 */
   /* #define WINVER  0x0500 */
    #define WINVER  0x0502
#endif

#include <windows.h>
#include "guilib.hpp"

#if ((defined(_MSC_VER)&&(_MSC_VER<1300)&&!defined(__POCC__)) || defined(__WATCOMC__)|| defined(__DMC__))
   /* DF7BE:
      Open Watcom: Macro IS_INTRESOURCE now defined in: H\NT\winuser.h
    */
   #if !defined(__WATCOMC__)
   #define IS_INTRESOURCE(_r) ((((ULONG_PTR)(_r)) >> 16) == 0)
   #endif
   #if (defined(_MSC_VER)&&(_MSC_VER<1300)||defined(__DMC__))
      #define GetWindowLongPtr    GetWindowLong
      #define SetWindowLongPtr    SetWindowLong
      #define DWORD_PTR           DWORD
      #define LONG_PTR            LONG
      #define ULONG_PTR           ULONG
      #define GWLP_WNDPROC        GWL_WNDPROC
      #define GWLP_USERDATA       GWL_USERDATA
      #define DWLP_MSGRESULT      DWL_MSGRESULT
   #endif
#endif

#include "hbwinuni.h"

HB_EXTERN_BEGIN

extern void hwg_writelog( const char * sFile, const char * sTraceMsg, ... );

extern PHB_ITEM GetObjectVar(PHB_ITEM pObject, const char * varname);
extern void SetObjectVar(PHB_ITEM pObject, const char * varname, PHB_ITEM pValue);

extern void SetWindowObject( HWND hWnd, PHB_ITEM pObject );
extern PHB_ITEM Rect2Array( RECT * rc );
extern BOOL Array2Rect( PHB_ITEM aRect, RECT * rc );

extern HWND MDIFrameWindow;
extern HWND MDIClientWindow;
extern HWND *aDialogs;
extern int iDialogs;
extern HMODULE hModule;
extern PHB_DYNS pSym_onEvent;

HB_EXTERN_END

#define GETOBJECTVAR(obj, var)        hb_objSendMsg(obj, var, 0)
#define SETOBJECTVAR(obj, var, val)   hb_objSendMsg(obj, var, 1, val)

#endif // HWINGUI_HPP
