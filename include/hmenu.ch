/*   Menu system     */

#xcommand MENU [ OF <oWnd> ] [ ID <nId> ] [ TITLE <cTitle> ] ;
          => ;
    Hwg_BeginMenu( <oWnd>, <nId>, <cTitle> )

#xcommand CONTEXT MENU <oMenu> ;
          => ;
    <oMenu> := Hwg_ContextMenu()

#xcommand ENDMENU           => Hwg_EndMenu()

#xcommand MENUITEM <item> [ ID <nId> ]    ;
            ACTION <act>                  ;
            [ BITMAP <bmp> ]               ; //ADDED by Sandro Freire
            [<res: FROM RESOURCE>]        ; //true use image from resource
            [ ACCELERATOR <flag>, <key> ] ;
            [<lDisabled: DISABLED>]       ;
          => ;
    Hwg_DefineMenuItem( <item>, <nId>, <{act}>, <.lDisabled.>, <flag>, <key>, <bmp>, <.res.>, .f. )

#xcommand MENUITEMCHECK <item> [ ID <nId> ]    ;
            [ ACTION <act> ]              ;
            [ ACCELERATOR <flag>, <key> ] ;
            [<lDisabled: DISABLED>]       ;
          => ;
    Hwg_DefineMenuItem( <item>, <nId>, <{act}>, <.lDisabled.>, <flag>, <key>,,, .t. )

#xcommand MENUITEMBITMAP <oMain>  ID <nId> ;
            BITMAP <bmp>                  ;
            [<res: FROM RESOURCE>]         ;
          => ;
    Hwg_InsertBitmapMenu( <oMain>:menu, <nId>, <bmp>, <.res.>)

#xcommand ACCELERATOR <flag>, <key>       ;
            [ ID <nId> ]                  ;
            ACTION <act>                  ;
          => ;
    Hwg_DefineAccelItem( <nId>, <{act}>, <flag>, <key> )

#xcommand SEPARATOR         => Hwg_DefineMenuItem()
