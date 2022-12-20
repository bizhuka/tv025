*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_tree DEFINITION FINAL FRIENDS zcl_eui_event_caller.
  PUBLIC SECTION.
    DATA:
      BEGIN OF ms_node,
        rec_opened           TYPE lvc_nkey,
        rec_created          TYPE lvc_nkey,
        free_search          TYPE lvc_nkey,
        new_employee_request TYPE lvc_nkey,
        new_visitor_request  TYPE lvc_nkey,
        user_prefs           TYPE lvc_nkey,
      END OF ms_node.

    METHODS:
      constructor
        IMPORTING
          io_prefs TYPE REF TO lcl_user_prefs,

      make_gui,

      fill,

      delete_from
        IMPORTING
          iv_parent_node TYPE lvc_nkey
          is_db_key      TYPE ts_db_key OPTIONAL
          iv_from        TYPE i         OPTIONAL
          iv_refresh     TYPE abap_bool OPTIONAL,

      f4_free_search,

      add_opened IMPORTING is_db_key TYPE ts_db_key
                           iv_insert TYPE abap_bool DEFAULT abap_true,
      show_f4
        IMPORTING iv_request       TYPE abap_bool
        RETURNING VALUE(rs_db_key) TYPE ts_db_key.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ts_tree_data,
        status TYPE zde_tv022_status,
        reinr  TYPE ts_db_key-reinr,
      END OF ts_tree_data,
      tt_tree_data TYPE STANDARD TABLE OF ts_tree_data WITH DEFAULT KEY.

    DATA:
      mo_prefs     TYPE REF TO lcl_user_prefs,
      mt_tree_data TYPE REF TO tt_tree_data,
      mo_gui_tree  TYPE REF TO cl_gui_alv_tree.

    METHODS:
      _fill_tree_with_created_opt,

      _on_link_click FOR EVENT link_click OF cl_gui_alv_tree
        IMPORTING
          node_key,

      _expand_invert_node
        IMPORTING
          iv_node  TYPE lvc_nkey
          iv_level TYPE i         DEFAULT 1,

      _add_node
        IMPORTING
                  i_node_text    TYPE clike
                  is_db_key      TYPE ts_db_key               OPTIONAL
                  i_relat_node   TYPE lvc_nkey                OPTIONAL
                  i_relationship TYPE i                       DEFAULT cl_gui_column_tree=>relat_last_child
                  is_layout      TYPE lvc_s_layn              OPTIONAL
                  iv_item_icon   TYPE icon_d                  OPTIONAL
                  iv_item_class  TYPE i                       OPTIONAL
        RETURNING VALUE(rv_node) TYPE lvc_nkey,

      _add_parent_node
        IMPORTING
                  i_node_text    TYPE csequence
                  iv_item_icon   TYPE icon_d                  OPTIONAL
                  iv_layout_icon TYPE icon_d                  OPTIONAL
                  i_relat_node   TYPE lvc_nkey                OPTIONAL
        RETURNING VALUE(rv_node) TYPE lvc_nkey,

      _add_travel_node
        IMPORTING
          is_db_key      TYPE ts_db_key
          iv_parent      TYPE lvc_nkey
          i_relationship TYPE i DEFAULT cl_gui_column_tree=>relat_last_child.
ENDCLASS.

CLASS lcl_tree IMPLEMENTATION.
  METHOD constructor.
    mo_prefs = io_prefs.
  ENDMETHOD.

  METHOD make_gui.
    " 1 time only
    CHECK mt_tree_data IS INITIAL.
    CREATE DATA mt_tree_data.

    DATA ls_header TYPE treev_hhdr.
    ls_header-heading = 'Personnel Number'(trp).
    ls_header-width   = 35.                              "#EC NUMBER_OK
    ls_header-t_image = icon_tree.

    DATA(lo_eui_tree) = NEW zcl_eui_tree(
        ir_table       = mt_tree_data
        is_header      = ls_header
        it_mod_catalog = VALUE #( ( fieldname = 'STATUS' outputlen = 4 coltext = 'S.' )
                                  ( fieldname = 'REINR'  outputlen = 15 ) )
        no_toolbar     = abap_true
        no_html_header = abap_true ).

    DATA(lo_doc_container) = NEW cl_gui_docking_container(
        dynnr     = sy-dynnr
        side      = cl_gui_docking_container=>dock_at_left
        extension = 330 ).                               "#EC NUMBER_OK
    lo_eui_tree->add_handler( me ).
    lo_eui_tree->pbo( io_container = lo_doc_container ).
    mo_gui_tree = lo_eui_tree->get_tree( ).
  ENDMETHOD.

  METHOD fill.
*    IF go_editor->mv_is_dev = abap_true.
    ms_node-new_employee_request = _add_parent_node(
      i_node_text    = 'New employee request'(ner)
      iv_layout_icon = icon_new_employee ).

    ms_node-new_visitor_request = _add_parent_node(
      i_node_text    = 'New visitor request'(nev)
      iv_layout_icon = icon_incoming_employee ).
*    ENDIF.

    ms_node-rec_opened = _add_parent_node(
      i_node_text  = 'Recently opened'(reo)
      iv_item_icon = icon_time ).
    DATA lr_db_key TYPE REF TO ts_db_key.
    LOOP AT mo_prefs->t_opened[] REFERENCE INTO lr_db_key.
      _add_travel_node( is_db_key = lr_db_key->*
                        iv_parent = ms_node-rec_opened ).
    ENDLOOP.

    _fill_tree_with_created_opt( ).

    ms_node-free_search = _add_parent_node(
      i_node_text    = 'Free Search'(frs)
      iv_layout_icon = icon_search
    ).

    ms_node-user_prefs = _add_parent_node(
     i_node_text    = 'User preferences'(upf)
     iv_layout_icon = icon_activity ).

    " update gui
    _expand_invert_node( iv_node = ms_node-rec_opened ).
    _expand_invert_node( iv_node = ms_node-rec_created ).
    mo_gui_tree->frontend_update( ).
  ENDMETHOD.

  METHOD f4_free_search.
    _on_link_click( node_key = ms_node-free_search ).
  ENDMETHOD.

  METHOD _on_link_click.
    DATA ls_command TYPE ts_command.
    " By default
    ls_command-ucomm = mc_pai_cmd-open_request.

    CASE node_key.
      WHEN ms_node-free_search.
        ls_command-db_key = show_f4( abap_true ).

      WHEN ms_node-new_employee_request.
        go_model->exchange_command( VALUE #( ucomm = mc_pai_cmd-new_employee_request ) ).

      WHEN ms_node-new_visitor_request.
        go_model->exchange_command( VALUE #( ucomm = mc_pai_cmd-new_visitor_request ) ).

      WHEN ms_node-user_prefs.
        go_model->exchange_command( VALUE #( ucomm = mc_pai_cmd-show_user_prefs ) ).

      WHEN OTHERS.
        DATA ls_tree_data TYPE ts_tree_data.
        mo_gui_tree->get_outtab_line( EXPORTING  i_node_key    = node_key
                                      IMPORTING  e_outtab_line = ls_tree_data
                                                 e_node_text   = DATA(lv_pernr)
                                      EXCEPTIONS OTHERS        = 1 ).
        CHECK sy-subrc = 0.

        " collapse or expand
        IF ls_tree_data-reinr IS INITIAL.
          _expand_invert_node( node_key ).
          RETURN.
        ENDIF.

        ls_command-pernr = lv_pernr.
        ls_command-reinr = ls_tree_data-reinr.
    ENDCASE.

    CHECK ls_command-db_key IS NOT INITIAL.
    go_model->exchange_command( is_command = ls_command ).
  ENDMETHOD.

  METHOD show_f4.
    DATA lt_ret  TYPE STANDARD TABLE OF ddshretval.
    CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
      EXPORTING
        "#@see SE37 -> 'ZF_TV025_REQUEST_EXIT'
        searchhelp = COND shlpname( WHEN iv_request = 'X' THEN 'ZSH_TV025_REQUEST' ELSE 'ZSH_TV025_TRAVEL' )
        dynpprog   = sy-repid
        dynpnr     = sy-dynnr
        tabname    = ''
        fieldname  = ''
      TABLES
        return_tab = lt_ret
      EXCEPTIONS
        OTHERS     = 0.

    LOOP AT lt_ret REFERENCE INTO DATA(ls_ret) WHERE fieldname = 'PERNR' OR fieldname = 'REINR'.
      CASE ls_ret->fieldname.
        WHEN 'PERNR'.                                       "#EC NOTEXT
          rs_db_key-pernr = ls_ret->fieldval.
        WHEN 'REINR'.                                       "#EC NOTEXT
          rs_db_key-reinr = ls_ret->fieldval.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD _expand_invert_node.
    DATA lt_expanded TYPE lvc_t_nkey.
    mo_gui_tree->get_expanded_nodes( CHANGING   ct_expanded_nodes = lt_expanded
                                     EXCEPTIONS OTHERS            = 0 ).
    READ TABLE lt_expanded TRANSPORTING NO FIELDS
     WITH KEY table_line = iv_node.
    IF sy-subrc = 0.
      mo_gui_tree->collapse_subtree( EXPORTING  i_node_key = iv_node
                                     EXCEPTIONS OTHERS     = 0 ).
      RETURN.
    ENDIF.

    mo_gui_tree->expand_node( EXPORTING  i_node_key    = iv_node
                                         i_level_count = iv_level
                              EXCEPTIONS OTHERS        = 0 ).
  ENDMETHOD.

  METHOD _fill_tree_with_created_opt.
    DATA(lt_travels) = go_model->get_request_items(
      it_select   = VALUE #( ( sign = 'I' option = 'EQ' shlpfield = 'CRUNM' low = sy-uname ) )
      iv_count    = mo_prefs->s_opt-v_max_count
      " form DB
      iv_order_by = |crdat DESCENDING, crtime DESCENDING| ).
    SORT lt_travels BY crdat DESCENDING crtime DESCENDING.

    " Get keys only
    DATA(lt_db_key) = CORRESPONDING tt_db_key( lt_travels ).
    CHECK lt_db_key[] IS NOT INITIAL.

    ms_node-rec_created = _add_parent_node(
      i_node_text  = 'Recently created'(rec)
      iv_item_icon = icon_date ).

    LOOP AT lt_db_key REFERENCE INTO DATA(lr_db_key).
      _add_travel_node( is_db_key = lr_db_key->*
                        iv_parent = ms_node-rec_created ).
    ENDLOOP.
  ENDMETHOD.

  METHOD _add_parent_node.
    DATA ls_layout TYPE lvc_s_layn.
    ls_layout-isfolder = abap_true.
    ls_layout-exp_image = ls_layout-n_image = iv_layout_icon.

    rv_node = _add_node(
      i_node_text   = i_node_text
      i_relat_node  = i_relat_node
      is_layout     = ls_layout
      iv_item_icon  = iv_item_icon
      iv_item_class = cl_gui_column_tree=>item_class_link ).
  ENDMETHOD.

  METHOD delete_from.
    DATA lt_children TYPE lvc_t_nkey.
    mo_gui_tree->get_children( EXPORTING  i_node_key  = iv_parent_node
                               IMPORTING  et_children = lt_children
                               EXCEPTIONS OTHERS      = 0 ).
    DATA lv_child TYPE lvc_nkey.
    LOOP AT lt_children INTO lv_child FROM iv_from.
      IF is_db_key IS SUPPLIED.
        DATA: ls_tree_data TYPE ts_tree_data,
              lv_pernr     TYPE lvc_value.
        mo_gui_tree->get_outtab_line( EXPORTING  i_node_key    = lv_child
                                      IMPORTING  e_outtab_line = ls_tree_data
                                                 e_node_text   = lv_pernr
                                      EXCEPTIONS OTHERS        = 1 ).
        CHECK sy-subrc = 0
          AND is_db_key-pernr = lv_pernr
          AND is_db_key-reinr = ls_tree_data-reinr.
      ENDIF.

      mo_gui_tree->delete_subtree( EXPORTING  i_node_key = lv_child
                                   EXCEPTIONS OTHERS     = 0 ).
    ENDLOOP.

    CHECK iv_refresh = abap_true.
    mo_gui_tree->frontend_update( ).
  ENDMETHOD.

  METHOD add_opened.
    " Delete the same key
    delete_from( iv_parent_node = ms_node-rec_opened
                 is_db_key      = is_db_key ).
    IF iv_insert = abap_true.
      _add_travel_node( is_db_key      = is_db_key
                        iv_parent      = ms_node-rec_opened
                        i_relationship = cl_gui_column_tree=>relat_first_child ).
    ENDIF.
    " Delete oversized
    delete_from( iv_parent_node = ms_node-rec_opened
                 iv_from        = mo_prefs->s_opt-v_max_count + 1
                 iv_refresh     = abap_true ).
  ENDMETHOD.

  METHOD _add_travel_node.
    DATA ls_layout TYPE lvc_s_layn.
    ls_layout-n_image = icon_change_text.

    _add_node(
      i_node_text    = |{ is_db_key-pernr ALPHA = OUT }|
      is_db_key      = is_db_key
      i_relat_node   = iv_parent
      is_layout      = ls_layout
      iv_item_class  = cl_gui_column_tree=>item_class_link
      i_relationship = i_relationship ).
  ENDMETHOD.

  METHOD _add_node.
    DATA lt_item_layout TYPE lvc_t_layi.
    DATA lr_item_layout TYPE REF TO lvc_s_layi.
    IF iv_item_icon IS NOT INITIAL OR iv_item_class IS NOT INITIAL.
      APPEND INITIAL LINE TO lt_item_layout REFERENCE INTO lr_item_layout.
      lr_item_layout->fieldname = cl_alv_tree_base=>c_hierarchy_column_name.
      lr_item_layout->t_image   = iv_item_icon.
      lr_item_layout->class     = iv_item_class.
    ENDIF.

    DATA ls_line TYPE ts_tree_data.
    IF is_db_key IS NOT INITIAL.
      DATA(ls_root) = VALUE zc_tv025_root( ).
      go_model->get_by_key( EXPORTING is_db_key  = is_db_key
                            CHANGING  cs_db_item = ls_root ).

      ls_line-reinr  = is_db_key-reinr.
      ls_line-status = ls_root-zz_status.
    ENDIF.

    DATA l_node_text TYPE lvc_value.
    l_node_text = i_node_text.

    mo_gui_tree->add_node(
      EXPORTING  i_relat_node_key = i_relat_node
                 i_relationship   = i_relationship
                 is_outtab_line   = ls_line
                 i_node_text      = l_node_text
                 is_node_layout   = is_layout
                 it_item_layout   = lt_item_layout
      IMPORTING  e_new_node_key   = rv_node
      EXCEPTIONS OTHERS           = 1 ).
    CHECK sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno DISPLAY LIKE 'E' WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDMETHOD.

ENDCLASS.
