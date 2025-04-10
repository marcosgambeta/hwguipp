//
// HWGUI++ and hblibvlc test
//
// Copyright (c) 2025 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
//

// hblibvlc:
// https://github.com/marcosgambeta/hblibvlc

// Compile with:
// hbmk2 hwguitest1 hblibvlc.hbc

#include "hwguipp.ch"

FUNCTION Main()

   LOCAL oMainWindow
   LOCAL vlc_instance
   LOCAL player
   LOCAL video_url
   LOCAL media

   // initialize libVLC
   vlc_instance := libvlc_new(0, NIL)

   IF Empty(vlc_instance)
      hwg_MsgInfo("libvlc_new failed")
      QUIT
   ENDIF

   // create a media player
   player := libvlc_media_player_new(vlc_instance)

   IF Empty(player)
      hwg_MsgInfo("libvlc_media_player_new failed")
      libvlc_release(vlc_instance)
      QUIT
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
      QUIT
   ENDIF

   // set the media to the player
   libvlc_media_player_set_media(player, media)

   INIT WINDOW oMainWindow TITLE "Testing HWGUI++ and hblibvlc" SIZE 800, 600

   MENU OF oMainWindow
      MENU TITLE "&Options"
         MENUITEM "Option A1" ACTION hwg_MsgInfo("A1")
         MENUITEM "Option A2" ACTION hwg_MsgInfo("A2")
         MENUITEM "Option A3" ACTION hwg_MsgInfo("A3")
         SEPARATOR
         MENUITEM "Exit" ACTION hwg_EndWindow()
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oMainWindow ON ACTIVATE {|| ;
      libvlc_media_player_set_hwnd(player, oMainWindow:handle), ;
      libvlc_media_player_play(player)}

   // clean up
   libvlc_media_player_stop(player)
   libvlc_media_release(media)
   libvlc_media_player_release(player)
   libvlc_release(vlc_instance)

RETURN NIL
