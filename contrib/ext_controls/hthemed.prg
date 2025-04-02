/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HStaticEx, HButtonEx, HGroupEx
 *
 * Copyright 2007 Luiz Rafael Culik Guimaraes <luiz at xharbour.com.br >
 * www - http://sites.uol.com.br/culikr/
*/

#include <hbclass.ch>
#include "hwguipp.ch"
#include <common.ch>

#translate :hBitmap       => :m_csbitmaps\[1\]
#translate :dwWidth       => :m_csbitmaps\[2\]
#translate :dwHeight      => :m_csbitmaps\[3\]
#translate :hMask         => :m_csbitmaps\[4\]
#translate :crTransparent => :m_csbitmaps\[5\]

#define TRANSPARENT 1
#define BTNST_COLOR_BK_IN     1            // Background color when mouse is INside
#define BTNST_COLOR_FG_IN     2            // Text color when mouse is INside
#define BTNST_COLOR_BK_OUT    3             // Background color when mouse is OUTside
#define BTNST_COLOR_FG_OUT    4             // Text color when mouse is OUTside
#define BTNST_COLOR_BK_FOCUS  5           // Background color when the button is focused
#define BTNST_COLOR_FG_FOCUS  6            // Text color when the button is focused
#define BTNST_MAX_COLORS      6
#define WM_SYSCOLORCHANGE               0x0015
#define BS_TYPEMASK SS_TYPEMASK
#define OFS_X 10 // distance from left/right side to beginning/end of text
#define RT_MANIFEST  24

CLASS HThemed
   CLASS VAR WindowsManifest INIT !EMPTY(hwg_Findresource( , 1 , RT_MANIFEST ) ) SHARED
   DATA hTheme
   DATA Themed INIT .F.

ENDCLASS

INIT PROCEDURE starttheme()
hwg_Initthemelib()

EXIT PROCEDURE endtheme()
hwg_Endthemelib()
