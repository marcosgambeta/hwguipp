/*
 * GTHWG, Video subsystem, based on HwGUI
 *
 * test1.prg - simple test program
 *
 * Copyright 2021 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 */

#include "hbgtinfo.ch"

FUNCTION Main

   LOCAL nKey, nh, nw, GetList := {}
   LOCAL cLogin := Space(16)

   REQUEST HB_GT_HWGUI
   REQUEST HB_GT_HWGUI_DEFAULT

   REQUEST HB_CODEPAGE_RU866
   REQUEST HB_CODEPAGE_UTF8

   SET SCORE OFF
   hb_cdpSelect( "RU866" )

   CreateWindow()

   SetMode( 30, 90 )
   nw := Min( 1920, hb_gtinfo( HB_GTI_DESKTOPWIDTH ) ) - 20
   nh := Min( 1080, hb_gtinfo( HB_GTI_DESKTOPHEIGHT ) ) - 84
   hb_gtinfo( HB_GTI_FONTWIDTH, Int( nw / ( MaxCol() + 1 ) ) )
   hb_gtinfo( HB_GTI_FONTSIZE, Int( nh / ( MaxRow() + 1 ) ) )
   //hwg_writelog( "gt: " + hb_gtVersion() + " " + hwg_version() )

   SetColor( "W+/B" )
   clear screen
   @ 0, 0, MaxRow(), MaxCol() BOX "******** "
   @ 4, 5 SAY "Test"
   @ MaxRow() - 1, 1 SAY "---- " + Str(MaxRow() + 1, 3) + " X " + Str(MaxCol() + 1, 3) + " Desktop:" + Str(hb_gtinfo(HB_GTI_DESKTOPROWS), 3)
   @ MaxRow() - 1, 70 SAY "----"
   @ MaxRow(), 1 SAY "===="
   @ MaxRow(), 70 SAY "===="
   @ 3, 5 SAY "������ ⥪��:" GET cLogin
   READ

   hwg_writelog( "Login: " + cLogin )

   nKey := Inkey(5)
   hwg_writelog( "Key " + Str(nKey) )
   gthwg_CloseWindow()

   RETURN NIL

#include "hwguipp.ch"

STATIC FUNCTION CreateWindow()

   LOCAL oWnd := gthwg_CreateMainWindow( "GT HwGUI Test" )

   MENU OF oWnd
      MENU TITLE "&File"
         MENUITEM "&New" ACTION hwg_MsgInfo("New!")
         SEPARATOR
         MENUITEM "&Exit" ACTION oWnd:Close()
      ENDMENU
      MENU TITLE "&Help"
         MENUITEM "&About" ACTION hwg_MsgInfo(hwg_version() + Chr(13) + Chr(10) + "gt: " + hb_gtVersion(), "About")
      ENDMENU
   ENDMENU

   RETURN oWnd
