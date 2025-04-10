//
// HWGUI++ and hblibvlc test
//
// Copyright (c) 2025 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
//

// hblibvlc:
// https://github.com/marcosgambeta/hblibvlc

// Compile with:
// hbmk2 hwguitest3 hblibvlc.hbc

// Requisites to run the test:
// libvlc plugins folder
// libvlc.dll
// libvlccore.dll

#include "hwguipp.ch"

FUNCTION Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow TITLE "Testing HWGUI++ and hblibvlc" SIZE 800, 600

   MENU OF oMainWindow
      MENU TITLE "&Options"
         MENUITEM "&Dialog" ACTION ShowDialog()
         SEPARATOR
         MENUITEM "Exit" ACTION hwg_EndWindow()
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oMainWindow MAXIMIZED

RETURN NIL

STATIC FUNCTION ShowDialog()

   LOCAL oDialog
   LOCAL vlc_instance
   LOCAL player
   LOCAL video_url
   LOCAL media

   // initialize libVLC
   vlc_instance := libvlc_new(0, NIL)

   IF Empty(vlc_instance)
      hwg_MsgInfo("libvlc_new failed")
      RETURN NIL
   ENDIF

   // create a media player
   player := libvlc_media_player_new(vlc_instance)

   IF Empty(player)
      hwg_MsgInfo("libvlc_media_player_new failed")
      libvlc_release(vlc_instance)
      RETURN NIL
   ENDIF

   // create url.txt if not found
   IF !File("url.txt")
      MemoWrit("url.txt", "https://archive.org/download/CC_1916_09_04_TheCount/CC_1916_09_04_TheCount_512kb.mp4")
   ENDIF

   // create media from a URL (put the URL in a file named url.txt)
   video_url := memoread("url.txt")
   media := libvlc_media_new_location(vlc_instance, video_url)

   IF Empty(media)
      hwg_MsgInfo("libvlc_media_new_location failed")
      libvlc_media_player_release(player)
      libvlc_release(vlc_instance)
      RETURN NIL
   ENDIF

   // set the media to the player
   libvlc_media_player_set_media(player, media)

   INIT DIALOG oDialog TITLE video_url SIZE 800, 600

   ACTIVATE DIALOG oDialog ON ACTIVATE {|| ;
      libvlc_media_player_set_hwnd(player, oDialog:handle), ;
      libvlc_media_player_play(player)}

   // clean up
   libvlc_media_player_stop(player)
   libvlc_media_release(media)
   libvlc_media_player_release(player)
   libvlc_release(vlc_instance)

RETURN NIL
