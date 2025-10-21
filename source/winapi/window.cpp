//
// HWGUI - Harbour Win32 GUI library source code:
// C level windows functions
//
// Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#define OEMRESOURCE

#include "hwingui.hpp"
#include <commctrl.h>
#include <hbapifs.hpp>
#include <hbapiitm.hpp>
#include <hbapicdp.hpp>
#include <hbvm.hpp>
#include <hbstack.hpp>
#include <hbapicls.hpp>
#include <math.h>
#include <float.h>
#include <limits.h>
// Avoid warnings from GCC
#include "warnings.hpp"
#include "incomp_pointer.hpp"

#define FIRST_MDICHILD_ID 501
#define WND_MDICHILD 3

static LRESULT CALLBACK s_MainWndProc(HWND, UINT, WPARAM, LPARAM);
static LRESULT CALLBACK s_FrameWndProc(HWND, UINT, WPARAM, LPARAM);
static LRESULT CALLBACK s_MDIChildWndProc(HWND, UINT, WPARAM, LPARAM);

static HHOOK s_KeybHook = nullptr;
HWND MDIFrameWindow = nullptr;
HWND MDIClientWindow = nullptr;
PHB_DYNS pSym_onEvent = nullptr;
PHB_DYNS pSym_keylist = nullptr;
static LPCTSTR s_szChild = TEXT("MDICHILD");

void hwg_doEvents(void)
{
  MSG msg;

  while (PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  };
}

static void s_ClearKeyboard(void)
{
  MSG msg;

  // For keyboard
  while (PeekMessage(&msg, nullptr, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE))
    ;
  // For Mouse
  while (PeekMessage(&msg, nullptr, WM_MOUSEFIRST, WM_MOUSELAST, PM_REMOVE))
    ;
}

// Consume all queued events, useful to update all the controls... I split in 2 parts because I feel
// that s_doEvents should be called internally by some other functions...

// HWG_DOEVENTS() --> NIL
HB_FUNC(HWG_DOEVENTS)
{
  hwg_doEvents();
}

// Creates main application window
// InitMainWindow(pObject, szAppName, cTitle, cMenu, hIcon, nBkColor, nStyle, nExclude, nLeft, nTop, nWidth, nHeight)

// HWG_INITMAINWINDOW() --> HWND
HB_FUNC(HWG_INITMAINWINDOW)
{
  HWND hWnd = nullptr;
  WNDCLASS wndclass;
  HANDLE hInstance = GetModuleHandle(nullptr);
  DWORD ExStyle = 0;
  auto pObject = hb_param(1, Harbour::Item::OBJECT);
  void *hAppName, *hTitle, *hMenu;
  LPCTSTR lpAppName = HB_PARSTR(2, &hAppName, nullptr);
  LPCTSTR lpTitle = HB_PARSTR(3, &hTitle, nullptr);
  LPCTSTR lpMenu = HB_PARSTR(4, &hMenu, nullptr);
  LONG nStyle = hb_parnl(7);
  LONG nExcl = hb_parnl(8);
  auto x = hb_parni(9);
  auto y = hb_parni(10);
  auto width = hb_parni(11);
  auto height = hb_parni(12);

  if (MDIFrameWindow == nullptr) {
    wndclass.style = CS_OWNDC | CS_VREDRAW | CS_HREDRAW | CS_DBLCLKS;
    wndclass.lpfnWndProc = s_MainWndProc;
    wndclass.cbClsExtra = 0;
    wndclass.cbWndExtra = 0;
    wndclass.hInstance = static_cast<HINSTANCE>(hInstance);
    wndclass.hIcon =
        (hb_pcount() > 4 && !HB_ISNIL(5)) ? hwg_par_HICON(5) : LoadIcon(static_cast<HINSTANCE>(hInstance), TEXT(""));
    wndclass.hCursor = LoadCursor(nullptr, IDC_ARROW);
    wndclass.hbrBackground =
        (hb_pcount() > 5 && !HB_ISNIL(6))
            ? ((hb_parnl(6) == -1) ? nullptr
                                   : (HB_ISPOINTER(6) ? hwg_par_HBRUSH(6) : reinterpret_cast<HBRUSH>(hb_parnl(6))))
            : reinterpret_cast<HBRUSH>(COLOR_WINDOW + 1); // TODO: é realmente preciso checar o tipo ?
    wndclass.lpszMenuName = lpMenu;
    wndclass.lpszClassName = lpAppName;

    if (RegisterClass(&wndclass)) {
      nStyle = (WS_OVERLAPPEDWINDOW & ~nExcl) | nStyle;
      hWnd =
          CreateWindowEx(ExStyle, lpAppName, lpTitle, nStyle, x, y, (!width) ? static_cast<LONG>(CW_USEDEFAULT) : width,
                         (!height) ? static_cast<LONG>(CW_USEDEFAULT) : height, nullptr, nullptr,
                         static_cast<HINSTANCE>(hInstance), nullptr);

      hb_objDataPutNL(pObject, "_NHOLDER", 1);
      SetWindowObject(hWnd, pObject);

      MDIFrameWindow = hWnd;
    }
  }
  hb_strfree(hAppName);
  hb_strfree(hTitle);
  hb_strfree(hMenu);

  hb_retptr(hWnd);
}

// HWG_CENTERWINDOW(HWND, np2) --> NIL
HB_FUNC(HWG_CENTERWINDOW)
{
  RECT rect, rectcli;
  int w, h, x, y;

  GetWindowRect(hwg_par_HWND(1), &rect);

  if (hb_parni(2) == WND_MDICHILD) {
    GetWindowRect(static_cast<HWND>(MDIClientWindow), &rectcli);
    x = rectcli.right - rectcli.left;
    y = rectcli.bottom - rectcli.top;
    w = rect.right - rect.left;
    h = rect.bottom - rect.top;
  } else {
    w = rect.right - rect.left;
    h = rect.bottom - rect.top;
    x = GetSystemMetrics(SM_CXSCREEN);
    y = GetSystemMetrics(SM_CYSCREEN);
  }

  SetWindowPos(hwg_par_HWND(1), HWND_TOP, (x - w) / 2, (y - h) / 2, 0, 0,
               SWP_NOSIZE + SWP_NOACTIVATE + SWP_FRAMECHANGED + SWP_NOSENDCHANGING);
}

void ProcessMessage(MSG msg, HACCEL hAcceler, BOOL lMdi)
{
  int i;
  HWND hwndGoto;

  for (i = 0; i < iDialogs; i++) {
    hwndGoto = aDialogs[i];
    if (IsWindow(hwndGoto) && IsDialogMessage(hwndGoto, &msg)) {
      break;
    }
  }

  if (i == iDialogs) {
    if (lMdi && TranslateMDISysAccel(MDIClientWindow, &msg)) {
      return;
    }

    if (!hAcceler || !TranslateAccelerator(MDIFrameWindow, hAcceler, &msg)) {
      TranslateMessage(&msg);
      DispatchMessage(&msg);
    }
  }
}

void ProcessMdiMessage(HWND hJanBase, HWND hJanClient, MSG msg, HACCEL hAcceler)
{
  if (!TranslateMDISysAccel(hJanClient, &msg) && !TranslateAccelerator(hJanBase, hAcceler, &msg)) {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }
}

void hwg_ActivateMainWindow(BOOL bShow, HACCEL hAcceler, BOOL bMaximize, BOOL bMinimize)
{
  MSG msg;

  if (bShow) {
    ShowWindow(MDIFrameWindow, bMaximize ? SW_SHOWMAXIMIZED : (bMinimize ? SW_SHOWMINIMIZED : SW_SHOWNORMAL));
  }

  while (GetMessage(&msg, nullptr, 0, 0)) {
    ProcessMessage(msg, hAcceler, 0);
  }
}

// HWG_ACTIVATEMAINWINDOW(lShow, hAccel|NIL, lMaximize, lMinimize) --> NIL
HB_FUNC(HWG_ACTIVATEMAINWINDOW)
{
  hwg_ActivateMainWindow(hb_parl(1), (HB_ISNIL(2) ? nullptr : static_cast<HACCEL>(hb_parptr(2))),
                         ((HB_ISLOG(3) && hb_parl(3)) ? 1 : 0), ((HB_ISLOG(4) && hb_parl(4)) ? 1 : 0));
}

// HWG_PROCESSMESSAGE(lMdi|NIL, nSleep|NIL) --> .T.|.F.
HB_FUNC(HWG_PROCESSMESSAGE)
{
  MSG msg;
  BOOL lMdi = (HB_ISNIL(1)) ? 0 : hb_parl(1);
  int nSleep = (HB_ISNIL(2)) ? 1 : hb_parni(2);

  if (PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
    ProcessMessage(msg, 0, lMdi);
    hb_retl(true);
  } else {
    hb_retl(false);
  }

  SleepEx(nSleep, TRUE);
}

// 22/09/2005 - <maurilio.longo@libero.it>
//    It can be used to see if there are messages awaiting of a certain
//    type, but it does not retrieve them

// HWG_PEEKMESSAGE(hWnd, wMsgFilterMin, wMsgFilterMax) --> .T.|.F.
HB_FUNC(HWG_PEEKMESSAGE)
{
  MSG msg;
  hb_retl(PeekMessage(&msg, hwg_par_HWND(1), hwg_par_UINT(2), hwg_par_UINT(3), PM_NOREMOVE));
}

// HWG_INITCHILDWINDOW() --> HWND
HB_FUNC(HWG_INITCHILDWINDOW)
{
  HWND hWnd = nullptr;
  WNDCLASS wndclass;
  HMODULE /*HANDLE*/ hInstance = GetModuleHandle(nullptr);
  auto pObject = hb_param(1, Harbour::Item::OBJECT);
  void *hAppName, *hTitle, *hMenu;
  LPCTSTR lpAppName = HB_PARSTR(2, &hAppName, nullptr);
  LPCTSTR lpTitle = HB_PARSTR(3, &hTitle, nullptr);
  LPCTSTR lpMenu = HB_PARSTR(4, &hMenu, nullptr);
  LONG nStyle = hb_parnl(7);
  auto x = hb_parni(8);
  auto y = hb_parni(9);
  auto width = hb_parni(10);
  auto height = hb_parni(11);
  auto hParent = hwg_par_HWND(12);
  BOOL fRegistered = TRUE;

  if (!GetClassInfo(hInstance, lpAppName, &wndclass)) {
    wndclass.style = CS_OWNDC | CS_VREDRAW | CS_HREDRAW | CS_DBLCLKS;
    wndclass.lpfnWndProc = s_MainWndProc;
    wndclass.cbClsExtra = 0;
    wndclass.cbWndExtra = 0;
    wndclass.hInstance = static_cast<HINSTANCE>(hInstance);
    wndclass.hIcon =
        (hb_pcount() > 4 && !HB_ISNIL(5)) ? hwg_par_HICON(5) : LoadIcon(static_cast<HINSTANCE>(hInstance), TEXT(""));
    wndclass.hCursor = LoadCursor(nullptr, IDC_ARROW);
    wndclass.hbrBackground = (((hb_pcount() > 5 && !HB_ISNIL(6)) ? ((hb_parnl(6) == -1) ? nullptr : hwg_par_HBRUSH(6))
                                                                 : reinterpret_cast<HBRUSH>(COLOR_WINDOW + 1)));
#if 0
       wndclass.hbrBackground = (((hb_pcount() > 5 && !HB_ISNIL(6)) ?
       ((hb_parnl(6) == -1) ? static_cast<HBRUSH>(COLOR_WINDOW + 1) :
       CreateSolidBrush(hb_parnl(6)))
       : static_cast<HBRUSH>(COLOR_WINDOW + 1)));
#endif
    wndclass.lpszMenuName = lpMenu;
    wndclass.lpszClassName = lpAppName;

    // UnregisterClass(lpAppName, (HINSTANCE)hInstance);
    if (!RegisterClass(&wndclass)) {
      fRegistered = FALSE;
#ifdef __XHARBOUR__
      MessageBox(GetActiveWindow(), lpAppName, TEXT("Register Child Wnd Class"), MB_OK | MB_ICONSTOP);
#endif
    }
  }

  if (fRegistered) {
    hWnd = CreateWindowEx(WS_EX_MDICHILD, lpAppName, lpTitle, WS_OVERLAPPEDWINDOW | nStyle, x, y,
                          (!width) ? static_cast<LONG>(CW_USEDEFAULT) : width,
                          (!height) ? static_cast<LONG>(CW_USEDEFAULT) : height, hParent, nullptr,
                          static_cast<HINSTANCE>(hInstance), nullptr);

    hb_objDataPutNL(pObject, "_NHOLDER", 1);
    SetWindowObject(hWnd, pObject);
  }

  hb_retptr(hWnd);

  hb_strfree(hAppName);
  hb_strfree(hTitle);
  hb_strfree(hMenu);
}

// HWG_ACTIVATECHILDWINDOW() --> NIL
HB_FUNC(HWG_ACTIVATECHILDWINDOW)
{
  // ShowWindow(hwg_par_HWND(2), hb_parl(1) ? SW_SHOWNORMAL : SW_HIDE);
  ShowWindow(hwg_par_HWND(2), (HB_ISLOG(3) && hb_parl(3))
                                  ? SW_SHOWMAXIMIZED
                                  : ((HB_ISLOG(4) && hb_parl(4)) ? SW_SHOWMINIMIZED : SW_SHOWNORMAL));
}

// Creates frame MDI and client window
// InitMainWindow(cTitle, cMenu, cBitmap, hIcon, nBkColor, nStyle, nLeft, nTop, nWidth, nHeight)

// HWG_INITMDIWINDOW() --> HWND
HB_FUNC(HWG_INITMDIWINDOW)
{
  HWND hWnd;
  WNDCLASS wndclass, wc;
  HANDLE hInstance = GetModuleHandle(nullptr);
  auto pObject = hb_param(1, Harbour::Item::OBJECT);
  void *hAppName, *hTitle, *hMenu;
  LPCTSTR lpAppName = HB_PARSTR(2, &hAppName, nullptr);
  LPCTSTR lpTitle = HB_PARSTR(3, &hTitle, nullptr);
  LPCTSTR lpMenu = HB_PARSTR(4, &hMenu, nullptr);
  auto x = hb_parni(8);
  auto y = hb_parni(9);
  auto width = hb_parni(10);
  auto height = hb_parni(11);

  if (MDIFrameWindow != nullptr) {
    hb_retni(-1);
  } else {
    // Register frame window
    wndclass.style = 0;
    wndclass.lpfnWndProc = s_FrameWndProc;
    wndclass.cbClsExtra = 0;
    wndclass.cbWndExtra = 0;
    wndclass.hInstance = static_cast<HINSTANCE>(hInstance);
    wndclass.hIcon =
        (hb_pcount() > 4 && !HB_ISNIL(5)) ? hwg_par_HICON(5) : LoadIcon(static_cast<HINSTANCE>(hInstance), TEXT(""));
    wndclass.hCursor = LoadCursor(nullptr, IDC_ARROW);
    wndclass.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_WINDOW + 1);
    wndclass.lpszMenuName = lpMenu;
    wndclass.lpszClassName = lpAppName;

    if (!RegisterClass(&wndclass)) {
      hb_retni(-2);
    } else {
      // Register client window
      wc.lpfnWndProc = static_cast<WNDPROC>(s_MDIChildWndProc);
      wc.hIcon =
          (hb_pcount() > 4 && !HB_ISNIL(5)) ? hwg_par_HICON(5) : LoadIcon(static_cast<HINSTANCE>(hInstance), TEXT(""));
      // TODO: revisar linha abaixo
      wc.hbrBackground =
          (hb_pcount() > 5 && !HB_ISNIL(6)) ? hwg_par_HBRUSH(6) : reinterpret_cast<HBRUSH>(COLOR_WINDOW + 1);
      // wc.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_WINDOW + 1);
      wc.lpszMenuName = nullptr;
      wc.cbWndExtra = 0;
      wc.lpszClassName = s_szChild;
      wc.cbClsExtra = 0;
      wc.hInstance = static_cast<HINSTANCE>(hInstance);
      wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
      wc.style = 0;

      if (!RegisterClass(&wc)) {
        hb_retni(-3);
      } else {
        // Create frame window
        hWnd = CreateWindowEx(0, lpAppName, lpTitle, WS_OVERLAPPEDWINDOW, x, y,
                              (!width) ? static_cast<LONG>(CW_USEDEFAULT) : width,
                              (!height) ? static_cast<LONG>(CW_USEDEFAULT) : height, nullptr, nullptr,
                              static_cast<HINSTANCE>(hInstance), nullptr);
        if (!hWnd) {
          hb_retni(-4);
        } else {
          hb_objDataPutNL(pObject, "_NHOLDER", 1);
          SetWindowObject(hWnd, pObject);

          MDIFrameWindow = hWnd;
          hb_retptr(hWnd);
        }
      }
    }
  }
  hb_strfree(hAppName);
  hb_strfree(hTitle);
  hb_strfree(hMenu);
}

// HWG_INITCLIENTWINDOW(?, nPos, nX, nY, nWidth, nHeight) --> hWnd
HB_FUNC(HWG_INITCLIENTWINDOW)
{
  CLIENTCREATESTRUCT ccs;
  int nPos = (hb_pcount() > 1 && !HB_ISNIL(2)) ? hb_parni(2) : 0;

  // Create client window
  ccs.hWindowMenu = GetSubMenu(GetMenu(MDIFrameWindow), nPos);
  ccs.idFirstChild = FIRST_MDICHILD_ID;

  auto hWnd = CreateWindowEx(0, TEXT("MDICLIENT"), nullptr, WS_CHILD | WS_CLIPCHILDREN | MDIS_ALLCHILDSTYLES,
                             hwg_par_int(3), hwg_par_int(4), hwg_par_int(5), hwg_par_int(6), MDIFrameWindow, nullptr,
                             GetModuleHandle(nullptr), static_cast<LPVOID>(&ccs));

  MDIClientWindow = hWnd;
  hb_retptr(hWnd);
}

// HWG_ACTIVATEMDIWINDOW() --> NIL
HB_FUNC(HWG_ACTIVATEMDIWINDOW)
{
  HACCEL hAcceler = (HB_ISNIL(2)) ? nullptr : static_cast<HACCEL>(hb_parptr(2));
  MSG msg;

  if (hb_parl(1)) {
    ShowWindow(MDIFrameWindow, (HB_ISLOG(3) && hb_parl(3))
                                   ? SW_SHOWMAXIMIZED
                                   : ((HB_ISLOG(4) && hb_parl(4)) ? SW_SHOWMINIMIZED : SW_SHOWNORMAL));
    ShowWindow(MDIClientWindow, SW_SHOW);
  }

  while (GetMessage(&msg, nullptr, 0, 0)) {
    // ProcessMessage(msg, hAcceler, 0);
    ProcessMdiMessage(MDIFrameWindow, MDIClientWindow, msg, hAcceler);
  }
}

// Creates child MDI window
// CreateMdiChildWindow(aChildWindow)
// aChildWindow = {cWindowTitle, Nil, aActions, Nil, nStatusWindowID, bStatusWrite}
// aActions = {{nMenuItemID, bAction}, ...}

// HWG_CREATEMDICHILDWINDOW() --> HWND
HB_FUNC(HWG_CREATEMDICHILDWINDOW)
{
  HWND hWnd = nullptr;
  auto pObj = hb_param(1, Harbour::Item::OBJECT);
  auto style = static_cast<DWORD>(hb_objDataGetNL(pObj, "STYLE"));
  auto y = hb_objDataGetNI(pObj, "NTOP");
  auto x = hb_objDataGetNI(pObj, "NLEFT");
  auto width = hb_objDataGetNI(pObj, "NWIDTH");
  auto height = hb_objDataGetNI(pObj, "NHEIGHT");
  void *hTitle;
  LPCTSTR lpTitle = HB_ITEMGETSTR(GETOBJECTVAR(pObj, "TITLE"), &hTitle, nullptr);

  if (!style) {
    style = WS_VISIBLE | WS_CHILD | WS_OVERLAPPEDWINDOW | static_cast<int>(hb_parnl(2)); // WS_VISIBLE | WS_MAXIMIZE;
  } else {
    style = style | static_cast<int>(hb_parnl(2));
  }

  if (MDIFrameWindow != nullptr) {
    hWnd = CreateMDIWindow(
#if (((defined(_MSC_VER) && (_MSC_VER <= 1200))))
        static_cast<LPSTR>(s_szChild), // pointer to registered child class name
        static_cast<LPSTR>(lpTitle),   // pointer to window name
#else
        s_szChild, // pointer to registered child class name
        lpTitle,   // pointer to window name
#endif
        style,                              // window style
        x,                                  // horizontal position of window
        y,                                  // vertical position of window
        width,                              // width of window
        height,                             // height of window
        static_cast<HWND>(MDIClientWindow), // handle to parent window (MDI client)
        GetModuleHandle(nullptr),           // handle to application instance
        reinterpret_cast<LPARAM>(&pObj)     // application-defined value
    );
  }
  hb_retptr(hWnd);
  hb_strfree(hTitle);
}

// HWG_SENDMESSAGE() --> numeric
HB_FUNC(HWG_SENDMESSAGE)
{
  void *hText;
  LPCTSTR lpText = HB_PARSTR(4, &hText, nullptr);

  hb_retnl(static_cast<LONG>(
      SendMessage(hwg_par_HWND(1), // handle of destination window
                  hwg_par_UINT(2), // message to send
                  HB_ISPOINTER(3) ? reinterpret_cast<WPARAM>(hb_parptr(3)) : static_cast<WPARAM>(hb_parnl(3)),
                  lpText ? reinterpret_cast<LPARAM>(lpText)
                         : (HB_ISPOINTER(4) ? reinterpret_cast<LPARAM>(hb_parptr(4)) : hwg_par_LPARAM(4)))));
  hb_strfree(hText);
}

// HWG_SENDMESSPTR() --> handle
HB_FUNC(HWG_SENDMESSPTR)
{
  void *hText;
  LPCTSTR lpText = HB_PARSTR(4, &hText, nullptr);

  hb_retptr(reinterpret_cast<void *>(
      SendMessage(hwg_par_HWND(1), // handle of destination window
                  hwg_par_UINT(2), // message to send
                  HB_ISPOINTER(3) ? reinterpret_cast<WPARAM>(hb_parptr(3)) : static_cast<WPARAM>(hb_parnl(3)),
                  lpText ? reinterpret_cast<LPARAM>(lpText)
                         : (HB_ISPOINTER(4) ? reinterpret_cast<LPARAM>(hb_parptr(4)) : hwg_par_LPARAM(4)))));
  hb_strfree(hText);
}

// HWG_POSTMESSAGE() --> numeric
HB_FUNC(HWG_POSTMESSAGE)
{
  hb_retnl(static_cast<LONG>(
      PostMessage(hwg_par_HWND(1), // handle of destination window
                  hwg_par_UINT(2), // message to send
                  HB_ISPOINTER(3) ? reinterpret_cast<WPARAM>(hb_parptr(3)) : static_cast<WPARAM>(hb_parnl(3)),
                  HB_ISPOINTER(4) ? reinterpret_cast<LPARAM>(hb_parptr(4)) : hwg_par_LPARAM(4))));
}

// HWG_SETFOCUS(HWND) --> handle
HB_FUNC(HWG_SETFOCUS)
{
  hb_retptr(SetFocus(hwg_par_HWND(1)));
}

// HWG_GETFOCUS() --> handle
HB_FUNC(HWG_GETFOCUS)
{
  hb_retptr(GetFocus());
}

// HWG_SELFFOCUS(HWND1, HWND2|NIL) --> .T.|.F.
HB_FUNC(HWG_SELFFOCUS)
{
  HWND hWnd = HB_ISNIL(2) ? static_cast<HWND>(GetFocus()) : hwg_par_HWND(2);
  hb_retl(hwg_par_HWND(1) == hWnd);
}

// HWG_SETWINDOWOBJECT(HWND) --> NIL
HB_FUNC(HWG_SETWINDOWOBJECT)
{
  SetWindowObject(hwg_par_HWND(1), hb_param(2, Harbour::Item::OBJECT));
}

void SetWindowObject(HWND hWnd, PHB_ITEM pObject)
{
  SetWindowLongPtr(hWnd, GWLP_USERDATA, pObject ? reinterpret_cast<LPARAM>(hb_itemNew(pObject)) : 0);
}

// HWG_GETWINDOWOBJECT(HWND) --> item
HB_FUNC(HWG_GETWINDOWOBJECT)
{
  hb_itemReturn(reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hwg_par_HWND(1), GWLP_USERDATA)));
}

// HWG_SETWINDOWTEXT(HWND, cText) --> NIL
HB_FUNC(HWG_SETWINDOWTEXT)
{
  void *hText;
  SetWindowText(hwg_par_HWND(1), HB_PARSTR(2, &hText, nullptr));
  hb_strfree(hText);
}

// HWG_GETWINDOWTEXT(HWND) --> cText
HB_FUNC(HWG_GETWINDOWTEXT)
{
  auto hWnd = hwg_par_HWND(1);
  auto ulLen = static_cast<ULONG>(SendMessage(hWnd, WM_GETTEXTLENGTH, 0, 0));
  LPTSTR cText = static_cast<TCHAR *>(hb_xgrab((ulLen + 1) * sizeof(TCHAR)));
  ulLen = static_cast<ULONG>(
      SendMessage(hWnd, WM_GETTEXT, static_cast<WPARAM>(ulLen + 1), reinterpret_cast<LPARAM>(cText)));
  HB_RETSTRLEN(cText, ulLen);
  hb_xfree(cText);
}

// HWG_SETWINDOWFONT(HWND, p2, p3) --> NIL
HB_FUNC(HWG_SETWINDOWFONT)
{
  SendMessage(hwg_par_HWND(1), WM_SETFONT,
              HB_ISPOINTER(2) ? reinterpret_cast<WPARAM>(hb_parptr(2)) : static_cast<WPARAM>(hb_parnl(2)),
              MAKELPARAM(((HB_ISNIL(3)) ? 0 : hb_parl(3)), 0));
}

// HWG_GETLASTERROR() --> numeric
HB_FUNC(HWG_GETLASTERROR)
{
  hb_retnl(static_cast<LONG>(GetLastError()));
}

// HWG_ENABLEWINDOW(HWND) --> NIL
HB_FUNC(HWG_ENABLEWINDOW)
{
  // ShowWindow(hWnd, (lEnable) ? SW_SHOWNORMAL : SW_HIDE);
  EnableWindow(hwg_par_HWND(1), static_cast<BOOL>(hb_parl(2)));
}

// HWG_DESTROYWINDOW(HWND) --> NIL
HB_FUNC(HWG_DESTROYWINDOW)
{
  DestroyWindow(hwg_par_HWND(1));
}

// HWG_HIDEWINDOW(HWND) --> NIL
HB_FUNC(HWG_HIDEWINDOW)
{
  ShowWindow(hwg_par_HWND(1), SW_HIDE);
}

// HWG_SHOWWINDOW(HWND) --> NIL
HB_FUNC(HWG_SHOWWINDOW)
{
  ShowWindow(hwg_par_HWND(1), (HB_ISNIL(2)) ? SW_SHOW : hb_parni(2));
}

// HWG_RESTOREWINDOW(HWND) --> NIL
HB_FUNC(HWG_RESTOREWINDOW)
{
  ShowWindow(hwg_par_HWND(1), SW_RESTORE);
}

// HWG_ISICONIC(HWND) --> .T.|.F.
HB_FUNC(HWG_ISICONIC)
{
  hb_retl(IsIconic(hwg_par_HWND(1)));
}

// HWG_ISWINDOWENABLED(HWND) --> .T.|.F.
HB_FUNC(HWG_ISWINDOWENABLED)
{
  hb_retl(IsWindowEnabled(hwg_par_HWND(1)));
}

// HWG_ISWINDOWVISIBLE(HWND) --> .T.|.F.
HB_FUNC(HWG_ISWINDOWVISIBLE)
{
  hb_retl(IsWindowVisible(hwg_par_HWND(1)));
}

// HWG_GETACTIVEWINDOW() --> handle
HB_FUNC(HWG_GETACTIVEWINDOW)
{
  hb_retptr(GetActiveWindow());
}

// HWG_GETINSTANCE() --> numeric
HB_FUNC(HWG_GETINSTANCE)
{
  hb_retnl(reinterpret_cast<LONG>(GetModuleHandle(nullptr)));
}

// HWG_SETWINDOWSTYLE(HWND, np2) --> numeric
HB_FUNC(HWG_SETWINDOWSTYLE)
{
  hb_retnl(SetWindowLongPtr(hwg_par_HWND(1), GWL_STYLE, hb_parnl(2)));
}

// HWG_GETWINDOWSTYLE(HWND) --> numeric
HB_FUNC(HWG_GETWINDOWSTYLE)
{
  hb_retnl(GetWindowLongPtr(hwg_par_HWND(1), GWL_STYLE));
}

// HWG_SETWINDOWEXSTYLE(HWND, np2) --> numeric
HB_FUNC(HWG_SETWINDOWEXSTYLE)
{
  hb_retnl(SetWindowLongPtr(hwg_par_HWND(1), GWL_EXSTYLE, hb_parnl(2)));
}

// HWG_GETWINDOWEXSTYLE(HWND) --> numeric
HB_FUNC(HWG_GETWINDOWEXSTYLE)
{
  hb_retnl(GetWindowLongPtr(hwg_par_HWND(1), GWL_EXSTYLE));
}

// HWG_FINDWINDOW(cClassText, cWindowName) --> handle
HB_FUNC(HWG_FINDWINDOW)
{
  void *hClassName;
  void *hWindowName;
  hb_retptr(FindWindow(HB_PARSTR(1, &hClassName, nullptr), HB_PARSTR(2, &hWindowName, nullptr)));
  hb_strfree(hClassName);
  hb_strfree(hWindowName);
}

// HWG_SETFOREGROUNDWINDOW(HWND) --> .T.|.F.
HB_FUNC(HWG_SETFOREGROUNDWINDOW)
{
  hb_retl(SetForegroundWindow(hwg_par_HWND(1)));
}

#if 0
HB_FUNC( HWG_SETACTIVEWINDOW )
{
   hb_retnl(SetActiveWindow(hwg_par_HWND(1)));
}
#endif

// HWG_RESETWINDOWPOS(HWND) --> NIL
HB_FUNC(HWG_RESETWINDOWPOS)
{
  RECT rc;
  GetWindowRect(hwg_par_HWND(1), &rc);
  MoveWindow(hwg_par_HWND(1), rc.left, rc.top, rc.right - rc.left + 1, rc.bottom - rc.top, 0);
}

// s_MainWndProc alteradas na HWGUI. Agora as funcoes em hWindow.prg
// retornam 0 para indicar que deve ser usado o processamento default.
static LRESULT CALLBACK s_MainWndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
  auto pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

  if (!pSym_onEvent) {
    pSym_onEvent = hb_dynsymFindName("ONEVENT");
  }

  if (pSym_onEvent && pObject) {

    hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
    hb_vmPush(pObject);
    hb_vmPushLong(static_cast<LONG>(message));
    //      hb_vmPushLong(static_cast<LONG>(wParam));
    //      hb_vmPushLong(static_cast<LONG>(lParam));
    hb_vmPushPointer(reinterpret_cast<void *>(wParam));
    hb_vmPushPointer(reinterpret_cast<void *>(lParam));
    hb_vmSend(3);
    if (HB_ISPOINTER(-1)) {
      return reinterpret_cast<LRESULT>(hb_parptr(-1));
    } else {
      long int res = hb_parnl(-1);
      if (res == -1) {
        return DefWindowProc(hWnd, message, wParam, lParam);
      } else {
        return res;
      }
    }
  } else {
    return DefWindowProc(hWnd, message, wParam, lParam);
  }
}

static LRESULT CALLBACK s_FrameWndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
  auto pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

  if (!pSym_onEvent) {
    pSym_onEvent = hb_dynsymFindName("ONEVENT");
  }

  if (pSym_onEvent && pObject) {
    hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
    hb_vmPush(pObject);
    hb_vmPushLong(static_cast<LONG>(message));
    //      hb_vmPushLong(static_cast<LONG>(wParam));
    //      hb_vmPushLong(static_cast<LONG>(lParam));
    hb_vmPushPointer(reinterpret_cast<void *>(wParam));
    hb_vmPushPointer(reinterpret_cast<void *>(lParam));
    hb_vmSend(3);
    if (HB_ISPOINTER(-1)) {
      return reinterpret_cast<LRESULT>(hb_parptr(-1));
    } else {
      long int res = hb_parnl(-1);
      if (res == -1) {
        return DefFrameProc(hWnd, MDIClientWindow, message, wParam, lParam);
      } else {
        return res;
      }
    }
  } else {
    return DefFrameProc(hWnd, MDIClientWindow, message, wParam, lParam);
  }
}

static LRESULT CALLBACK s_MDIChildWndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
  if (message == WM_NCCREATE) {
    LPMDICREATESTRUCT cs = static_cast<LPMDICREATESTRUCT>((reinterpret_cast<LPCREATESTRUCT>(lParam))->lpCreateParams);
    PHB_ITEM *pObj = reinterpret_cast<PHB_ITEM *>(cs->lParam);
    hb_objDataPutNL(*pObj, "_NHOLDER", 1);
    hb_objDataPutPtr(*pObj, "_HANDLE", hWnd);
    SetWindowObject(hWnd, *pObj);
  }

  auto pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

  if (!pSym_onEvent) {
    pSym_onEvent = hb_dynsymFindName("ONEVENT");
  }

  if (pSym_onEvent && pObject) {
    hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
    hb_vmPush(pObject);
    hb_vmPushLong(static_cast<LONG>(message));
    //      hb_vmPushLong(static_cast<LONG>(wParam));
    //      hb_vmPushLong(static_cast<LONG>(lParam));
    hb_vmPushPointer(reinterpret_cast<void *>(wParam));
    hb_vmPushPointer(reinterpret_cast<void *>(lParam));
    hb_vmSend(3);
    if (HB_ISPOINTER(-1)) {
      return reinterpret_cast<LRESULT>(hb_parptr(-1));
    } else {
      long int res = hb_parnl(-1);
      if (res == -1) {
        return DefMDIChildProc(hWnd, message, wParam, lParam);
      } else {
        return res;
      }
    }
  } else {
    return DefMDIChildProc(hWnd, message, wParam, lParam);
  }
}

// DEPRECATED
// Call hb_objSendMsg directly or use the functions hb_objDataGet* or use the macro GETOBJECTVAR
PHB_ITEM GetObjectVar(PHB_ITEM pObject, const char *varname)
{
  return hb_objSendMsg(pObject, varname, 0);
}

// DEPRECATED
// Call hb_objSendMsg directly or use the functions hb_objDataPut* or use the macro SETOBJECTVAR
void SetObjectVar(PHB_ITEM pObject, const char *varname, PHB_ITEM pValue)
{
  hb_objSendMsg(pObject, varname, 1, pValue);
}

// HWG_SETUTF8() --> NIL
HB_FUNC(HWG_SETUTF8)
{
  PHB_CODEPAGE cdp = hb_cdpFindExt("UTF8");

  if (cdp) {
    hb_vmSetCDP(cdp);
  }
}

// HWG_EXITPROCESS() --> NIL
HB_FUNC(HWG_EXITPROCESS)
{
  ExitProcess(0);
}

// HWG_DECREASEHOLDERS(HWND) --> NIL
HB_FUNC(HWG_DECREASEHOLDERS)
{
#if 0
     auto pObject = hb_param(1, Harbour::Item::OBJECT);
#ifndef UIHOLDERS
     if( pObject->item.asArray.value->ulHolders )
        pObject->item.asArray.value->ulHolders--;
#else
     if( pObject->item.asArray.value->uiHolders )
        pObject->item.asArray.value->uiHolders--;
#endif
#endif
  auto hWnd = hwg_par_HWND(1);
  auto pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

  if (pObject) {
    hb_itemRelease(pObject);
    SetWindowLongPtr(hWnd, GWLP_USERDATA, 0);
  }
}

// HWG_SETTOPMOST(HWND) --> .T.|.F.
HB_FUNC(HWG_SETTOPMOST)
{
  hb_retl(SetWindowPos(hwg_par_HWND(1), HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE));
}

// HWG_REMOVETOPMOST(HWND) --> .T.|.F.
HB_FUNC(HWG_REMOVETOPMOST)
{
  hb_retl(SetWindowPos(hwg_par_HWND(1), HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE));
}

// HWG_CHILDWINDOWFROMPOINT(HWND, nX, nY) --> handle
HB_FUNC(HWG_CHILDWINDOWFROMPOINT)
{
  POINT pt;
  pt.x = hb_parnl(2);
  pt.y = hb_parnl(3);
  hb_retptr(ChildWindowFromPoint(hwg_par_HWND(1), pt));
}

// HWG_WINDOWFROMPOINT() --> handle
HB_FUNC(HWG_WINDOWFROMPOINT)
{
  POINT pt;
  pt.x = hb_parnl(2);
  pt.y = hb_parnl(3);
  ClientToScreen(hwg_par_HWND(1), &pt);
  hb_retptr(WindowFromPoint(pt));
}

// HWG_MAKEWPARAM(np1, np2) --> numeric
HB_FUNC(HWG_MAKEWPARAM)
{
  WPARAM p = MAKEWPARAM((static_cast<WORD>(hb_parnl(1))), (static_cast<WORD>(hb_parnl(2))));
  hb_retnl(static_cast<LONG>(p));
}

// HWG_MAKELPARAM(np1, np2) --> handle
HB_FUNC(HWG_MAKELPARAM)
{
  LPARAM p = MAKELPARAM((static_cast<WORD>(hb_parnl(1))), (static_cast<WORD>(hb_parnl(2))));
  hb_retptr(reinterpret_cast<void *>(p));
}

// HWG_SETWINDOWPOS(HWND|pWND, HWND2, nX, nY, nWidth, nHeight) --> .T.|.F.
HB_FUNC(HWG_SETWINDOWPOS)
{
  HWND hWnd = (HB_ISNUM(1) || HB_ISPOINTER(1)) ? hwg_par_HWND(1) : nullptr;
  HWND hWndInsertAfter = (HB_ISNUM(2) || HB_ISPOINTER(2)) ? hwg_par_HWND(2) : nullptr;
  auto x = hb_parni(3);
  auto y = hb_parni(4);
  auto cx = hb_parni(5);
  auto cy = hb_parni(6);
  UINT uFlags = hb_parni(7);
  hb_retl(SetWindowPos(hWnd, hWndInsertAfter, x, y, cx, cy, uFlags));
}

// HWG_SETASTYLE(np1, np2) --> NIL
HB_FUNC(HWG_SETASTYLE)
{
#define MAP_STYLE(src, dest)                                                                                           \
  if (dwStyle & (src))                                                                                                 \
  dwText |= (dest)
#define NMAP_STYLE(src, dest)                                                                                          \
  if (!(dwStyle & (src)))                                                                                              \
  dwText |= (dest)

  DWORD dwStyle = hb_parnl(1), dwText = 0;

  MAP_STYLE(SS_RIGHT, DT_RIGHT);
  MAP_STYLE(SS_CENTER, DT_CENTER);
  MAP_STYLE(SS_CENTERIMAGE, DT_VCENTER | DT_SINGLELINE);
  MAP_STYLE(SS_NOPREFIX, DT_NOPREFIX);
  MAP_STYLE(SS_WORDELLIPSIS, DT_WORD_ELLIPSIS);
  MAP_STYLE(SS_ENDELLIPSIS, DT_END_ELLIPSIS);
  MAP_STYLE(SS_PATHELLIPSIS, DT_PATH_ELLIPSIS);

  NMAP_STYLE(SS_LEFTNOWORDWRAP | SS_CENTERIMAGE | SS_WORDELLIPSIS | SS_ENDELLIPSIS | SS_PATHELLIPSIS, DT_WORDBREAK);

  hb_stornl(dwStyle, 1);
  hb_stornl(dwText, 2);
}

// HWG_BRINGTOTOP(HWND) --> .T.|.F.
HB_FUNC(HWG_BRINGTOTOP)
{
  auto hWnd = hwg_par_HWND(1);
  // DWORD ForegroundThreadID;
  // DWORD    ThisThreadID;
  // DWORD      timeout;
  // BOOL Res = FALSE;
  if (IsIconic(hWnd)) {
    ShowWindow(hWnd, SW_RESTORE);
    hb_retl(true);
    return;
  }

  // ForegroundThreadID = GetWindowThreadProcessID(GetForegroundWindow(),nullptr);
  // ThisThreadID = GetWindowThreadPRocessId(hWnd, nullptr);
  //    if( AttachThreadInput(ThisThreadID, ForegroundThreadID, TRUE) ) {

  BringWindowToTop(hWnd); // IE 5.5 related hack
  SetForegroundWindow(hWnd);
  //      AttachThreadInput(ThisThreadID, ForegroundThreadID,FALSE);
  //      Res = (GetForegroundWindow() == hWnd);
  //   }
  // hb_retl(Res);
}

// HWG_UPDATEWINDOW(HWND) --> NIL
HB_FUNC(HWG_UPDATEWINDOW)
{
  UpdateWindow(hwg_par_HWND(1));
}

LONG GetFontDialogUnits(HWND h, HFONT f)
{
  HB_SYMBOL_UNUSED(f);

  // get the hdc to the main window
  auto hDc = GetDC(h);

  // with the current font attributes, select the font
  // hFont = f;//GetStockObject(ANSI_VAR_FONT);
  auto hFont = static_cast<HFONT>(GetStockObject(ANSI_VAR_FONT));
  auto hFontOld = static_cast<HFONT>(SelectObject(hDc, hFont));

  // get its length, then calculate the average character width

  LPCTSTR tmp = TEXT("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz");
  SIZE sz;
  GetTextExtentPoint32(hDc, tmp, 52, &sz);
  LONG avgWidth = (sz.cx / 52);

  // re-select the previous font & delete the hDc
  SelectObject(hDc, hFontOld);
  DeleteObject(hFont);
  ReleaseDC(h, hDc);

  return avgWidth;
}

// HWG_GETFONTDIALOGUNITS(HWND, HFONT) --> numeric
HB_FUNC(HWG_GETFONTDIALOGUNITS)
{
  hb_retnl(GetFontDialogUnits(hwg_par_HWND(1), static_cast<HFONT>(hb_parptr(2))));
}

// HWG_GETTOOLBARID(HWND, np2) --> numeric
HB_FUNC(HWG_GETTOOLBARID)
{
  auto hMytoolMenu = hwg_par_HWND(1);
  auto wp = static_cast<WPARAM>(hb_parnl(2));
  UINT uId;

  if (SendMessage(hMytoolMenu, TB_MAPACCELERATOR, static_cast<WPARAM>(wp), reinterpret_cast<LPARAM>(&uId)) != 0) {
    hb_retnl(uId);
  } else {
    hb_retnl(-1);
  }
}

// HWG_ISWINDOW(HWND) --> .T.|.F.
HB_FUNC(HWG_ISWINDOW)
{
  hb_retl(IsWindow(hwg_par_HWND(1)));
}

// HWG_MINMAXWINDOW(p1, p2, p3, p4, p5, p6) --> NIL
HB_FUNC(HWG_MINMAXWINDOW)
{
  MINMAXINFO *lpMMI = static_cast<MINMAXINFO *>(hb_parptr(2));
  DWORD m_fxMin;
  DWORD m_fyMin;
  DWORD m_fxMax;
  DWORD m_fyMax;

  m_fxMin = (HB_ISNIL(3)) ? lpMMI->ptMinTrackSize.x : hb_parni(3);
  m_fyMin = (HB_ISNIL(4)) ? lpMMI->ptMinTrackSize.y : hb_parni(4);
  m_fxMax = (HB_ISNIL(5)) ? lpMMI->ptMaxTrackSize.x : hb_parni(5);
  m_fyMax = (HB_ISNIL(6)) ? lpMMI->ptMaxTrackSize.y : hb_parni(6);
  lpMMI->ptMinTrackSize.x = m_fxMin;
  lpMMI->ptMinTrackSize.y = m_fyMin;
  lpMMI->ptMaxTrackSize.x = m_fxMax;
  lpMMI->ptMaxTrackSize.y = m_fyMax;

  //   SendMessage(hwg_par_HWND(1), WM_GETMINMAXINFO, 0, static_cast<LPARAM>(lpMMI));
}

// HWG_GETWINDOWPLACEMENT(HWND) --> numeric
HB_FUNC(HWG_GETWINDOWPLACEMENT)
{
  auto hWnd = hwg_par_HWND(1);
  WINDOWPLACEMENT wp;

  wp.length = sizeof(WINDOWPLACEMENT);

  if (GetWindowPlacement(hWnd, &wp)) {
    hb_retnl(wp.showCmd);
  } else {
    hb_retnl(-1);
  }
}

// HWG_FLASHWINDOW(HWND, np2) --> NIL
HB_FUNC(HWG_FLASHWINDOW)
{
  FlashWindow(hwg_par_HWND(1), (HB_ISNIL(2)) ? 1 : hb_parni(2));
}

// HWG_ANSITOUNICODE(cText) --> cText
HB_FUNC(HWG_ANSITOUNICODE)
{
  void *hText = static_cast<TCHAR *>(hb_xgrab((1024 + 1) * sizeof(TCHAR)));
#if !defined(__XHARBOUR__)
  hb_parstr_u16(1, HB_CDP_ENDIAN_NATIVE, &hText, nullptr);
#else
  hwg_wstrget(hb_param(1, Harbour::Item::ANY), &hText, nullptr);
#endif
  HB_RETSTRLEN(static_cast<TCHAR *>(hText), 1024);
  hb_strfree(hText);
}

// HWG_CLEARKEYBOARD() --> NIL
HB_FUNC(HWG_CLEARKEYBOARD)
{
  s_ClearKeyboard();
}

// HWG_PAINTWINDOW(HWND, HBRUSH) --> NIL
HB_FUNC(HWG_PAINTWINDOW)
{
  auto pps = static_cast<PAINTSTRUCT *>(hb_xgrab(sizeof(PAINTSTRUCT)));
  auto hDC = BeginPaint(hwg_par_HWND(1), pps);
  BOOL fErase = pps->fErase;
  RECT rc = pps->rcPaint;
  HBRUSH hBrush = (HB_ISNIL(2)) ? reinterpret_cast<HBRUSH>(COLOR_3DFACE + 1) : hwg_par_HBRUSH(2);
  if (fErase == 1) {
    FillRect(hDC, &rc, hBrush);
  }

  EndPaint(hwg_par_HWND(1), pps);
  hb_xfree(pps);
}

// HWG_GETBACKBRUSH(HWND) --> handle
HB_FUNC(HWG_GETBACKBRUSH)
{
  hb_retptr(GetCurrentObject(GetDC(hwg_par_HWND(1)), OBJ_BRUSH));
}

// HWG_WINDOWSETRESIZE(HWND) --> NIL
HB_FUNC(HWG_WINDOWSETRESIZE)
{
  auto handle = hwg_par_HWND(1);
  int iResizeable = (HB_ISNIL(2)) ? 0 : hb_parl(2);

  if (iResizeable) {
    SetWindowLongPtr(handle, GWL_STYLE, GetWindowLongPtr(handle, GWL_STYLE) | (WS_SIZEBOX | WS_MAXIMIZEBOX));
  } else {
    SetWindowLongPtr(handle, GWL_STYLE, GetWindowLongPtr(handle, GWL_STYLE) & ~(WS_SIZEBOX | WS_MAXIMIZEBOX));
  }
}

LRESULT CALLBACK KeybHook(int code, WPARAM wp, LPARAM lp)
{
  if ((code >= 0) && (lp & 0x80000000)) {
    auto pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(GetActiveWindow(), GWLP_USERDATA));

    if (!pSym_keylist) {
      pSym_keylist = hb_dynsymFindName("EVALKEYLIST");
    }

    if (pObject && pSym_keylist && hb_objHasMessage(pObject, pSym_keylist)) {
      hb_vmPushSymbol(hb_dynsymSymbol(pSym_keylist));
      hb_vmPush(pObject);
      hb_vmPushLong(static_cast<LONG>(wp));
      hb_vmSend(1);
    }
  }

  return CallNextHookEx(nullptr, code, wp, lp);
}

// HWG__ISUNICODE() --> .T.|.F.
HB_FUNC(HWG__ISUNICODE)
{
#ifdef UNICODE
  hb_retl(true);
#else
  hb_retl(false);
#endif
}

// HWG_INITPROC() --> NIL
HB_FUNC(HWG_INITPROC)
{
  s_KeybHook = SetWindowsHookEx(WH_KEYBOARD, KeybHook, 0, GetCurrentThreadId());
}

// HWG_EXITPROC() --> NIL
HB_FUNC(HWG_EXITPROC)
{
  if (aDialogs) {
    hb_xfree(aDialogs);
  }

  if (s_KeybHook) {
    UnhookWindowsHookEx(s_KeybHook);
    s_KeybHook = nullptr;
  }
}

// hwg_SetApplocale()
// GTK only, for WinAPI empty function body
// for compatibility purpose

// HWG_SETAPPLOCALE() --> NIL
HB_FUNC(HWG_SETAPPLOCALE)
{
}
