/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * C level windows functions
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "guilib.h"
#include "hbapifs.h"
#include "hbapiitm.h"
#include "hbvm.h"
#include "item.api"
#include <locale.h>
#include "gtk/gtk.h"
#include "gdk/gdkkeysyms.h"
#ifdef __XHARBOUR__
#include "hbfast.h"
#else
#include "hbapicls.h"
#endif
#include "hwgtk.h"

/* Avoid warnings from GCC */
#include "warnings.h"

#define WM_MOVE                           3
#define WM_SIZE                           5
#define WM_SETFOCUS                       7
#define WM_KILLFOCUS                      8
#define WM_KEYDOWN                      256    // 0x0100
#define WM_KEYUP                        257    // 0x0101
#define WM_MOUSEMOVE                    512    // 0x0200
#define WM_LBUTTONDOWN                  513    // 0x0201
#define WM_LBUTTONUP                    514    // 0x0202
#define WM_LBUTTONDBLCLK                515    // 0x0203
#define WM_RBUTTONDOWN                  516    // 0x0204
#define WM_RBUTTONUP                    517    // 0x0205

extern void hwg_writelog(const char * sFile, const char * sTraceMsg, ...);

void SetObjectVar(PHB_ITEM pObject, char* varname, PHB_ITEM pValue);
PHB_ITEM GetObjectVar(PHB_ITEM pObject, const char * varname);
void SetWindowObject(GtkWidget * hWnd, PHB_ITEM pObject);
void all_signal_connect(gpointer hWnd);
void set_signal(gpointer handle, char * cSignal, long int p1, long int p2, long int p3);
void cb_signal(GtkWidget * widget, gchar * data);
gint cb_signal_size(GtkWidget * widget, GtkAllocation * allocation, gpointer data);
void set_event(gpointer handle, char * cSignal, long int p1, long int p2, long int p3);

PHB_DYNS pSym_onEvent = nullptr;
PHB_DYNS pSym_keylist = nullptr;
guint s_KeybHook = 0;
GtkWidget * hMainWindow = nullptr;

HB_LONG prevp2 = -1;

typedef struct
{
   char * cName;
   int msg;
} HW_SIGNAL, * PHW_SIGNAL;

#define NUMBER_OF_SIGNALS   1
static HW_SIGNAL aSignals[NUMBER_OF_SIGNALS] = {{"destroy", 2}};

static gchar szAppLocale[] = "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";

gboolean cb_delete_event(GtkWidget * widget, gchar * data)
{
   gpointer gObject;

   HB_SYMBOL_UNUSED(data);
   gObject = g_object_get_data(reinterpret_cast<GObject*>(widget), "obj");

   if( !pSym_onEvent )
   {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   if( pSym_onEvent && gObject )
   {
      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(static_cast<PHB_ITEM>(gObject));
      hb_vmPushLong(2);
      hb_vmPushLong(0);
      hb_vmPushLong(0);
      hb_vmSend(3);
      return !(static_cast<gboolean>(hb_parl(-1)));
   }
   return FALSE;
}

HB_FUNC( HWG_GTK_INIT )
{
   gtk_init(0, 0);
   setlocale(LC_NUMERIC, "C");
   setlocale(LC_CTYPE, "");
}

HB_FUNC( HWG_GTK_EXIT )
{
   gtk_main_quit();
}

/*  Creates main application window
    hwg_InitMainWindow(pObject, szAppName, cTitle, cMenu, hIcon, nStyle, nLeft, nTop, nWidth, nHeight, hbackground)
*/
HB_FUNC( HWG_INITMAINWINDOW )
{
   GtkWidget * hWnd ;
   GtkWidget * vbox;
   GtkFixed * box;
   GdkPixmap * background;
   GtkStyle * style;
   PHB_ITEM pObject = hb_param(1, Harbour::Item::OBJECT);
   gchar * gcTitle = hwg_convert_to_utf8(hb_parcx(3));
   int x = hb_parnl(7);
   int y = hb_parnl(8);
   int width = hb_parnl(9);
   int height = hb_parnl(10);
   /* Icon */
   PHWGUI_PIXBUF szFile = HB_ISPOINTER(5) ? static_cast<PHWGUI_PIXBUF>(HB_PARHANDLE(5)) : nullptr;
   /* Background image */
   PHWGUI_PIXBUF szBackFile = HB_ISPOINTER(11) ? static_cast<PHWGUI_PIXBUF>(HB_PARHANDLE(11)) : nullptr;

   /* Background style*/
   style = gtk_style_new();
   if( szBackFile )
   {
      gdk_pixbuf_render_pixmap_and_mask(szBackFile->handle, &background, nullptr, 0);
      if( !background )
      {
         g_error("%s\n", "Error loading background image");
      }
      style->bg_pixmap[0] = background;
   }

   hWnd = static_cast<GtkWidget*>(gtk_window_new(GTK_WINDOW_TOPLEVEL));

   gtk_window_set_title(GTK_WINDOW(hWnd), gcTitle);
   g_free(gcTitle);
   //gtk_window_set_policy(GTK_WINDOW(hWnd), TRUE, TRUE, FALSE);
   gtk_window_set_resizable(GTK_WINDOW(hWnd), TRUE);
   gtk_window_set_default_size(GTK_WINDOW(hWnd), width, height);
   gtk_window_move(GTK_WINDOW(hWnd), x, y);

   vbox = gtk_vbox_new(FALSE, 0);
   gtk_container_add(GTK_CONTAINER(hWnd), vbox);

   box = reinterpret_cast<GtkFixed*>(gtk_fixed_new());
   gtk_box_pack_start(GTK_BOX(vbox), reinterpret_cast<GtkWidget*>(box), TRUE, TRUE, 0);

   g_object_set_data(reinterpret_cast<GObject*>(hWnd), "window", reinterpret_cast<gpointer>(1));
   SetWindowObject(hWnd, pObject);
   g_object_set_data(reinterpret_cast<GObject*>(hWnd), "vbox", static_cast<gpointer>(vbox));
   g_object_set_data(reinterpret_cast<GObject*>(hWnd), "fbox", static_cast<gpointer>(box));

   gtk_widget_add_events(hWnd, GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK | GDK_POINTER_MOTION_MASK | GDK_FOCUS_CHANGE);
   set_event(static_cast<gpointer>(hWnd), "button_press_event", 0, 0, 0);
   set_event(static_cast<gpointer>(hWnd), "button_release_event", 0, 0, 0);
   set_event(static_cast<gpointer>(hWnd), "motion_notify_event", 0, 0, 0);

   g_signal_connect(G_OBJECT(hWnd), "delete-event", G_CALLBACK(cb_delete_event), nullptr);
   g_signal_connect(G_OBJECT (hWnd), "destroy", G_CALLBACK(gtk_main_quit), nullptr);

   set_event(static_cast<gpointer>(hWnd), "configure_event", 0, 0, 0);
   set_event(static_cast<gpointer>(hWnd), "focus_in_event", 0, 0, 0);

   g_signal_connect_after(box, "size-allocate", G_CALLBACK(cb_signal_size), nullptr);
   //g_signal_connect_after(hWnd, "size-allocate", G_CALLBACK(cb_signal_size), nullptr);

/* Set default icon
   DF7BE:
   gtk_window_set_icon() does not work
*/
   if (szFile)
   {
      gtk_window_set_default_icon(szFile->handle);
   }
   /* Set Background */
   if (szBackFile)
   {
      gtk_widget_set_style(GTK_WIDGET(hWnd), GTK_STYLE(style));
   }

   hMainWindow = hWnd;
   HB_RETHANDLE(hWnd);
}

HB_FUNC( HWG_CREATEDLG )
{
   GtkWidget * hWnd;
   GtkWidget * vbox;
   GtkFixed * box;
   GdkPixmap * background;
   GtkStyle * style;
   PHB_ITEM pObject = hb_param(1, Harbour::Item::OBJECT);
   gchar * gcTitle = hwg_convert_to_utf8(hb_itemGetCPtr(GetObjectVar(pObject, "TITLE")));
   int x = hb_itemGetNI(GetObjectVar(pObject, "NLEFT"));
   int y = hb_itemGetNI(GetObjectVar(pObject, "NTOP"));
   int width = hb_itemGetNI(GetObjectVar(pObject, "NWIDTH"));
   int height = hb_itemGetNI(GetObjectVar(pObject, "NHEIGHT"));
   PHB_ITEM pIcon = GetObjectVar(pObject, "OICON");
   PHB_ITEM pBmp = GetObjectVar(pObject, "OBMP");
   PHWGUI_PIXBUF szFile = nullptr;
   PHWGUI_PIXBUF szBackFile = nullptr;

   /* Icon */
   if( !HB_IS_NIL(pIcon) )
   {
      szFile = static_cast<PHWGUI_PIXBUF>(hb_itemGetPtr(GetObjectVar(pIcon, "HANDLE")));
   }
   /* Background image */
   if( !HB_IS_NIL(pBmp) )
   {
      szBackFile = static_cast<PHWGUI_PIXBUF>(hb_itemGetPtr(GetObjectVar(pBmp, "HANDLE")));
   }
   /* Background style*/
   style = gtk_style_new();
   if( szBackFile )
   {
      gdk_pixbuf_render_pixmap_and_mask(szBackFile->handle, &background, nullptr, 0);
      if( !background )
      {
         g_error("%s\n", "Error loading background image");
      }
      style->bg_pixmap[0] = background;
   }

   hWnd = static_cast<GtkWidget*>(gtk_window_new(GTK_WINDOW_TOPLEVEL));

   if( szFile )
   {
      gtk_window_set_icon(GTK_WINDOW(hWnd), szFile->handle);
   }

   gtk_window_set_title(GTK_WINDOW(hWnd), gcTitle);
   g_free(gcTitle);
   //gtk_window_set_policy(GTK_WINDOW(hWnd), TRUE, TRUE, FALSE);
   gtk_window_set_resizable(GTK_WINDOW(hWnd), TRUE);
   gtk_window_set_default_size(GTK_WINDOW(hWnd), width, height);
   gtk_window_move(GTK_WINDOW(hWnd), x, y);

   vbox = gtk_vbox_new(FALSE, 0);
   gtk_container_add(GTK_CONTAINER(hWnd), vbox);

   box = reinterpret_cast<GtkFixed*>(gtk_fixed_new());
   gtk_box_pack_start(GTK_BOX(vbox), reinterpret_cast<GtkWidget*>(box), TRUE, TRUE, 0);

   g_object_set_data(reinterpret_cast<GObject*>(hWnd), "window", reinterpret_cast<gpointer>(1));
   SetWindowObject(hWnd, pObject);
   g_object_set_data(reinterpret_cast<GObject*>(hWnd), "vbox", static_cast<gpointer>(vbox));
   g_object_set_data(reinterpret_cast<GObject*>(hWnd), "fbox", static_cast<gpointer>(box));

   gtk_widget_add_events(hWnd, GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK | GDK_POINTER_MOTION_MASK | GDK_FOCUS_CHANGE);
   set_event(static_cast<gpointer>(hWnd), "button_press_event", 0, 0, 0 );
   set_event(static_cast<gpointer>(hWnd), "button_release_event", 0, 0, 0);
   set_event(static_cast<gpointer>(hWnd), "motion_notify_event", 0, 0, 0);

   g_signal_connect(G_OBJECT(hWnd), "delete-event", G_CALLBACK(cb_delete_event), nullptr);

   set_event(static_cast<gpointer>(hWnd), "configure_event", 0, 0, 0);
   set_event(static_cast<gpointer>(hWnd), "focus_in_event", 0, 0, 0);

   g_signal_connect(box, "size-allocate", G_CALLBACK(cb_signal_size), nullptr);
   //g_signal_connect(hWnd, "size-allocate", G_CALLBACK(cb_signal_size), nullptr);

   /* Set Background */
   if( szBackFile )
   {
      gtk_widget_set_style(GTK_WIDGET(hWnd), GTK_STYLE(style));
   }

   HB_RETHANDLE(hWnd);
}

/*
 *  HWG_ACTIVATEMAINWINDOW(lShow, hAccel, lMaximize, lMinimize)
 */
HB_FUNC( HWG_ACTIVATEMAINWINDOW )
{
/*
   GtkWidget * hWnd = static_cast<GtkWidget*>(HB_PARHANDLE(1));

   if( !HB_ISNIL(3) && hb_parl(3) )
   {
      gtk_window_maximize(static_cast<GtkWindow*>(hWnd));
   }
   if( !HB_ISNIL(4) && hb_parl(4) )
   {
      gtk_window_iconify(static_cast<GtkWindow*>(hWnd));
   }

   gtk_widget_show_all(hWnd);
*/
   gtk_main();
}

HB_FUNC( HWG_ACTIVATEDIALOG )
{
   // gtk_widget_show_all(static_cast<GtkWidget*>(HB_PARHANDLE(1)));
   if( HB_ISNIL(2) || !hb_parl(2) )
   {
      gtk_main();
   }
}

void hwg_doEvents(void)
{
   while( g_main_context_iteration(nullptr, FALSE) );
}

void ProcessMessage(void)
{
   while( g_main_context_iteration(nullptr, FALSE) );
}

HB_FUNC( HWG_PROCESSMESSAGE )
{
   ProcessMessage();
}

gint cb_signal_size(GtkWidget * widget, GtkAllocation * allocation, gpointer data)
{
   gpointer gObject = g_object_get_data(reinterpret_cast<GObject*>(gtk_widget_get_parent(gtk_widget_get_parent(widget))), "obj");
   //gpointer gObject = g_object_get_data(static_cast<GObject*>(widget), "obj");
   HB_SYMBOL_UNUSED(data);

   if( !pSym_onEvent )
   {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   if( pSym_onEvent && gObject )
   {
      HB_LONG p3 = (static_cast<HB_ULONG>(allocation->width) & 0xFFFF) | ((static_cast<HB_ULONG>(allocation->height) << 16) & 0xFFFF0000);

      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(static_cast<PHB_ITEM>(gObject));
      hb_vmPushLong(WM_SIZE);
      hb_vmPushLong(0);
      hb_vmPushLong(p3);
      hb_vmSend(3);

   }
   return 0;
}

void cb_signal(GtkWidget * widget, gchar * data)
{
   gpointer gObject;
   HB_LONG p1, p2, p3;

   sscanf(static_cast<char*>(data), "%ld %ld %ld", &p1, &p2, &p3);
   if( !p1 )
   {
      p1 = 273;
      if( p3 )
      {
         widget = reinterpret_cast<GtkWidget*>(p3);
      }
      else
      {
         widget = hMainWindow;
      }
      p3 = 0;
   }

   gObject = g_object_get_data(reinterpret_cast<GObject*>(widget), "obj");

   if( !pSym_onEvent )
   {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   if( pSym_onEvent && gObject )
   {
      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(static_cast<PHB_ITEM>(gObject));
      hb_vmPushLong(p1);
      hb_vmPushLong(p2);
      hb_vmPushLong(static_cast<HB_LONG>(p3));
      hb_vmSend(3);
      /* res = hb_parnl(-1); */
   }
}

static HB_LONG ToKey(HB_LONG a, HB_LONG b)
{
   switch( a )
   {
      case GDK_KEY_asciitilde:
      case GDK_KEY_dead_tilde:
         switch( b )
         {
            case GDK_KEY_A: return static_cast<HB_LONG>(GDK_KEY_Atilde);
            case GDK_KEY_a: return static_cast<HB_LONG>(GDK_KEY_atilde);
            case GDK_KEY_N: return static_cast<HB_LONG>(GDK_KEY_Ntilde);
            case GDK_KEY_n: return static_cast<HB_LONG>(GDK_KEY_ntilde);
            case GDK_KEY_O: return static_cast<HB_LONG>(GDK_KEY_Otilde);
            case GDK_KEY_o: return static_cast<HB_LONG>(GDK_KEY_otilde);
         }
         break;
      case GDK_KEY_asciicircum:
      case GDK_KEY_dead_circumflex:
         switch( b )
         {
            case GDK_KEY_A: return static_cast<HB_LONG>(GDK_KEY_Acircumflex);
            case GDK_KEY_a: return static_cast<HB_LONG>(GDK_KEY_acircumflex);
            case GDK_KEY_E: return static_cast<HB_LONG>(GDK_KEY_Ecircumflex);
            case GDK_KEY_e: return static_cast<HB_LONG>(GDK_KEY_ecircumflex);
            case GDK_KEY_I: return static_cast<HB_LONG>(GDK_KEY_Icircumflex);
            case GDK_KEY_i: return static_cast<HB_LONG>(GDK_KEY_icircumflex);
            case GDK_KEY_O: return static_cast<HB_LONG>(GDK_KEY_Ocircumflex);
            case GDK_KEY_o: return static_cast<HB_LONG>(GDK_KEY_ocircumflex);
            case GDK_KEY_U: return static_cast<HB_LONG>(GDK_KEY_Ucircumflex);
            case GDK_KEY_u: return static_cast<HB_LONG>(GDK_KEY_ucircumflex);
            case GDK_KEY_C: return static_cast<HB_LONG>(GDK_KEY_Ccircumflex);
            case GDK_KEY_H: return static_cast<HB_LONG>(GDK_KEY_Hcircumflex);
            case GDK_KEY_h: return static_cast<HB_LONG>(GDK_KEY_hcircumflex);
            case GDK_KEY_J: return static_cast<HB_LONG>(GDK_KEY_Jcircumflex);
            case GDK_KEY_j: return static_cast<HB_LONG>(GDK_KEY_jcircumflex);
            case GDK_KEY_G: return static_cast<HB_LONG>(GDK_KEY_Gcircumflex);
            case GDK_KEY_g: return static_cast<HB_LONG>(GDK_KEY_gcircumflex);
            case GDK_KEY_S: return static_cast<HB_LONG>(GDK_KEY_Scircumflex);
            case GDK_KEY_s: return static_cast<HB_LONG>(GDK_KEY_scircumflex);
         }
         break;
      case GDK_KEY_grave:
      case GDK_KEY_dead_grave:
         switch( b )
         {
            case GDK_KEY_A: return static_cast<HB_LONG>(GDK_KEY_Agrave);
            case GDK_KEY_a: return static_cast<HB_LONG>(GDK_KEY_agrave);
            case GDK_KEY_E: return static_cast<HB_LONG>(GDK_KEY_Egrave);
            case GDK_KEY_e: return static_cast<HB_LONG>(GDK_KEY_egrave);
            case GDK_KEY_I: return static_cast<HB_LONG>(GDK_KEY_Igrave);
            case GDK_KEY_i: return static_cast<HB_LONG>(GDK_KEY_igrave);
            case GDK_KEY_O: return static_cast<HB_LONG>(GDK_KEY_Ograve);
            case GDK_KEY_o: return static_cast<HB_LONG>(GDK_KEY_ograve);
            case GDK_KEY_U: return static_cast<HB_LONG>(GDK_KEY_Ugrave);
            case GDK_KEY_u: return static_cast<HB_LONG>(GDK_KEY_ugrave);
            case GDK_KEY_C: return static_cast<HB_LONG>(GDK_KEY_Ccedilla);
            case GDK_KEY_c: return static_cast<HB_LONG>(GDK_KEY_ccedilla);
         }
         break;
      case GDK_KEY_acute:
      case GDK_KEY_dead_acute:
         switch( b )
         {
            case GDK_KEY_A: return static_cast<HB_LONG>(GDK_KEY_Aacute);
            case GDK_KEY_a: return static_cast<HB_LONG>(GDK_KEY_aacute);
            case GDK_KEY_E: return static_cast<HB_LONG>(GDK_KEY_Eacute);
            case GDK_KEY_e: return static_cast<HB_LONG>(GDK_KEY_eacute);
            case GDK_KEY_I: return static_cast<HB_LONG>(GDK_KEY_Iacute);
            case GDK_KEY_i: return static_cast<HB_LONG>(GDK_KEY_iacute);
            case GDK_KEY_O: return static_cast<HB_LONG>(GDK_KEY_Oacute);
            case GDK_KEY_o: return static_cast<HB_LONG>(GDK_KEY_oacute);
            case GDK_KEY_U: return static_cast<HB_LONG>(GDK_KEY_Uacute);
            case GDK_KEY_u: return static_cast<HB_LONG>(GDK_KEY_uacute);
            case GDK_KEY_Y: return static_cast<HB_LONG>(GDK_KEY_Yacute);
            case GDK_KEY_y: return static_cast<HB_LONG>(GDK_KEY_yacute);
            case GDK_KEY_C: return static_cast<HB_LONG>(GDK_KEY_Cacute);
            case GDK_KEY_c: return static_cast<HB_LONG>(GDK_KEY_cacute);
            case GDK_KEY_L: return static_cast<HB_LONG>(GDK_KEY_Lacute);
            case GDK_KEY_l: return static_cast<HB_LONG>(GDK_KEY_lacute);
            case GDK_KEY_N: return static_cast<HB_LONG>(GDK_KEY_Nacute);
            case GDK_KEY_n: return static_cast<HB_LONG>(GDK_KEY_nacute);
            case GDK_KEY_R: return static_cast<HB_LONG>(GDK_KEY_Racute);
            case GDK_KEY_r: return static_cast<HB_LONG>(GDK_KEY_racute);
            case GDK_KEY_S: return static_cast<HB_LONG>(GDK_KEY_Sacute);
            case GDK_KEY_s: return static_cast<HB_LONG>(GDK_KEY_sacute);
            case GDK_KEY_Z: return static_cast<HB_LONG>(GDK_KEY_Zacute);
            case GDK_KEY_z: return static_cast<HB_LONG>(GDK_KEY_zacute);
         }
         break;
      case GDK_KEY_diaeresis:
      case GDK_KEY_dead_diaeresis:
         switch( b )
         {
            case GDK_KEY_A: return static_cast<HB_LONG>(GDK_KEY_Adiaeresis);
            case GDK_KEY_a: return static_cast<HB_LONG>(GDK_KEY_adiaeresis);
            case GDK_KEY_E: return static_cast<HB_LONG>(GDK_KEY_Ediaeresis);
            case GDK_KEY_e: return static_cast<HB_LONG>(GDK_KEY_ediaeresis);
            case GDK_KEY_I: return static_cast<HB_LONG>(GDK_KEY_Idiaeresis);
            case GDK_KEY_i: return static_cast<HB_LONG>(GDK_KEY_idiaeresis);
            case GDK_KEY_O: return static_cast<HB_LONG>(GDK_KEY_Odiaeresis);
            case GDK_KEY_o: return static_cast<HB_LONG>(GDK_KEY_odiaeresis);
            case GDK_KEY_U: return static_cast<HB_LONG>(GDK_KEY_Udiaeresis);
            case GDK_KEY_u: return static_cast<HB_LONG>(GDK_KEY_udiaeresis);
            case GDK_KEY_Y: return static_cast<HB_LONG>(GDK_KEY_Ydiaeresis);
            case GDK_KEY_y: return static_cast<HB_LONG>(GDK_KEY_ydiaeresis);
      }
   }

   return b;
}

static gint cb_event(GtkWidget * widget, GdkEvent * event, gchar * data)
{
   gpointer gObject = g_object_get_data(reinterpret_cast<GObject*>(widget), "obj");
   HB_LONG lRes;
   //gunichar uchar;
   //gchar * tmpbuf;
   //gchar * res = nullptr;

   if( !pSym_onEvent )
   {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   //if( !gObject )
   //{
   //   gObject = g_object_get_data(static_cast<GObject*>(widget->parent->parent), "obj");
   //}
   if( pSym_onEvent && gObject )
   {
      HB_LONG p1, p2, p3;

      switch( event->type )
      {
         case GDK_KEY_PRESS:
         case GDK_KEY_RELEASE:
         {
            /*
            char utf8string[10];
            gunichar uchar;
            int ll;
            uchar = gdk_keyval_to_unicode((static_cast<GdkEventKey*>(event))->keyval);
            ll = g_unichar_to_utf8(uchar, utf8string);
            utf8string[ll] = '\0';
            g_debug("keyval: %lu %s", (static_cast<GdkEventKey*>(event))->keyval, utf8string);
            */
            p1 = (event->type == GDK_KEY_PRESS) ? WM_KEYDOWN : WM_KEYUP;
            p2 = (reinterpret_cast<GdkEventKey*>(event))->keyval;
            if( p2 == GDK_KEY_asciitilde || p2 == GDK_KEY_asciicircum || p2 == GDK_KEY_grave || p2 == GDK_KEY_acute || p2 == GDK_KEY_diaeresis || p2 == GDK_KEY_dead_acute || p2 == GDK_KEY_dead_tilde || p2==GDK_KEY_dead_circumflex || p2==GDK_KEY_dead_grave || p2 == GDK_KEY_dead_diaeresis )
            {
               prevp2 = p2;
               p2 = -1;
            }
            else
            {
               if( prevp2 != -1 )
               {
                  p2 = ToKey(prevp2, static_cast<HB_LONG>(p2));
                  //uchar = gdk_keyval_to_unicode(p2);
                  prevp2 = -1;
               }
            }
            //tmpbuf = g_new0(gchar, 7);
            //g_unichar_to_utf8(uchar, tmpbuf);
            //res = hwg_convert_to_utf8(tmpbuf);
            //g_free(tmpbuf);
            p3 = (((reinterpret_cast<GdkEventKey*>(event))->state & GDK_SHIFT_MASK) ? 1 : 0) |
                 (((reinterpret_cast<GdkEventKey*>(event))->state & GDK_CONTROL_MASK) ? 2 : 0) |
                 (((reinterpret_cast<GdkEventKey*>(event))->state & GDK_MOD1_MASK) ? 4 : 0);
            break;
         }
         case GDK_SCROLL:
         {
            p1 = WM_KEYDOWN;
            p2 = ((reinterpret_cast<GdkEventScroll*>(event))->direction == GDK_SCROLL_DOWN) ? 0xFF54 : 0xFF52;
            p3 = 0;
            break;
         }
         case GDK_BUTTON_PRESS:
         case GDK_2BUTTON_PRESS:
         case GDK_BUTTON_RELEASE:
         {
            if( (reinterpret_cast<GdkEventButton*>(event))->button == 3 )
            {
               p1 = (event->type == GDK_BUTTON_PRESS) ? WM_RBUTTONDOWN : ((event->type == GDK_BUTTON_RELEASE) ? WM_RBUTTONUP : WM_LBUTTONDBLCLK);
            }
            else
            {
               p1 = (event->type == GDK_BUTTON_PRESS) ? WM_LBUTTONDOWN : ((event->type == GDK_BUTTON_RELEASE) ? WM_LBUTTONUP : WM_LBUTTONDBLCLK);
            }
            p2 = 0;
            p3 = ((static_cast<HB_ULONG>((reinterpret_cast<GdkEventButton*>(event))->x)) & 0xFFFF) | (((static_cast<HB_ULONG>((reinterpret_cast<GdkEventButton*>(event))->y)) << 16) & 0xFFFF0000);
            break;
         }
         case GDK_MOTION_NOTIFY:
         {
            p1 = WM_MOUSEMOVE;
            p2 = ((reinterpret_cast<GdkEventMotion*>(event))->state & GDK_BUTTON1_MASK ) ? 1 : 0;
            p3 = ((static_cast<HB_ULONG>((reinterpret_cast<GdkEventMotion*>(event))->x)) & 0xFFFF) | (((static_cast<HB_ULONG>((reinterpret_cast<GdkEventMotion*>(event))->y)) << 16) & 0xFFFF0000);
            break;
         }
         case GDK_CONFIGURE:
         {
            GtkAllocation alloc;
            gtk_widget_get_allocation(widget, &alloc);
            p2 = 0;
            if( alloc.width != (reinterpret_cast<GdkEventConfigure*>(event))->width || alloc.height!= (reinterpret_cast<GdkEventConfigure*>(event))->height )
            {
               return 0;
            }
            else
            {
               p1 = WM_MOVE;
               p3 = ((reinterpret_cast<GdkEventConfigure*>(event))->x & 0xFFFF) | (((reinterpret_cast<GdkEventConfigure*>(event))->y << 16) & 0xFFFF0000);
            }
            break;
         }
         case GDK_ENTER_NOTIFY:
         case GDK_LEAVE_NOTIFY:
         {
            p1 = WM_MOUSEMOVE;
            p2 = ((reinterpret_cast<GdkEventCrossing*>(event))->state & GDK_BUTTON1_MASK) ? 1 : 0 | (event->type == GDK_ENTER_NOTIFY) ? 0x10 : 0;
            p3 = ((static_cast<HB_ULONG>((reinterpret_cast<GdkEventCrossing*>(event))->x)) & 0xFFFF) | (((static_cast<HB_ULONG>((reinterpret_cast<GdkEventMotion*>(event))->y)) << 16) & 0xFFFF0000);
            break;
         }
         case GDK_FOCUS_CHANGE:
         {
            p1 = ((reinterpret_cast<GdkEventFocus*>(event))->in) ? WM_SETFOCUS : WM_KILLFOCUS;
            p2 = p3 = 0;
            break;
         }
         default:
         {
            sscanf(static_cast<char*>(data), "%ld %ld %ld", &p1, &p2, &p3);
         }
      }

      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(static_cast<PHB_ITEM>(gObject));
      hb_vmPushLong(p1);
      hb_vmPushLong(p2);
      hb_vmPushLong(p3);
      hb_vmSend(3);
      lRes = hb_parnl(-1);
      return lRes;
   }

   return 0;
}

void set_signal(gpointer handle, char * cSignal, long int p1, long int p2, long int p3)
{
   char buf[25] = {0};

   sprintf(buf, "%ld %ld %ld", p1, p2, p3);
   g_signal_connect(handle, cSignal, G_CALLBACK(cb_signal), g_strdup(buf));
}

HB_FUNC( HWG_SETSIGNAL )
{
   gpointer p = static_cast<gpointer>(HB_PARHANDLE(1));
   set_signal(static_cast<gpointer>(p), const_cast<char*>(hb_parc(2)), hb_parnl(3), hb_parnl(4), reinterpret_cast<long int>(HB_PARHANDLE(5)));
}

HB_FUNC( HWG_EMITSIGNAL )
{
   g_signal_emit_by_name(G_OBJECT(HB_PARHANDLE(1)), const_cast<char*>(hb_parc(2)));
}

void set_event(gpointer handle, char * cSignal, long int p1, long int p2, long int p3)
{
   char buf[25] = {0};

   sprintf(buf, "%ld %ld %ld", p1, p2, p3);
   g_signal_connect(handle, cSignal, G_CALLBACK(cb_event), g_strdup(buf));
}

HB_FUNC( HWG_SETEVENT )
{
   gpointer p = static_cast<gpointer>(HB_PARHANDLE(1));
   set_event(p, const_cast<char*>(hb_parc(2)), hb_parnl(3), hb_parnl(4), hb_parnl(5));
}

void all_signal_connect(gpointer hWnd)
{
   char buf[20] = {0};

   for( int i = 0; i < NUMBER_OF_SIGNALS; i++ )
   {
      sprintf(buf, "%d 0 0", aSignals[i].msg);
      g_signal_connect(hWnd, aSignals[i].cName, G_CALLBACK(cb_signal), g_strdup(buf));
   }
}

GtkWidget * GetActiveWindow(void)
{
   GList * pL = gtk_window_list_toplevels(), * pList;

   pList = pL;
   while( pList )
   {
      if( gtk_window_is_active(pList->data) )
      {
         break;
      }
      pList = g_list_next(pList);
   }
   if( !pList )
   {
      pList = pL;
   }

   return (pList) ? pList->data : nullptr;
}

HB_FUNC( HWG_GETACTIVEWINDOW )
{
   HB_RETHANDLE(GetActiveWindow());
}

HB_FUNC( HWG_SETWINDOWOBJECT )
{
   SetWindowObject(static_cast<GtkWidget*>(HB_PARHANDLE(1)), hb_param(2, Harbour::Item::OBJECT));
}

void SetWindowObject(GtkWidget * hWnd, PHB_ITEM pObject)
{
   gpointer gObject = g_object_get_data(reinterpret_cast<GObject*>(hWnd), "obj");

   if( gObject )
   {
      hb_itemRelease(static_cast<PHB_ITEM>(gObject));
   }
   if( pObject )
   {
      g_object_set_data(reinterpret_cast<GObject*>(hWnd), "obj", static_cast<gpointer>(hb_itemNew(pObject)));
   }
   else
   {
      g_object_set_data(reinterpret_cast<GObject*>(hWnd), "obj", static_cast<gpointer>(nullptr));
   }
}

HB_FUNC( HWG_GETWINDOWOBJECT )
{
   gpointer dwNewLong = g_object_get_data(static_cast<GObject*>(HB_PARHANDLE(1)), "obj");

   if( dwNewLong )
   {
      hb_itemReturn(static_cast<PHB_ITEM>(dwNewLong));
   }
   else
   {
      hb_ret();
   }
}

HB_FUNC( HWG_SETWINDOWTEXT )
{
   gchar * gcTitle = hwg_convert_to_utf8(hb_parcx(2));
   gtk_window_set_title(GTK_WINDOW(HB_PARHANDLE(1)), gcTitle);
   g_free(gcTitle);
}

HB_FUNC( HWG_GETWINDOWTEXT )
{
   char * cTitle = const_cast<char*>(gtk_window_get_title(GTK_WINDOW(HB_PARHANDLE(1))));
   hb_retc(cTitle);
}

HB_FUNC( HWG_ENABLEWINDOW )
{
   GtkWidget * widget = static_cast<GtkWidget*>(HB_PARHANDLE(1));
   HB_BOOL lEnable = hb_parl(2);
   gtk_widget_set_sensitive(widget, lEnable);
}

HB_FUNC( HWG_ISWINDOWENABLED )
{
   hb_retl(gtk_widget_is_sensitive(static_cast<GtkWidget*>(HB_PARHANDLE(1))));
}

HB_FUNC( HWG_ISICONIC )
{
   hb_retl(0);
}

HB_FUNC( HWG_MOVEWINDOW )
{
   GtkWidget * hWnd = static_cast<GtkWidget*>(HB_PARHANDLE(1));

   if( !HB_ISNIL(2) || !HB_ISNIL(3) )
   {
      gtk_window_move(GTK_WINDOW(hWnd), hb_parni(2), hb_parni(3));
   }
   if( !HB_ISNIL(4) || !HB_ISNIL(5) )
   {
      gtk_window_resize(GTK_WINDOW(hWnd), hb_parni(4), hb_parni(5));
   }
}

HB_FUNC( HWG_CENTERWINDOW )
{
   GtkWindow * hWnd = static_cast<GtkWindow*>(HB_PARHANDLE(1));
   gint width = 0, height = 0;
   gtk_window_get_size(hWnd, &width, &height);
   gtk_window_move(hWnd, (gdk_screen_width() - width) / 2, (gdk_screen_height() - height) / 2);

}

HB_FUNC( HWG_WINDOWMAXIMIZE )
{
   gtk_window_maximize(static_cast<GtkWindow*>(HB_PARHANDLE(1)));
}

HB_FUNC( HWG_RESTOREWINDOW )
{
   gtk_window_unmaximize(static_cast<GtkWindow*>(HB_PARHANDLE(1)));
}

HB_FUNC( HWG_WINDOWMINIMIZE )
{
   gtk_window_iconify(static_cast<GtkWindow*>(HB_PARHANDLE(1)));
}

PHB_ITEM GetObjectVar(PHB_ITEM pObject, const char * varname)
{
#ifdef __XHARBOUR__
   return hb_objSendMsg(pObject, varname, 0);
#else
   hb_objSendMsg(pObject, varname, 0);
   return hb_param(-1, Harbour::Item::ANY);
#endif
}

void SetObjectVar(PHB_ITEM pObject, char * varname, PHB_ITEM pValue)
{
   hb_objSendMsg(pObject, varname, 1, pValue);
}

HB_FUNC( HWG_RELEASEOBJECT )
{
   GObject * hWnd = static_cast<GObject*>(HB_PARHANDLE(1));
   gpointer dwNewLong = g_object_get_data(hWnd, "obj");

   if( dwNewLong )
   {
      hb_itemRelease(static_cast<PHB_ITEM>(dwNewLong));
      g_object_set_data(hWnd, "obj", static_cast<gpointer>(nullptr));
   }
   else
   {
      hb_ret();
   }
}

HB_FUNC( HWG_SETFOCUS )
{
   GObject * hObj = static_cast<GObject*>(HB_PARHANDLE(1));
   GtkWidget * handle = gtk_window_get_focus(gtk_window_list_toplevels()->data);

   if( hObj )
   {
      if( g_object_get_data(hObj, "window") )
      {
         gtk_window_present(static_cast<GtkWindow*>(HB_PARHANDLE(1)));
      }
      else
      {
         gtk_widget_grab_focus(static_cast<GtkWidget*>(HB_PARHANDLE(1)));
      }
   }

   HB_RETHANDLE(handle);
}

HB_FUNC( HWG_GETFOCUS )
{
   HB_RETHANDLE(gtk_window_get_focus(gtk_window_list_toplevels()->data));
}

HB_FUNC( HWG_DESTROYWINDOW )
{
   gtk_widget_destroy(static_cast<GtkWidget*>(HB_PARHANDLE(1)));
}

void hwg_set_modal(GtkWindow * hDlg, GtkWindow * hParent)
{
   gtk_window_set_modal(hDlg, 1);
   if( hParent )
   {
      gtk_window_set_transient_for(hDlg, hParent);
   }
}

HB_FUNC( HWG_SET_MODAL )
{
   hwg_set_modal(static_cast<GtkWindow*>(HB_PARHANDLE(1)), static_cast<GtkWindow*>((!HB_ISNIL(2)) ? HB_PARHANDLE(2) : nullptr));
}

HB_FUNC( HWG_WINDOWSETRESIZE )
{
   GtkWindow * handle = static_cast<GtkWindow*>(HB_PARHANDLE(1));
   gint width = 0, height = 0, bResize = hb_parl(2);

   //if( !bResize )
   //{
      gtk_window_get_size(handle, &width, &height);
      gtk_widget_set_size_request(reinterpret_cast<GtkWidget*>(handle), width, height);
   //}
   gtk_window_set_resizable(handle, bResize);
}

HB_FUNC( HWG_WINDOWSETDECORATED )
{
   GtkWindow * handle = static_cast<GtkWindow*>(HB_PARHANDLE(1));
   gtk_window_set_decorated(handle ,hb_parl(2));
}

HB_FUNC( HWG_SETTOPMOST )
{
   gtk_window_set_keep_above(static_cast<GtkWindow*>(HB_PARHANDLE(1)), TRUE);
}

HB_FUNC( HWG_REMOVETOPMOST )
{
   gtk_window_set_keep_above(static_cast<GtkWindow*>(HB_PARHANDLE(1)), FALSE);
}

HB_FUNC( HWG_GETWINDOWPOS )
{
   gint x, y;
   PHB_ITEM aMetr = hb_itemArrayNew(2);
   gtk_window_get_position(static_cast<GtkWindow*>(HB_PARHANDLE(1)), &x, &y);
   hb_itemPutNL(hb_arrayGetItemPtr(aMetr, 1), x);
   hb_itemPutNL(hb_arrayGetItemPtr(aMetr, 2), y);
   hb_itemRelease(hb_itemReturn(aMetr));
}

gchar * hwg_convert_to_utf8( const char * szText )
{
   if( *szAppLocale )
   {
      return g_convert(szText, -1, "UTF-8", szAppLocale, nullptr, nullptr, nullptr);
   }
   else
   {
      return g_locale_to_utf8(szText, -1, nullptr, nullptr, nullptr);
   }
}

gchar * hwg_convert_from_utf8(const char * szText)
{
   if( *szAppLocale )
   {
      return g_convert(szText, -1, szAppLocale, "UTF-8", nullptr, nullptr, nullptr);
   }
   else
   {
      return g_locale_from_utf8(szText, -1, nullptr, nullptr, nullptr);
   }
}

HB_FUNC( HWG_SETAPPLOCALE )
{
   const char * szLocale = hb_parc(1);
   int iLen = hb_parclen(1);
   hb_retc(szAppLocale);
   memcpy(szAppLocale, szLocale, iLen);
   szAppLocale[iLen] = '\0';
}

HB_FUNC( HWG_KEYTOUTF8 )
{
   char utf8string[10];
   int iLen;
   iLen = g_unichar_to_utf8(gdk_keyval_to_unicode(hb_parnl(1)), utf8string);
   utf8string[iLen] = '\0';
   hb_retc(utf8string);
}

HB_FUNC( HWG_SEND_KEY )
{
   gtk_test_widget_send_key(static_cast<GtkWidget*>(HB_PARHANDLE(1)), static_cast<guint>(hb_parni(2)), static_cast<GdkModifierType>(hb_parni(3)));
}

static gint snooper(GtkWidget * grab_widget, GdkEventKey * event, gpointer func_data)
{
   GtkWidget * window = GetActiveWindow();

   HB_SYMBOL_UNUSED(func_data);
   if( window && event->type == GDK_KEY_RELEASE )
   {
      PHB_ITEM pObject = static_cast<PHB_ITEM>(g_object_get_data(reinterpret_cast<GObject*>(window), "obj"));
      if( !pSym_keylist )
      {
         pSym_keylist = hb_dynsymFindName("EVALKEYLIST");
      }

      if( pObject && pSym_keylist && hb_objHasMessage(pObject, pSym_keylist) )
      {
         HB_LONG p2;
         hb_vmPushSymbol(hb_dynsymSymbol(pSym_keylist));
         hb_vmPush(pObject);
         hb_vmPushLong(static_cast<HB_LONG>((static_cast<GdkEventKey*>(event))->keyval));
         p2 = (((static_cast<GdkEventKey*>(event))->state & GDK_SHIFT_MASK) ? 1 : 0) |
              (((static_cast<GdkEventKey*>(event))->state & GDK_CONTROL_MASK) ? 2 : 0) |
              (((static_cast<GdkEventKey*>(event))->state & GDK_MOD1_MASK) ? 4 : 0);
         hb_vmPushLong(static_cast<HB_LONG>(p2));
         hb_vmSend(2);
      }
   }

   return FALSE;
}

HB_FUNC( HWG__ISUNICODE )
{
/* Windows */
#if defined(_WIN32) || defined(_WIN64) || defined(__MINGW32__) || defined(__MINGW64__)
#ifdef UNICODE
   hb_retl(1);
#else
   hb_retl(0);
#endif
#else
/* *NIX */
   hb_retl(1);
#endif
}

HB_FUNC( HWG_INITPROC )
{
   s_KeybHook = gtk_key_snooper_install(&snooper, nullptr);
}

HB_FUNC( HWG_EXITPROC )
{
   gtk_key_snooper_remove(s_KeybHook);
}

HB_FUNC( HWG_DEICONIFY ) /* maximize  */
{
   gtk_window_deiconify(static_cast<GtkWindow*>(HB_PARHANDLE(1)));
}

HB_FUNC( HWG_ICONIFY )   /* minimize */
{
   gtk_window_iconify(static_cast<GtkWindow*>(HB_PARHANDLE(1)));
}

/*
 * ShellModifyIcon(hWnd,  hIcon)
 * TOOLTIP not supported
 * Comment out for experimental purposes
 */
/*
HB_FUNC( HWG_SHELLMODIFYICON )
{
   PHWGUI_PIXBUF szFile = HB_ISPOINTER(2) ? static_cast<PHWGUI_PIXBUF>(HB_PARHANDLE(2)) : nullptr;
   if( szFile )
   {
      gtk_window_set_icon(static_cast<GtkWindow*>(HB_PARHANDLE(1)), szFile->handle);
      gtk_window_set_default_icon(szFile->handle);
      gtk_window_iconify(static_cast<GtkWindow*>(HB_PARHANDLE(1)));
      gtk_window_deiconify(static_cast<GtkWindow*>(HB_PARHANDLE(1)));
   }
}
*/
