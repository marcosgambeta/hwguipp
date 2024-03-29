/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * Widget creation functions
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 *
 * StatusBar /ProgressBar and monthCalendar Functions
 *
 * Copyright 2008 Luiz Rafael Culik Guimaraes <luiz at xharbour.com.br >
 * www - http://sites.uol.com.br/culikr/
 */

#include "guilib.hpp"
#include <hbapifs.hpp>
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include "item.api"

#include <cairo.h>
#include "gtk/gtk.h"

#include "hwgtk.hpp"
#include <hbdate.hpp>
/* Avoid warnings from GCC */
#include "warnings.hpp"

#define SS_CENTER 1
#define SS_RIGHT 2
#define ES_PASSWORD 32
#define ES_MULTILINE 4
#define ES_READONLY 2048

#define BS_AUTO3STATE 6
#define BS_GROUPBOX 7
#define BS_AUTORADIOBUTTON 9

#define SS_OWNERDRAW 13

#define WM_PAINT 15
#define WM_HSCROLL 276
#define WM_VSCROLL 277
#define WM_USER 1024
#define WS_EX_TRANSPARENT 32

extern PHB_ITEM GetObjectVar(PHB_ITEM pObject, const char *varname);
extern void SetObjectVar(PHB_ITEM pObject, const char *varname, PHB_ITEM pValue);
extern void SetWindowObject(GtkWidget *hWnd, PHB_ITEM pObject);
extern void set_signal(gpointer handle, const char *cSignal, long int p1, long int p2, long int p3);
extern void set_event(gpointer handle, const char *cSignal, long int p1, long int p2, long int p3);
extern void cb_signal(GtkWidget *widget, gchar *data);
extern void all_signal_connect(gpointer hWnd);
extern GtkWidget *GetActiveWindow(void);
extern GdkPixbuf *alpha2pixbuf(GdkPixbuf *hPixIn, long int nColor);

static PHB_DYNS pSymTimerProc = nullptr;
static PHB_DYNS pSym_onEvent = nullptr;
static GtkWidget *h4stock = nullptr;

GtkFixed *getFixedBox(GObject *handle)
{
  return static_cast<GtkFixed *>(g_object_get_data(handle, "fbox"));
}

void hwg_colorN2C(unsigned int lColor, char *szColor)
{
  char c;
  sprintf(szColor, "%06x", lColor);
  c = szColor[0];
  szColor[0] = szColor[4];
  szColor[4] = c;
  c = szColor[1];
  szColor[1] = szColor[5];
  szColor[5] = c;
}

#if GTK_MAJOR_VERSION - 0 > 2
void set_css_data(char *szData)
{
  GtkCssProvider *provider = gtk_css_provider_new();
  GdkDisplay *display = gdk_display_get_default();
  GdkScreen *screen = gdk_display_get_default_screen(display);

  gtk_style_context_add_provider_for_screen(screen, GTK_STYLE_PROVIDER(provider),
                                            GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);

  gtk_css_provider_load_from_data(GTK_CSS_PROVIDER(provider), szData, -1, nullptr);
  g_object_unref(provider);
}
#endif

GtkWidget *getDrawing(GObject *handle)
{
  return static_cast<GtkWidget *>(g_object_get_data(handle, "draw"));
}

HB_FUNC(HWG_GETDRAWING)
{
  hb_retptr(getDrawing(static_cast<GObject *>(hb_parptr(1))));
}

HB_FUNC(HWG_STOCKBITMAP)
{
  PHWGUI_PIXBUF hpix;
  GdkPixbuf *handle;

  if (!h4stock)
  {
    h4stock = gtk_drawing_area_new();
  }

  handle = gtk_widget_render_icon(h4stock, hb_parc(1), ((HB_ISNIL(2)) ? GTK_ICON_SIZE_BUTTON : hb_parni(2)), nullptr);
  if (handle)
  {
    hpix = static_cast<PHWGUI_PIXBUF>(hb_xgrab(sizeof(HWGUI_PIXBUF)));
    hpix->type = HWGUI_OBJECT_PIXBUF;
    hpix->handle = handle;
    hpix->trcolor = -1;
    hb_retptr(hpix);
  }
}

/*
CreateStatic(hParentWindow, nControlID, nStyle, x, y, nWidth, nHeight, nExtStyle, cTitle)
*/
HB_FUNC(HWG_CREATESTATIC)
{
  HB_ULONG ulStyle = hb_parnl(3);
  const char *cTitle = (hb_pcount() > 8) ? hb_parc(9) : "";
  GtkWidget *hCtrl, *hLabel;
  GtkFixed *box;
  HB_ULONG ulExtStyle = hb_parnl(8);

  if ((ulStyle & SS_OWNERDRAW) == SS_OWNERDRAW)
  {
    hCtrl = gtk_drawing_area_new();
    g_object_set_data(reinterpret_cast<GObject *>(hCtrl), "draw", static_cast<gpointer>(hCtrl));
  }
  else
  {
    gchar *gcTitle = hwg_convert_to_utf8(cTitle);
    hCtrl = gtk_event_box_new();
    hLabel = gtk_label_new(gcTitle);
    g_free(gcTitle);
    gtk_container_add(GTK_CONTAINER(hCtrl), hLabel);
    g_object_set_data(reinterpret_cast<GObject *>(hCtrl), "label", static_cast<gpointer>(hLabel));
    if (ulExtStyle & WS_EX_TRANSPARENT)
    {
      gtk_event_box_set_visible_window(GTK_EVENT_BOX(hCtrl), 0);
    }

    if (!(ulStyle & SS_CENTER))
    {
      gtk_misc_set_alignment(GTK_MISC(hLabel), (ulStyle & SS_RIGHT) ? 1 : 0, 0);
    }
  }
  box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));
  if (box)
  {
    gtk_fixed_put(box, hCtrl, hb_parni(4), hb_parni(5));
  }
  gtk_widget_set_size_request(hCtrl, hb_parni(6), hb_parni(7));

  if ((ulStyle & SS_OWNERDRAW) == SS_OWNERDRAW)
  {
#if GTK_MAJOR_VERSION - 0 < 3
    set_event(static_cast<gpointer>(hCtrl), "expose_event", WM_PAINT, 0, 0);
#else
    set_event(static_cast<gpointer>(hCtrl), "draw", WM_PAINT, 0, 0);
#endif
  }
  hb_retptr(hCtrl);
}

HB_FUNC(HWG_STATIC_SETTEXT)
{
  gchar *gcTitle = hwg_convert_to_utf8(hb_parcx(2));
  auto hLabel = static_cast<GtkLabel *>(g_object_get_data(static_cast<GObject *>(hb_parptr(1)), "label"));
  gtk_label_set_text(hLabel, gcTitle);
  g_free(gcTitle);
}

HB_FUNC(HWG_STATIC_GETTEXT)
{
  hb_retc(const_cast<char *>(gtk_label_get_text(g_object_get_data(static_cast<GObject *>(hb_parptr(1)), "label"))));
}

/*
hwg_CreateButton(hParentWindow, nButtonID, nStyle, x, y, nWidth, nHeight, cCaption, hpixbuf)
*/
HB_FUNC(HWG_CREATEBUTTON)
{
  GtkWidget *hCtrl, *img;
  HB_ULONG ulStyle = hb_parnl(3);
  const char *cTitle = (hb_pcount() > 7) ? hb_parc(8) : "";
  GtkFixed *box;
  PHWGUI_PIXBUF szFile = HB_ISPOINTER(9) ? static_cast<PHWGUI_PIXBUF>(hb_parptr(9)) : nullptr;
  gchar *gcTitle = hwg_convert_to_utf8(cTitle);

  if ((ulStyle & 0xf) == BS_AUTORADIOBUTTON)
  {
    auto group = static_cast<GSList *>(hb_parptr(2));
    hCtrl = gtk_radio_button_new_with_label(group, gcTitle);
    group = gtk_radio_button_get_group(reinterpret_cast<GtkRadioButton *>(hCtrl));
    hb_storptr(group, 2);
  }
  else if ((ulStyle & 0xf) == BS_AUTO3STATE)
  {
    hCtrl = gtk_check_button_new_with_label(gcTitle);
  }
  else if ((ulStyle & 0xf) == BS_GROUPBOX)
  {
    hCtrl = gtk_frame_new(gcTitle);
  }
  else
  {
    hCtrl = gtk_button_new_with_mnemonic(gcTitle);
  }

#if GTK_CHECK_VERSION(2, 4, 1)
  if (szFile)
  {
    img = gtk_image_new_from_pixbuf(szFile->handle);
    gtk_button_set_image(GTK_BUTTON(hCtrl), img);
  }
#endif
  g_free(gcTitle);
  box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));
  if (box)
  {
    gtk_fixed_put(box, hCtrl, hb_parni(4), hb_parni(5));
  }
  gtk_widget_set_size_request(hCtrl, hb_parni(6), hb_parni(7));

  hb_retptr(hCtrl);
}

HB_FUNC(HWG_BUTTON_SETTEXT)
{
  gchar *gcTitle = hwg_convert_to_utf8(hb_parcx(2));
  auto hBtn = static_cast<GtkWidget *>(hb_parptr(1));

  gtk_button_set_label(reinterpret_cast<GtkButton *>(hBtn), gcTitle);
  g_free(gcTitle);
}

HB_FUNC(HWG_BUTTON_GETTEXT)
{
  hb_retc(const_cast<char *>(gtk_button_get_label(static_cast<GtkButton *>(hb_parptr(1)))));
}

HB_FUNC(HWG_CHECKBUTTON)
{
  gtk_toggle_button_set_active(static_cast<GtkToggleButton *>(hb_parptr(1)), hb_parl(2));
}

HB_FUNC(HWG_ISBUTTONCHECKED)
{
  hb_retl(gtk_toggle_button_get_active(static_cast<GtkToggleButton *>(hb_parptr(1))));
}

/*
CreateEdit(hParentWIndow, nEditControlID, nStyle, x, y, nWidth, nHeight, cInitialString)
*/
HB_FUNC(HWG_CREATEEDIT)
{
  GtkWidget *hCtrl;
  const char *cTitle = (hb_pcount() > 7) ? hb_parc(8) : "";
  unsigned long ulStyle = (HB_ISNIL(3)) ? 0 : hb_parnl(3);

  if (ulStyle & ES_MULTILINE)
  {
    hCtrl = gtk_text_view_new();
    g_object_set_data(reinterpret_cast<GObject *>(hCtrl), "multi", reinterpret_cast<gpointer>(1));
    if (ulStyle & ES_READONLY)
    {
      gtk_text_view_set_editable(reinterpret_cast<GtkTextView *>(hCtrl), 0);
    }
    gtk_text_view_set_wrap_mode(GTK_TEXT_VIEW(hCtrl), GTK_WRAP_WORD_CHAR);
  }
  else
  {
    hCtrl = gtk_entry_new();
    if (ulStyle & ES_PASSWORD)
    {
      gtk_entry_set_visibility(reinterpret_cast<GtkEntry *>(hCtrl), FALSE);
    }
  }

  GtkFixed *box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));
  if (box)
  {
    gtk_fixed_put(box, hCtrl, hb_parni(4), hb_parni(5));
  }
  gtk_widget_set_size_request(hCtrl, hb_parni(6), hb_parni(7));

  if (*cTitle)
  {
    gchar *gcTitle = hwg_convert_to_utf8(cTitle);
    if (ulStyle & ES_MULTILINE)
    {
      GtkTextBuffer *buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(hCtrl));
      gtk_text_buffer_set_text(buffer, gcTitle, -1);
    }
    else
    {
      gtk_entry_set_text(reinterpret_cast<GtkEntry *>(hCtrl), gcTitle);
    }
    g_free(gcTitle);
  }

  gtk_widget_add_events(hCtrl, GDK_BUTTON_PRESS_MASK);
  set_event(static_cast<gpointer>(hCtrl), "button_press_event", 0, 0, 0);

  all_signal_connect(static_cast<gpointer>(hCtrl));
  hb_retptr(hCtrl);
}

HB_FUNC(HWG_EDIT_SETTEXT)
{
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  gchar *gcTitle = hwg_convert_to_utf8(hb_parcx(2));

  if (g_object_get_data(reinterpret_cast<GObject *>(hCtrl), "multi"))
  {
    GtkTextBuffer *buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(hCtrl));
    gtk_text_buffer_set_text(buffer, gcTitle, -1);
  }
  else
  {
    gtk_entry_set_text(reinterpret_cast<GtkEntry *>(hCtrl), gcTitle);
  }
  g_free(gcTitle);
}

HB_FUNC(HWG_EDIT_GETTEXT)
{
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  char *cptr;

  if (g_object_get_data(reinterpret_cast<GObject *>(hCtrl), "multi"))
  {
    GtkTextBuffer *buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(hCtrl));
    GtkTextIter iterStart, iterEnd;

    gtk_text_buffer_get_start_iter(buffer, &iterStart);
    gtk_text_buffer_get_end_iter(buffer, &iterEnd);
    cptr = gtk_text_buffer_get_text(buffer, &iterStart, &iterEnd, 1);
  }
  else
  {
    cptr = const_cast<char *>(gtk_entry_get_text(reinterpret_cast<GtkEntry *>(hCtrl)));
  }

  if (*cptr)
  {
    cptr = hwg_convert_from_utf8(cptr);
    hb_retc(cptr);
    g_free(cptr);
  }
  else
  {
    hb_retc("");
  }
}

HB_FUNC(HWG_EDIT_SETPOS)
{
  gtk_editable_set_position(static_cast<GtkEditable *>(hb_parptr(1)), hb_parni(2));
}

HB_FUNC(HWG_EDIT_GETPOS)
{
  hb_retni(gtk_editable_get_position(static_cast<GtkEditable *>(hb_parptr(1))));
}

HB_FUNC(HWG_EDIT_GETSELPOS)
{
  gint start, end;
  if (gtk_editable_get_selection_bounds((static_cast<GtkEditable *>(hb_parptr(1))), &start, &end))
  {
    auto aSel = hb_itemArrayNew(2);

    auto temp = hb_itemPutNL(nullptr, start);
    hb_itemArrayPut(aSel, 1, temp);
    hb_itemRelease(temp);

    temp = hb_itemPutNL(nullptr, end);
    hb_itemArrayPut(aSel, 2, temp);
    hb_itemRelease(temp);

    hb_itemReturn(aSel);
    hb_itemRelease(aSel);
  }
}

HB_FUNC(HWG_EDIT_SET_OVERMODE)
{
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  gboolean bOver;

  if (g_object_get_data(reinterpret_cast<GObject *>(hCtrl), "multi"))
  {
    bOver = gtk_text_view_get_overwrite((reinterpret_cast<GtkTextView *>(hCtrl)));
    if (!(HB_ISNIL(2)))
    {
      gtk_text_view_set_overwrite((reinterpret_cast<GtkTextView *>(hCtrl)), hb_parl(2));
    }
  }
  else
  {
    bOver = gtk_entry_get_overwrite_mode((reinterpret_cast<GtkEntry *>(hCtrl)));
    if (!(HB_ISNIL(2)))
    {
      gtk_entry_set_overwrite_mode((reinterpret_cast<GtkEntry *>(hCtrl)), hb_parl(2));
    }
  }
  hb_retl(bOver);
}

/*
CreateCombo(hParentWIndow, nComboID, nStyle, x, y, nWidth, nHeight)
*/
HB_FUNC(HWG_CREATECOMBO)
{
  GtkWidget *hCtrl;
  gint iText = ((hb_parni(3) & 1) == 0);
  GtkFixed *box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));

#if GTK_MAJOR_VERSION - 0 < 3
  hCtrl = gtk_combo_box_entry_new_text();
#else
  hCtrl = gtk_combo_box_text_new_with_entry();
#endif
  if (!iText)
  {
    gtk_editable_set_editable(reinterpret_cast<GtkEditable *>(gtk_bin_get_child(reinterpret_cast<GtkBin *>(hCtrl))),
                              FALSE);
    // hCtrl = gtk_combo_box_new_text();
  }
  if (box)
  {
    gtk_fixed_put(box, hCtrl, hb_parni(4), hb_parni(5));
  }
  gtk_widget_set_size_request(hCtrl, hb_parni(6), hb_parni(7));

  hb_retptr(hCtrl);
}

HB_FUNC(HWG_COMBOSETARRAY)
{
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  auto pArray = hb_param(2, Harbour::Item::ARRAY);
  HB_ULONG ulKol;

  if (pArray)
  {
    HB_ULONG ulLen = hb_arrayLen(pArray);
    char *cItem;

    ulKol = reinterpret_cast<HB_ULONG>(g_object_get_data(reinterpret_cast<GObject *>(hCtrl), "kol"));
    for (HB_ULONG ul = 1; ul <= ulKol; ++ul)
    {
#if GTK_MAJOR_VERSION - 0 < 3
      gtk_combo_box_remove_text(reinterpret_cast<GtkComboBox *>(hCtrl), 0);
#else
      gtk_combo_box_text_remove(static_cast<GtkComboBox *>(hCtrl), 0);
#endif
    }
    for (HB_ULONG ul = 1; ul <= ulLen; ++ul)
    {
      if (hb_arrayGetType(pArray, ul) & Harbour::Item::ARRAY)
      {
        cItem = hwg_convert_to_utf8(hb_arrayGetCPtr(hb_arrayGetItemPtr(pArray, ul), 1));
      }
      else
      {
        cItem = hwg_convert_to_utf8(hb_arrayGetCPtr(pArray, ul));
      }
#if GTK_MAJOR_VERSION - 0 < 3
      gtk_combo_box_append_text(reinterpret_cast<GtkComboBox *>(hCtrl), cItem);
#else
      gtk_combo_box_text_append(static_cast<GtkComboBox *>(hCtrl), nullptr, cItem);
#endif
    }
    g_object_set_data(reinterpret_cast<GObject *>(hCtrl), "kol", reinterpret_cast<gpointer>(ulLen));
  }
}

HB_FUNC(HWG_COMBOSET)
{
  gtk_combo_box_set_active(static_cast<GtkComboBox *>(hb_parptr(1)), hb_parni(2) - 1);
}

HB_FUNC(HWG_COMBOGET)
{
  gint i = gtk_combo_box_get_active(static_cast<GtkComboBox *>(hb_parptr(1))) + 1;
  if (i <= 0)
  {
    i = 1;
  }
  hb_retni(i);
}

HB_FUNC(HWG_COMBOPOPUP)
{
  gtk_combo_box_popup(static_cast<GtkComboBox *>(hb_parptr(1)));
}

/*
HB_FUNC( HWG_COMBOGETEDIT )
{
   hb_retptr(static_cast<void*>((GTK_ENTRY(GTK_BIN(hb_parptr(1))->child))));
}
*/

/*
HB_FUNC( HWG_COMBOSETSTRING )
{
   gtk_entry_set_text(GTK_ENTRY(GTK_COMBO(hb_parnl(1))->entry), hb_parc(2));
}

HB_FUNC( HWG_COMBOGETSTRING )
{
   gtk_entry_get_text(GTK_ENTRY(GTK_COMBO(hb_parnl(1))->entry));
}
*/

HB_FUNC(HWG_CREATEUPDOWNCONTROL)
{
#if GTK_MAJOR_VERSION - 0 < 3
  GtkObject *adj;
#else
  GtkAdjustment *adj;
#endif
  adj = gtk_adjustment_new(static_cast<gdouble>(hb_parnl(6)), static_cast<gdouble>(hb_parnl(7)),
                           static_cast<gdouble>(hb_parnl(8)), 1, 1, 1);
  GtkWidget *hCtrl = gtk_spin_button_new(reinterpret_cast<GtkAdjustment *>(adj), 0.5, 0);

  GtkFixed *box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));
  if (box)
  {
    gtk_fixed_put(box, hCtrl, hb_parni(2), hb_parni(3));
  }
  gtk_widget_set_size_request(hCtrl, hb_parni(4), hb_parni(5));

  hb_retptr(hCtrl);
}

HB_FUNC(HWG_SETUPDOWN)
{
  gtk_spin_button_set_value(static_cast<GtkSpinButton *>(hb_parptr(1)), static_cast<gdouble>(hb_parnl(2)));
}

HB_FUNC(HWG_GETUPDOWN)
{
  hb_retnl(gtk_spin_button_get_value_as_int(static_cast<GtkSpinButton *>(hb_parptr(1))));
}

HB_FUNC(HWG_SETRANGEUPDOWN)
{
  gtk_spin_button_set_range(static_cast<GtkSpinButton *>(hb_parptr(1)), static_cast<gdouble>(hb_parnl(2)),
                            static_cast<gdouble>(hb_parnl(3)));
}

#define WS_VSCROLL 2097152 // 0x00200000L
#define WS_HSCROLL 1048576 // 0x00100000L

HB_FUNC(HWG_CREATEBROWSE)
{
  GtkWidget *vbox, *hbox;
  GtkWidget *vscroll, *hscroll;
  GtkWidget *area;
  GtkFixed *box;
  auto pObject = hb_param(1, Harbour::Item::OBJECT);
  auto nLeft = hb_itemGetNI(GetObjectVar(pObject, "NLEFT"));
  auto nTop = hb_itemGetNI(GetObjectVar(pObject, "NTOP"));
  auto nWidth = hb_itemGetNI(GetObjectVar(pObject, "NWIDTH"));
  auto nHeight = hb_itemGetNI(GetObjectVar(pObject, "NHEIGHT"));
  unsigned long int ulStyle = hb_itemGetNL(GetObjectVar(pObject, "STYLE"));

  auto temp = GetObjectVar(pObject, "OPARENT");
  auto handle = static_cast<GObject *>(hb_itemGetPtr(GetObjectVar(temp, "HANDLE")));

  hbox = gtk_hbox_new(FALSE, 0);
  vbox = gtk_vbox_new(FALSE, 0);

  area = gtk_drawing_area_new();

  gtk_box_pack_start(GTK_BOX(hbox), vbox, TRUE, TRUE, 0);
  if (ulStyle & WS_VSCROLL)
  {
#if GTK_MAJOR_VERSION - 0 < 3
    GtkObject *adjV;
#else
    GtkAdjustment *adjV;
#endif
    adjV = gtk_adjustment_new(0.0, 0.0, 101.0, 1.0, 10.0, 10.0);
    vscroll = gtk_vscrollbar_new(GTK_ADJUSTMENT(adjV));
    gtk_box_pack_end(GTK_BOX(hbox), vscroll, FALSE, FALSE, 0);

    temp = hb_itemPutPtr(nullptr, adjV);
    SetObjectVar(pObject, "_HSCROLLV", temp);
    hb_itemRelease(temp);

    SetWindowObject(reinterpret_cast<GtkWidget *>(adjV), pObject);
    set_signal(static_cast<gpointer>(adjV), "value_changed", WM_VSCROLL, 0, 0);
  }

  gtk_box_pack_start(GTK_BOX(vbox), area, TRUE, TRUE, 0);
  if (ulStyle & WS_HSCROLL)
  {
#if GTK_MAJOR_VERSION - 0 < 3
    GtkObject *adjH;
#else
    GtkAdjustment *adjH;
#endif
    adjH = gtk_adjustment_new(0.0, 0.0, 101.0, 1.0, 10.0, 10.0);
    hscroll = gtk_hscrollbar_new(GTK_ADJUSTMENT(adjH));
    gtk_box_pack_end(GTK_BOX(vbox), hscroll, FALSE, FALSE, 0);

    temp = hb_itemPutPtr(nullptr, adjH);
    SetObjectVar(pObject, "_HSCROLLH", temp);
    hb_itemRelease(temp);

    SetWindowObject(reinterpret_cast<GtkWidget *>(adjH), pObject);
    set_signal(static_cast<gpointer>(adjH), "value_changed", WM_HSCROLL, 0, 0);
  }

  box = getFixedBox(handle);
  if (box)
  {
    gtk_fixed_put(box, hbox, nLeft, nTop);
  }
  gtk_widget_set_size_request(hbox, nWidth, nHeight);

  temp = hb_itemPutPtr(nullptr, area);
  SetObjectVar(pObject, "_AREA", temp);
  hb_itemRelease(temp);

  SetWindowObject(area, pObject);
#if GTK_MAJOR_VERSION - 0 < 3
  set_event(static_cast<gpointer>(area), "expose_event", WM_PAINT, 0, 0);
#else
  set_event(static_cast<gpointer>(area), "draw", WM_PAINT, 0, 0);
#endif

  gtk_widget_set_can_focus(area, 1);
  // GTK_WIDGET_SET_FLAGS(area, GTK_CAN_FOCUS);

  gtk_widget_add_events(area, GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK | GDK_KEY_PRESS_MASK |
                                  GDK_KEY_RELEASE_MASK | GDK_POINTER_MOTION_MASK | GDK_SCROLL_MASK |
                                  GDK_FOCUS_CHANGE_MASK);
  set_event(static_cast<gpointer>(area), "button_press_event", 0, 0, 0);
  set_event(static_cast<gpointer>(area), "button_release_event", 0, 0, 0);
  set_event(static_cast<gpointer>(area), "motion_notify_event", 0, 0, 0);
  set_event(static_cast<gpointer>(area), "key_press_event", 0, 0, 0);
  set_event(static_cast<gpointer>(area), "key_release_event", 0, 0, 0);
  set_event(static_cast<gpointer>(area), "scroll_event", 0, 0, 0);
  set_event(static_cast<gpointer>(area), "focus_in_event", 0, 0, 0);
  set_event(static_cast<gpointer>(area), "focus_out_event", 0, 0, 0);

  // gtk_widget_show_all(hbox);
  all_signal_connect(static_cast<gpointer>(area));
  g_object_set_data(reinterpret_cast<GObject *>(hbox), "draw", static_cast<gpointer>(area));
  hb_retptr(hbox);
}

HB_FUNC(HWG_GETADJVALUE)
{
  auto adj = static_cast<GtkAdjustment *>(hb_parptr(1));
  int iOption = (HB_ISNIL(2)) ? 0 : hb_parni(2);

  if (iOption == 0)
  {
    hb_retnl(static_cast<HB_LONG>(gtk_adjustment_get_value(adj)));
  }
  else if (iOption == 1)
  {
    hb_retnl(static_cast<HB_LONG>(gtk_adjustment_get_upper(adj)));
  }
  else if (iOption == 2)
  {
    hb_retnl(static_cast<HB_LONG>(gtk_adjustment_get_step_increment(adj)));
  }
  else if (iOption == 3)
  {
    hb_retnl(static_cast<HB_LONG>(gtk_adjustment_get_page_increment(adj)));
  }
  else if (iOption == 4)
  {
    hb_retnl(static_cast<HB_LONG>(gtk_adjustment_get_page_size(adj)));
  }
  else
  {
    hb_retnl(0);
  }
}

/*
 * hwg_SetAdjOptions(hAdj, value, maxpos, step, pagestep, pagesize)
 */
HB_FUNC(HWG_SETADJOPTIONS)
{
  auto adj = static_cast<GtkAdjustment *>(hb_parptr(1));
  gdouble value;
  auto lChanged = 0;

  if (!HB_ISNIL(2) && ((value = static_cast<gdouble>(hb_parnl(2))) != gtk_adjustment_get_value(adj)))
  {
    gtk_adjustment_set_value(adj, value);
    lChanged = 1;
  }
  if (!HB_ISNIL(3) && ((value = static_cast<gdouble>(hb_parnl(3))) != gtk_adjustment_get_upper(adj)))
  {
    gtk_adjustment_set_upper(adj, value);
    lChanged = 1;
  }
  if (!HB_ISNIL(4) && ((value = static_cast<gdouble>(hb_parnl(4))) != gtk_adjustment_get_step_increment(adj)))
  {
    gtk_adjustment_set_step_increment(adj, value);
    lChanged = 1;
  }
  if (!HB_ISNIL(5) && ((value = static_cast<gdouble>(hb_parnl(5))) != gtk_adjustment_get_page_increment(adj)))
  {
    gtk_adjustment_set_page_increment(adj, value);
    lChanged = 1;
  }
  if (!HB_ISNIL(6) && ((value = static_cast<gdouble>(hb_parnl(6))) != gtk_adjustment_get_page_size(adj)))
  {
    gtk_adjustment_set_page_size(adj, value);
    lChanged = 1;
  }
  // if( lChanged ) {
  //    gtk_adjustment_changed(adj);
  // }
  hb_retl(lChanged);
}

void cb_signal_tab(GtkNotebook *notebook, GtkWidget *page, guint page_num, gpointer user_data)
{
  gpointer gObject = g_object_get_data(reinterpret_cast<GObject *>(notebook), "obj");

  HB_SYMBOL_UNUSED(page);
  HB_SYMBOL_UNUSED(user_data);

  if (!pSym_onEvent)
  {
    pSym_onEvent = hb_dynsymFindName("ONEVENT");
  }

  if (pSym_onEvent && gObject)
  {
    hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
    hb_vmPush(static_cast<PHB_ITEM>(gObject));
    hb_vmPushLong(WM_USER);
    hb_vmPushLong(static_cast<HB_LONG>(page_num) + 1);
    hb_vmPushLong(static_cast<HB_LONG>(0));
    hb_vmSend(3);
  }
}

HB_FUNC(HWG_CREATETABCONTROL)
{
  GtkWidget *hCtrl = gtk_notebook_new();

  GtkFixed *box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));
  if (box)
  {
    gtk_fixed_put(box, hCtrl, hb_parni(4), hb_parni(5));
  }
  gtk_widget_set_size_request(hCtrl, hb_parni(6), hb_parni(7));

  g_signal_connect(hCtrl, "switch-page", G_CALLBACK(cb_signal_tab), nullptr);

  hb_retptr(hCtrl);
}

HB_FUNC(HWG_ADDTAB)
{
  auto nb = static_cast<GtkNotebook *>(hb_parptr(1));
  GtkWidget *box = gtk_fixed_new();
  GtkWidget *hLabel;
  char *cLabel = hwg_convert_to_utf8(hb_parc(2));

  hLabel = gtk_label_new(cLabel);
  g_free(cLabel);

  gtk_notebook_append_page(nb, box, hLabel);

  g_object_set_data(reinterpret_cast<GObject *>(nb), "fbox", static_cast<gpointer>(box));

  hb_retptr(nb);
}

HB_FUNC(HWG_DELETETAB)
{
  gtk_notebook_remove_page(static_cast<GtkNotebook *>(hb_parptr(1)), hb_parni(2) - 1);
}

HB_FUNC(HWG_SETTABNAME)
{
  auto nb = static_cast<GtkNotebook *>(hb_parptr(1));
  gchar *gcTitle = hwg_convert_to_utf8(hb_parc(3));

  gtk_notebook_set_tab_label_text(nb, gtk_notebook_get_nth_page(nb, hb_parni(2) - 1), gcTitle);
  g_free(gcTitle);
}

HB_FUNC(HWG_SETCURRENTTAB)
{
  gtk_notebook_set_current_page(static_cast<GtkNotebook *>(hb_parptr(1)), hb_parni(2) - 1);
}

HB_FUNC(HWG_GETCURRENTTAB)
{
  hb_retni(gtk_notebook_get_current_page(static_cast<GtkNotebook *>(hb_parptr(1))) + 1);
}

HB_FUNC(HWG_CREATESEP)
{
  HB_BOOL lVert = hb_parl(2);
  GtkWidget *hCtrl;
  GtkFixed *box;

  if (lVert)
  {
    hCtrl = gtk_vseparator_new();
  }
  else
  {
    hCtrl = gtk_hseparator_new();
  }
  box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));
  if (box)
  {
    gtk_fixed_put(box, hCtrl, hb_parni(3), hb_parni(4));
  }
  gtk_widget_set_size_request(hCtrl, hb_parni(5), hb_parni(6));

  hb_retptr(hCtrl);
}

/*
CreatePanel(hParentWindow, nControlID, nStyle, x, y, nWidth, nHeight, nExtStyle, cTitle)
*/
HB_FUNC(HWG_CREATEPANEL)
{
  GtkWidget *vbox, *hbox;
  GtkWidget *vscroll = nullptr, *hscroll = nullptr;
  GtkWidget *hCtrl;
  GtkFixed *box;
  auto pObject = hb_param(1, Harbour::Item::OBJECT);
  HB_ULONG ulStyle = hb_parnl(3);
  gint nWidth = hb_parnl(6), nHeight = hb_parnl(7);

  auto temp = GetObjectVar(pObject, "OPARENT");
  auto handle = static_cast<GObject *>(hb_itemGetPtr(GetObjectVar(temp, "HANDLE")));

  auto fbox = reinterpret_cast<GtkFixed *>(gtk_fixed_new());

  hbox = gtk_hbox_new(FALSE, 0);
  vbox = gtk_vbox_new(FALSE, 0);

  if ((ulStyle & SS_OWNERDRAW) == SS_OWNERDRAW)
  {
    hCtrl = gtk_drawing_area_new();
    g_object_set_data(reinterpret_cast<GObject *>(hCtrl), "draw", static_cast<gpointer>(hCtrl));
  }
  else
  {
    hCtrl = gtk_toolbar_new();
  }

  gtk_box_pack_start(GTK_BOX(hbox), vbox, TRUE, TRUE, 0);
  if (ulStyle & WS_VSCROLL)
  {
#if GTK_MAJOR_VERSION - 0 < 3
    GtkObject *adjV;
#else
    GtkAdjustment *adjV;
#endif
    adjV = gtk_adjustment_new(0.0, 0.0, 101.0, 1.0, 10.0, 10.0);
    vscroll = gtk_vscrollbar_new(GTK_ADJUSTMENT(adjV));
    gtk_box_pack_end(GTK_BOX(hbox), vscroll, FALSE, FALSE, 0);

    temp = hb_itemPutPtr(nullptr, adjV);
    SetObjectVar(pObject, "_HSCROLLV", temp);
    hb_itemRelease(temp);

    SetWindowObject(reinterpret_cast<GtkWidget *>(adjV), pObject);
    set_signal(static_cast<gpointer>(adjV), "value_changed", WM_VSCROLL, 0, 0);
  }

  gtk_box_pack_start(GTK_BOX(vbox), reinterpret_cast<GtkWidget *>(fbox), TRUE, TRUE, 0);
  gtk_fixed_put(fbox, hCtrl, 0, 0);
  if (ulStyle & WS_HSCROLL)
  {
#if GTK_MAJOR_VERSION - 0 < 3
    GtkObject *adjH;
#else
    GtkAdjustment *adjH;
#endif
    adjH = gtk_adjustment_new(0.0, 0.0, 101.0, 1.0, 10.0, 10.0);
    hscroll = gtk_hscrollbar_new(GTK_ADJUSTMENT(adjH));
    gtk_box_pack_end(GTK_BOX(vbox), hscroll, FALSE, FALSE, 0);

    temp = hb_itemPutPtr(nullptr, adjH);
    SetObjectVar(pObject, "_HSCROLLH", temp);
    hb_itemRelease(temp);

    SetWindowObject(reinterpret_cast<GtkWidget *>(adjH), pObject);
    set_signal(static_cast<gpointer>(adjH), "value_changed", WM_HSCROLL, 0, 0);
  }

  box = getFixedBox(handle);
  if (box)
  {
    gtk_fixed_put(box, static_cast<GtkWidget *>(hbox), hb_parni(4), hb_parni(5));
    gtk_widget_set_size_request(static_cast<GtkWidget *>(hbox), nWidth, nHeight);
    if (vscroll)
    {
      nWidth -= 12;
    }
    if (hscroll)
    {
      nHeight -= 12;
    }
    gtk_widget_set_size_request(hCtrl, nWidth, nHeight);
  }

  g_object_set_data(reinterpret_cast<GObject *>(hCtrl), "fbox", static_cast<gpointer>(fbox));

  temp = hb_itemPutPtr(nullptr, hbox);
  SetObjectVar(pObject, "_HBOX", temp);
  hb_itemRelease(temp);

  gtk_widget_set_can_focus(hCtrl, 1);
  // GTK_WIDGET_SET_FLAGS(hCtrl, GTK_CAN_FOCUS);
  if ((ulStyle & SS_OWNERDRAW) == SS_OWNERDRAW)
  {
#if GTK_MAJOR_VERSION - 0 < 3
    set_event(static_cast<gpointer>(hCtrl), "expose_event", WM_PAINT, 0, 0);
#else
    set_event(static_cast<gpointer>(hCtrl), "draw", WM_PAINT, 0, 0);
#endif
  }
  gtk_widget_add_events(hCtrl, GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK | GDK_ENTER_NOTIFY_MASK |
                                   GDK_LEAVE_NOTIFY_MASK | GDK_POINTER_MOTION_MASK);
  set_event(static_cast<gpointer>(hCtrl), "button_press_event", 0, 0, 0);
  set_event(static_cast<gpointer>(hCtrl), "button_release_event", 0, 0, 0);
  set_event(static_cast<gpointer>(hCtrl), "enter_notify_event", 0, 0, 0);
  set_event(static_cast<gpointer>(hCtrl), "leave_notify_event", 0, 0, 0);
  set_event(static_cast<gpointer>(hCtrl), "motion_notify_event", 0, 0, 0);
  all_signal_connect(static_cast<gpointer>(hCtrl));

  hb_retptr(hCtrl);
}

HB_FUNC(HWG_DESTROYPANEL)
{
  GtkFixed *box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));
  if (box)
  {
    gtk_widget_destroy(reinterpret_cast<GtkWidget *>(box));
  }
}

/*
CreateOwnBtn(hParentWindow, nControlID, x, y, nWidth, nHeight)
*/
HB_FUNC(HWG_CREATEOWNBTN)
{
  GtkWidget *hCtrl;
  GtkFixed *box;

  hCtrl = gtk_drawing_area_new();
  g_object_set_data(reinterpret_cast<GObject *>(hCtrl), "draw", static_cast<gpointer>(hCtrl));

  box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));
  if (box)
  {
    gtk_fixed_put(box, hCtrl, hb_parni(3), hb_parni(4));
    gtk_widget_set_size_request(hCtrl, hb_parni(5), hb_parni(6));
  }
#if GTK_MAJOR_VERSION - 0 < 3
  set_event(static_cast<gpointer>(hCtrl), "expose_event", WM_PAINT, 0, 0);
#else
  set_event(static_cast<gpointer>(hCtrl), "draw", WM_PAINT, 0, 0);
#endif
  gtk_widget_set_can_focus(hCtrl, 1);
  // GTK_WIDGET_SET_FLAGS(hCtrl, GTK_CAN_FOCUS);
  gtk_widget_add_events(hCtrl, GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK | GDK_ENTER_NOTIFY_MASK |
                                   GDK_LEAVE_NOTIFY_MASK);
  set_event(static_cast<gpointer>(hCtrl), "button_press_event", 0, 0, 0);
  set_event(static_cast<gpointer>(hCtrl), "button_release_event", 0, 0, 0);
  set_event(static_cast<gpointer>(hCtrl), "enter_notify_event", 0, 0, 0);
  set_event(static_cast<gpointer>(hCtrl), "leave_notify_event", 0, 0, 0);
  all_signal_connect(static_cast<gpointer>(hCtrl));

  hb_retptr(hCtrl);
}

HB_FUNC(HWG_ADDTOOLTIP)
{
  gchar *gcTitle = hwg_convert_to_utf8(hb_parcx(2));
  gtk_widget_set_tooltip_text(static_cast<GtkWidget *>(hb_parptr(1)), gcTitle);
  g_free(gcTitle);
}

HB_FUNC(HWG_DELTOOLTIP)
{
  gtk_widget_set_tooltip_text(static_cast<GtkWidget *>(hb_parptr(1)), nullptr);
}

HB_FUNC(HWG_SETTOOLTIPTITLE)
{
  gchar *gcTitle = hwg_convert_to_utf8(hb_parcx(2));
  gtk_widget_set_tooltip_text(static_cast<GtkWidget *>(hb_parptr(1)), gcTitle);
  g_free(gcTitle);
}

HB_FUNC(HWG_SETTOOLTIPBALLOON)
{
  /*
   Empty function added by DF7BE
   The tooltip balloon is a nice gimmick of Windows and is not available in GTK.
   For compatible purposes you can set
   hwg_Settooltipballoon(.T.)
   as you like in your app, but the function call has no effect in GTK.
   In GTK, the tooltip is displayed in an rectangle.
 */
}

static gint cb_timer(gchar *data)
{
  HB_LONG p1;

  sscanf(static_cast<char *>(data), "%ld", &p1);

  if (!pSymTimerProc)
  {
    pSymTimerProc = hb_dynsymFind("HWG_TIMERPROC");
  }

  if (pSymTimerProc)
  {
    hb_vmPushSymbol(hb_dynsymSymbol(pSymTimerProc));
    hb_vmPushNil();
    hb_vmPushLong(static_cast<HB_LONG>(p1));
    hb_vmDo(1);
    return hb_parnl(-1);
  }

  return 0;
}

/*
 *  HWG_SetTimer(idTimer, i_MilliSeconds) -> tag
 */
HB_FUNC(HWG_SETTIMER)
{
  char buf[10] = {0};
  sprintf(buf, "%ld", hb_parnl(1));
  hb_retni(static_cast<gint>(
      g_timeout_add(static_cast<guint32>(hb_parnl(2)), reinterpret_cast<GSourceFunc>(cb_timer), g_strdup(buf))));
}

/*
 *  HWG_KillTimer(tag)
 */
HB_FUNC(HWG_KILLTIMER)
{
  // gtk_timeout_remove(static_cast<gint>(hb_parni(1)));
}

HB_FUNC(HWG_GETPARENT)
{
  hb_retptr(static_cast<void *>(gtk_widget_get_parent(static_cast<GtkWidget *>(hb_parptr(1)))));
}

HB_FUNC(HWG_LOADCURSOR)
{
  if (HB_ISCHAR(1))
  {
    // hb_retnl(static_cast<HB_LONG>(LoadCursor(GetModuleHandle(nullptr), hb_parc(1))));
  }
  else
  {
    hb_retptr(gdk_cursor_new(static_cast<GdkCursorType>(hb_parni(1))));
  }
}

/* Added by DF7BE:
       hwg_LoadCursorFromFile(ccurFname, x, y)
*/
HB_FUNC(HWG_LOADCURSORFROMFILE)
{
  GdkPixbuf *handle;
  GdkPixbuf *pHandle;
  GdkCursor *cursor;
  GdkDisplay *display = gdk_display_get_default();

  if (HB_ISCHAR(1))
  {
    handle = gdk_pixbuf_new_from_file(hb_parc(1), nullptr);
    pHandle = alpha2pixbuf(handle, 4095); /* 16777215 = 2^24 -1 (old value)  cursor are small */
    /* Returns handle to GdkCursor */
    cursor = gdk_cursor_new_from_pixbuf(display, pHandle, hb_parni(2), hb_parni(3));
    /* g_free(pHandle);   core dump with invalid pointer */
    hb_retptr(cursor);
  }
  else
  {
    hb_retptr(gdk_cursor_new(static_cast<GdkCursorType>(GDK_ARROW)));
  }
}

/*
 Hwg_SetCursor(objecthandle, areahandle)
 area : for example return value of Select() in HBROWSE
*/
HB_FUNC(HWG_SETCURSOR)
{
  GtkWidget *widget = (HB_ISPOINTER(2)) ? static_cast<GtkWidget *>(hb_parptr(2)) : GetActiveWindow();
  gdk_window_set_cursor(gtk_widget_get_window(widget), static_cast<GdkCursor *>(hb_parptr(1)));
}

HB_FUNC(HWG_MOVEWIDGET)
{
  auto widget = static_cast<GtkWidget *>(hb_parptr(1));
  GtkWidget *ch_widget = nullptr;
  GtkWidget *parent;

  if (!HB_ISNIL(6) && hb_parl(6))
  {
    ch_widget = widget;
    widget = gtk_widget_get_parent(widget);
  }

  parent = gtk_widget_get_parent(widget);
  if (!HB_ISNIL(2) && !HB_ISNIL(3))
  {
    gtk_fixed_move(reinterpret_cast<GtkFixed *>(parent), widget, hb_parni(2), hb_parni(3));
  }
  if (!HB_ISNIL(4) || !HB_ISNIL(5))
  {
    gint w, h, w1, h1;
    GtkAllocation alloc;
    gtk_widget_get_allocation(parent, &alloc);
    gtk_widget_get_size_request(widget, &w, &h);
    w1 = (HB_ISNIL(4)) ? w : hb_parni(4);
    h1 = (HB_ISNIL(5)) ? h : hb_parni(5);
    if (w1 > alloc.width)
    {
      w1 = alloc.width;
    }
    if (h1 > alloc.height)
    {
      h1 = alloc.height;
    }
    if (w != w1 || h != h1)
    {
      gtk_widget_set_size_request(widget, w1, h1);
      if (ch_widget)
      {
        gtk_widget_set_size_request(ch_widget, w1, h1);
      }
    }
  }
}

HB_FUNC(HWG_CREATEPROGRESSBAR)
{
  GtkWidget *hCtrl;
  GtkFixed *box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));
  hCtrl = gtk_progress_bar_new();

  if (box)
  {
    gtk_fixed_put(box, hCtrl, hb_parni(3), hb_parni(4));
  }
  gtk_widget_set_size_request(hCtrl, hb_parni(5), hb_parni(6));
  hb_retptr(hCtrl);
}

HB_FUNC(HWG_UPDATEPROGRESSBAR)
{
  // SendMessage(static_cast<HWND>(hb_parnl(1)), PBM_STEPIT, 0, 0);
  gtk_progress_bar_pulse(static_cast<GtkProgressBar *>(hb_parptr(1)));
}

HB_FUNC(HWG_SETPROGRESSBAR)
{
  auto widget = static_cast<GtkWidget *>(hb_parptr(1));
  auto b = static_cast<gdouble>(hb_parnd(2));

  // gtk_progress_bar_update(GTK_PROGRESS_BAR(widget), b);
  gtk_progress_bar_set_fraction(GTK_PROGRESS_BAR(widget), b);
  while (gtk_events_pending())
  {
    gtk_main_iteration();
  }
}

/* Added by DF7BE:
   Resets an existing progress bar:
   Use this function after creating a
   progress bar after a first use.
 */
HB_FUNC(HWG_RESETPROGRESSBAR)
{
  auto widget = static_cast<GtkWidget *>(hb_parptr(1));

  gtk_progress_bar_set_fraction(GTK_PROGRESS_BAR(widget), 0.0);
  gtk_progress_bar_update(GTK_PROGRESS_BAR(widget), 0.0);
  while (gtk_events_pending())
  {
    gtk_main_iteration();
  }
}

HB_FUNC(HWG_CREATESTATUSWINDOW)
{
  GtkWidget *w, *h;
  auto handle = static_cast<GObject *>(hb_parptr(1));
  auto vbox = static_cast<GtkWidget *>(g_object_get_data(handle, "vbox"));

  // w  = gtk_statusbar_new() ;
  h = gtk_hseparator_new();
  w = gtk_label_new("");
  gtk_misc_set_alignment(GTK_MISC(w), 0, 0);

  gtk_box_pack_start(GTK_BOX(vbox), static_cast<GtkWidget *>(h), FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(vbox), static_cast<GtkWidget *>(w), FALSE, FALSE, 0);

  hb_retptr(w);
}

HB_FUNC(HWG_WRITESTATUSWINDOW)
{
  char *cText = hwg_convert_to_utf8(hb_parcx(3));
  auto w = static_cast<GtkWidget *>(hb_parptr(1));

  // hb_retni(gtk_statusbar_push(GTK_STATUSBAR(w), iStatus, cText));
  gtk_label_set_text(reinterpret_cast<GtkLabel *>(w), cText);
  g_free(cText);
}

static void toolbar_clicked(GtkWidget *item, gpointer user_data)
{
  auto pData = static_cast<PHB_ITEM>(user_data);
  hb_vmEvalBlock(static_cast<PHB_ITEM>(pData));
  HB_SYMBOL_UNUSED(item);
}

HB_FUNC(HWG_CREATETOOLBAR)
{
  GtkWidget *hCtrl = gtk_toolbar_new();

  // GtkFixed * box = getFixedBox(static_cast<GObject*>(hb_parptr(1)));
  // GtkWidget * tmp_image;
  // GtkWidget * toolbutton1;
  // GtkWidget * toolbutton2;
  // gint tmp_toolbar_icon_size;
  auto handle = static_cast<GObject *>(hb_parptr(1));
  GtkFixed *box = getFixedBox(handle);
  GtkWidget *vbox = gtk_widget_get_parent(reinterpret_cast<GtkWidget *>(box));
  gtk_box_pack_start(GTK_BOX(vbox), hCtrl, FALSE, FALSE, 0);
  hb_retptr(hCtrl);
}

HB_FUNC(HWG_CREATETOOLBARBUTTON)
{
#if GTK_CHECK_VERSION(2, 4, 1)
  GtkWidget *toolbutton1, *img;
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  PHWGUI_PIXBUF szFile = HB_ISPOINTER(2) ? static_cast<PHWGUI_PIXBUF>(hb_parptr(2)) : nullptr;
  const char *szLabel = HB_ISCHAR(3) ? hb_parc(3) : nullptr;
  HB_BOOL lSep = hb_parl(4);
  gchar *gcLabel = nullptr;

  if (szLabel)
  {
    gcLabel = hwg_convert_to_utf8(szLabel);
  }
  if (lSep)
  {
    toolbutton1 = reinterpret_cast<GtkWidget *>(gtk_separator_tool_item_new());
  }
  else
  {
    if (szFile)
    {
      img = gtk_image_new_from_pixbuf(szFile->handle);
      gtk_widget_show(img);
      toolbutton1 = reinterpret_cast<GtkWidget *>(gtk_tool_button_new(img, gcLabel));
    }
    else
    {
      toolbutton1 = reinterpret_cast<GtkWidget *>(gtk_tool_button_new(nullptr, gcLabel));
    }
    if (gcLabel)
    {
      g_free(gcLabel);
    }
  }
  gtk_widget_show(toolbutton1);
  gtk_container_add(GTK_CONTAINER(hCtrl), toolbutton1);

  hb_retptr(toolbutton1);
#endif
}

HB_FUNC(HWG_TOOLBAR_SETACTION)
{
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  PHB_ITEM pItem = hb_itemParam(2);
  g_signal_connect(hCtrl, "clicked", G_CALLBACK(toolbar_clicked), static_cast<void *>(pItem));
}

static void tabchange_clicked(GtkNotebook *item, GtkWidget *Page, guint pagenum, gpointer user_data)
{
  auto pData = static_cast<PHB_ITEM>(user_data);
  gpointer dwNewLong = g_object_get_data(reinterpret_cast<GObject *>(item), "obj");
  auto pObject = static_cast<PHB_ITEM>(dwNewLong);
  auto Disk = hb_itemPutNL(nullptr, pagenum + 1);

  HB_SYMBOL_UNUSED(Page);
  hb_vmEvalBlockV(static_cast<PHB_ITEM>(pData), 2, pObject, Disk);
  hb_itemRelease(Disk);
}

HB_FUNC(HWG_TAB_SETACTION)
{
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  PHB_ITEM pItem = hb_itemParam(2);
  g_signal_connect(hCtrl, "switch-page", G_CALLBACK(tabchange_clicked), static_cast<void *>(pItem));
}

HB_FUNC(HWG_INITMONTHCALENDAR)
{
  GtkWidget *hCtrl;
  GtkFixed *box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));

  hCtrl = gtk_calendar_new();

  if (box)
  {
    gtk_fixed_put(box, hCtrl, hb_parni(3), hb_parni(4));
  }
  gtk_widget_set_size_request(hCtrl, hb_parni(5), hb_parni(6));
  hb_retptr(hCtrl);
}

HB_FUNC(HWG_SETMONTHCALENDARDATE)
{
  auto pDate = hb_param(2, Harbour::Item::DATE);

  if (pDate)
  {
    auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
#ifndef HARBOUR_OLD_VERSION
    int lYear, lMonth, lDay;
#else
    long lYear, lMonth, lDay;
#endif

    hb_dateDecode(hb_itemGetDL(pDate), &lYear, &lMonth, &lDay);

    lMonth = lMonth - 1; /* Bugfixung by DF7BE */

    gtk_calendar_select_month(GTK_CALENDAR(hCtrl), lMonth, lYear);
    gtk_calendar_select_day(GTK_CALENDAR(hCtrl), lDay);
  }
}

HB_FUNC(HWG_GETMONTHCALENDARDATE)
{
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  char szDate[9];
#ifndef HARBOUR_OLD_VERSION
  int lYear, lMonth, lDay;
#else
  long lYear, lMonth, lDay;
#endif
  gtk_calendar_get_date(GTK_CALENDAR(hCtrl), reinterpret_cast<guint *>(&lYear), reinterpret_cast<guint *>(&lMonth),
                        reinterpret_cast<guint *>(&lDay));

  lMonth = lMonth + 1;

  hb_dateStrPut(szDate, lYear, lMonth, lDay);
  szDate[8] = 0;
  hb_retds(szDate);
}

HB_FUNC(HWG_CREATEIMAGE)
{
  GtkWidget *hCtrl;
  GtkFixed *box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));
  GdkPixbuf *handle = gdk_pixbuf_new_from_file(hb_parc(2), nullptr);
  GdkPixbuf *pHandle = alpha2pixbuf(handle, 16777215);

  hCtrl = gtk_image_new_from_pixbuf(pHandle);

  if (box)
  {
    gtk_fixed_put(box, hCtrl, hb_parni(3), hb_parni(4));
  }
  gtk_widget_set_size_request(hCtrl, hb_parni(5), hb_parni(6));
  hb_retptr(hCtrl);
}

HB_FUNC(HWG_MONTHCALENDAR_SETACTION)
{
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  PHB_ITEM pItem = hb_itemParam(2);
  g_signal_connect(hCtrl, "day-selected", G_CALLBACK(toolbar_clicked), static_cast<void *>(pItem));
}

void hwg_parse_color(HB_ULONG ncolor, GdkColor *pColor);

#if GTK_MAJOR_VERSION - 0 < 3
HB_FUNC(HWG_SETFGCOLOR)
{
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  GtkStateType iType = (HB_ISNIL(3)) ? GTK_STATE_NORMAL : hb_parni(3);

  GtkWidget *label;
  HB_ULONG hColor = hb_parnl(2);
  GdkColor color;

  if (GTK_IS_BUTTON(hCtrl))
  {
    label = gtk_bin_get_child(GTK_BIN(hCtrl));
  }
  else if (GTK_IS_EVENT_BOX(hCtrl))
  {
    label = gtk_bin_get_child(GTK_BIN(hCtrl));
  }
  else
  {
    label = hCtrl; // g_object_get_data(static_cast<Object*>(hCtrl), "label");
  }

  if (label)
  {
    /*
    GtkStyle * style = gtk_style_copy(gtk_widget_get_style(label));
    hwg_parse_color(hColor, &(style->fg[iType]));
    hwg_parse_color(hColor, &(style->text[iType]));
    gtk_widget_set_style(label, style);
    */
    hwg_parse_color(hColor, &color);
    gtk_widget_modify_fg(label, iType, &color);
  }
}

HB_FUNC(HWG_SETBGCOLOR)
{
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  HB_ULONG hColor = hb_parnl(2);
  GdkColor color;

  /*
  GtkStyle * style = gtk_style_copy(gtk_widget_get_style(hCtrl));
  hwg_parse_color(hColor, &(style->bg[GTK_STATE_NORMAL]));
  hwg_parse_color(hColor, &(style->base[GTK_STATE_NORMAL]));
  gtk_widget_set_style(hCtrl, style);
  */
  hwg_parse_color(hColor, &color);
  gtk_widget_modify_bg(hCtrl, GTK_STATE_NORMAL, &color);
}

#else

HB_FUNC(HWG_SETFGCOLOR)
{
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  char szData[128], szColor[8];
  const char *pName = gtk_widget_get_name(hCtrl);

  if (pName && strncmp(pName, "Gtk", 3) != 0)
  {
    hwg_colorN2C(static_cast<unsigned int>(hb_parni(2)), szColor);
    sprintf(szData, "#%s { color: #%s; }", pName, szColor);
    // hwg_writelog(nullptr, szData);
    set_css_data(szData);
  }
}

HB_FUNC(HWG_SETBGCOLOR)
{
  auto hCtrl = static_cast<GtkWidget *>(hb_parptr(1));
  char szData[128], szColor[8];
  const char *pName = gtk_widget_get_name(hCtrl);

  if (pName && strncmp(pName, "Gtk", 3) != 0)
  {
    hwg_colorN2C(static_cast<unsigned int>(hb_parni(2)), szColor);
    sprintf(szData, "#%s { background: #%s; }", pName, szColor);
    // hwg_writelog(nullptr, szData);
    set_css_data(szData);
  }
}
#endif

/*
CreateSplitter(hParentWindow, nControlID, nStyle, x, y, nWidth, nHeight)
*/
HB_FUNC(HWG_CREATESPLITTER)
{
  // HB_ULONG ulStyle = hb_parnl(3);
  GtkWidget *hCtrl;
  GtkFixed *box;
  // auto fbox = static_cast<GtkFixed*>(gtk_fixed_new());

  hCtrl = gtk_drawing_area_new();
  g_object_set_data(reinterpret_cast<GObject *>(hCtrl), "draw", static_cast<gpointer>(hCtrl));
  box = getFixedBox(static_cast<GObject *>(hb_parptr(1)));

  if (box)
  {
    gtk_fixed_put(box, hCtrl, hb_parni(4), hb_parni(5));
  }
  gtk_widget_set_size_request(hCtrl, hb_parni(6), hb_parni(7));
  /*
  if( box ) {
     gtk_fixed_put(box, static_cast<GtkWidget*>(fbox), hb_parni(4), hb_parni(5));
     gtk_widget_set_size_request(static_cast<GtkWidget*>(fbox), hb_parni(6), hb_parni(7));
  }
  gtk_fixed_put(fbox, hCtrl, 0, 0);
  gtk_widget_set_size_request(hCtrl, hb_parni(6), hb_parni(7));
  g_object_set_data(static_cast<GObject*>(hCtrl), "fbox", static_cast<gpointer>(fbox));
  */
#if GTK_MAJOR_VERSION - 0 < 3
  set_event(static_cast<gpointer>(hCtrl), "expose_event", WM_PAINT, 0, 0);
#else
  set_event(static_cast<gpointer>(hCtrl), "draw", WM_PAINT, 0, 0);
#endif
  gtk_widget_set_can_focus(hCtrl, 1);
  // GTK_WIDGET_SET_FLAGS(hCtrl, GTK_CAN_FOCUS);

  gtk_widget_add_events(hCtrl, GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK | GDK_POINTER_MOTION_MASK);
  set_event(static_cast<gpointer>(hCtrl), "button_press_event", 0, 0, 0);
  set_event(static_cast<gpointer>(hCtrl), "button_release_event", 0, 0, 0);
  set_event(static_cast<gpointer>(hCtrl), "motion_notify_event", 0, 0, 0);

  all_signal_connect(static_cast<gpointer>(hCtrl));
  hb_retptr(hCtrl);
}

HB_FUNC(HWG_CSSLOAD)
{
#if GTK_MAJOR_VERSION - 0 > 2
  set_css_data(static_cast<char *>(hb_parc(1)));
#endif
}

HB_FUNC(HWG_SETWIDGETNAME)
{
  gtk_widget_set_name(static_cast<GtkWidget *>(hb_parptr(1)), hb_parc(2));
}

/*
 DF7BE : Ticket #64
 hwg_ShowCursor(lcursor, hwindow, ndefaultcsrtype)
*/
HB_FUNC(HWG_SHOWCURSOR)
{
  HB_BOOL modus;
  int rvalue;

  GdkCursor *cursor;
  GdkWindow *win;

  /* long csrtype; */

  modus = hb_parl(1);

  /* csrtype = (HB_ISNIL(3)) ? 0 : hb_parnl(3); */

  if (modus)
  {
    /* show cursor */
    cursor = gdk_cursor_new(GDK_ARROW);
    /*
    crashes on LINUX, works best on GTK development environment on Windows
    cursor = gdk_cursor_new(csrtype);
    */
    rvalue = 0;
  }
  else
  {
    /* hide cursor */
    cursor = gdk_cursor_new(GDK_BLANK_CURSOR);
    rvalue = -1;
  }
  win = gtk_widget_get_window(static_cast<GtkWidget *>(hb_parptr(2)));
  gdk_window_set_cursor(win, cursor);
  hb_retni(rvalue);
}

HB_FUNC(HWG_GETCURSORTYPE)
{
  hb_retnl(reinterpret_cast<long>(gdk_cursor_get_type));
}
