*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_editor DEFINITION INHERITING FROM lcl_tab FINAL FRIENDS zcl_eui_event_caller.
  PUBLIC SECTION.
    METHODS:
      constructor,
      start_of_selection,

      on_pbo_event FOR EVENT pbo_event OF zif_eui_manager IMPORTING sender,

      pbo_ui      REDEFINITION,
      pai_ui      REDEFINITION.

    DATA:
      mo_prefs TYPE REF TO lcl_user_prefs READ-ONLY,
      mo_tree  TYPE REF TO lcl_tree       READ-ONLY.

  PROTECTED SECTION.
    METHODS:
      _make_tree,
      _do_open      IMPORTING is_db_key       TYPE ts_db_key
                              iv_check_exists TYPE abap_bool DEFAULT abap_true,

      _do_save      IMPORTING iv_re_open TYPE abap_bool OPTIONAL,
      _is_saved     RETURNING VALUE(rv_ok) TYPE abap_bool,

      _add_table_parts,

      _get_status REDEFINITION.
ENDCLASS.

CLASS lcl_editor IMPLEMENTATION.
  METHOD constructor.
    super->constructor( iv_dynnr      = '0100'
                        ir_screen_ui  = REF #( zss_tv025_head )
                        iv_title      = ''
                        iv_row_end    = 0 " <--- full screen
                       ).
    init_date_checker( it_low  = VALUE #( ( REF #( zss_tv025_head-date_beg ) ) )
                       it_high = VALUE #( ( REF #( zss_tv025_head-date_end ) ) ) ).
  ENDMETHOD.

  METHOD start_of_selection.
    _show_item( ).
  ENDMETHOD.

  METHOD _get_status.
    super->_get_status( ).
    rs_status-prog    = sy-repid.
    rs_status-name    = 'STAT_REQUEST'.
    rs_status-title   = COND #( WHEN zss_tv025_head IS INITIAL THEN 'Attention! Deprecated version!'(trt)
                                WHEN locked IS NOT INITIAL     THEN 'Travel Requests - View'(trv)
                                                               ELSE 'Travel Requests - Edit'(tre) ).
    rs_status-exclude = COND #( WHEN go_model->is_changed( ) <> abap_true THEN VALUE syucomm_t( ( mc_pai_cmd-save ) ) ).

    IF locked IS NOT INITIAL.
      APPEND mc_pai_cmd-dict    TO rs_status-exclude[].
    ENDIF.

    IF locked IS NOT INITIAL OR zss_tv025_head IS INITIAL.
      APPEND mc_pai_cmd-add_tab TO rs_status-exclude[].
    ENDIF.
  ENDMETHOD.

  METHOD on_pbo_event.
    CHECK sender IS INSTANCE OF zcl_eui_screen.
    sender->set_status( _get_status( ) ).

    _make_tree( ).
  ENDMETHOD.

  METHOD _make_tree.
    " 1 time only
    CHECK mo_tree IS INITIAL.
    mo_prefs = NEW #( ).
    mo_tree  = NEW #( mo_prefs ).

    mo_tree->make_gui( ).
    mo_tree->fill( ).
  ENDMETHOD.

  METHOD pbo_ui.
    super->pbo_ui( ). " it_customize = COND #( ).
    tabs-activetab   = g_tabs-pressed_tab.
    g_tabs-subscreen = g_tabs-pressed_tab+5.

    zss_tv025_head_ui = VALUE #( ).
    zss_tv025_head_ui-department = zcl_hr_om_utilities=>find_hlevel(
       im_objid  = zss_tv025_head-pernr
       im_datum  = zss_tv025_head-date_beg
       im_hlevel = 'DEPARTMENT' ).
    zss_tv025_head_ui-dep_name = zcl_hr_om_utilities=>get_object_name(
       im_objty = 'O'
       im_objid = zss_tv025_head_ui-department
       im_subty = '0001' ).

**********************************************************************
    zss_tv025_head_ui-passp_number = zss_tv025_head-passp_number.
    zss_tv025_head_ui-passp_expiry = zss_tv025_head-passp_expiry.

    CHECK go_model->is_visitor( ) <> abap_true.

    DATA(lt_passport) = VALUE zcl_v_tv025_root=>tt_passport(
                        ( pernr = zss_tv025_head-pernr
                          reinr = zss_tv025_head-reinr ) ).
    DATA(lo_odata_ext) = CAST zif_sadl_read_runtime( zcl_sadl_annotation_ext=>create( 'ZCL_V_TV025_ROOT' ) ).

    lo_odata_ext->execute( CHANGING ct_data_rows = lt_passport ).
    zss_tv025_head_ui-passp_expiry = lt_passport[ 1 ]-passp_expiry.
    zss_tv025_head_ui-passp_number = lt_passport[ 1 ]-passp_number.
  ENDMETHOD.

  METHOD pai_ui.
    IF go_model->is_visitor( ) = abap_true.
      IF    zss_tv025_head_ui-passp_number IS NOT INITIAL
        AND find( val = |{ zss_tv025_head_ui-passp_number }| regex = '^[0-9A-Z]*$' ) <> 0.
        MESSAGE s003(ztv_025) WITH zss_tv025_head_ui-passp_number DISPLAY LIKE 'W'.
      ENDIF.

      zss_tv025_head-passp_number = zss_tv025_head_ui-passp_number.
      zss_tv025_head-passp_expiry = zss_tv025_head_ui-passp_expiry.
    ENDIF.

    " status & visitor fields are editable
    go_model->ms_cache-s_head = zss_tv025_head.

    IF iv_command CP 'TABS_*' AND zss_tv025_head IS NOT INITIAL.
      g_tabs-pressed_tab = iv_command.
      RETURN.
    ENDIF.

    go_model->exchange_command( IMPORTING es_command = DATA(ls_command) ).
    IF iv_command IS INITIAL.
      iv_command = ls_command-ucomm.
    ENDIF.

    CASE iv_command.
      WHEN mc_pai_cmd-save.
        _do_save( iv_re_open = abap_true ).

      WHEN mc_pai_cmd-open_request.
        CHECK ls_command-db_key IS NOT INITIAL
          AND _is_saved( ) = abap_true.

        _do_open( ls_command-db_key ).

      WHEN mc_pai_cmd-new_employee_request OR mc_pai_cmd-new_visitor_request.
        CHECK _is_saved( ) = abap_true.

        DATA lo_request TYPE REF TO lif_request.
        CREATE OBJECT lo_request TYPE (iv_command).

        DATA(ls_db_key) = lo_request->get_db_key( ).
        " Reopen current item
        IF ls_db_key IS INITIAL.
          ls_db_key = CORRESPONDING #( zss_tv025_head ).
        ENDIF.
        CHECK ls_db_key IS NOT INITIAL.

        _do_open( is_db_key       = ls_db_key
                  iv_check_exists = abap_false ).

        lo_request->after_created( ls_db_key ).

      WHEN zif_eui_manager=>mc_cmd-cancel OR mc_pai_cmd-back.
        cv_close = abap_false.
        CHECK _is_saved( ) = abap_true.
        cv_close = abap_true.

        go_model->lock( iv_unlock = abap_true ).

      WHEN mc_pai_cmd-dict.
        go_dict->show_all( ).

      WHEN mc_pai_cmd-show_user_prefs.
        mo_prefs->show_screen( ).

      WHEN mc_pai_cmd-add_tab.
        _add_table_parts( ).

      WHEN mc_pai_cmd-report.
        NEW zcl_tv025_report( )->start_of_selection( ).
    ENDCASE.
  ENDMETHOD.

  METHOD _add_table_parts.
    TYPES: BEGIN OF ts_popup,
             v_flight        TYPE xsdboolean,
             v_hotel         TYPE xsdboolean,
             v_transport     TYPE xsdboolean,
             v_keep_previous TYPE xsdboolean,
           END OF ts_popup.
    DATA(ls_db_key) = mo_tree->show_f4( abap_true ).
    CHECK ls_db_key IS NOT INITIAL.

    DATA(ls_template) = go_model->read_db( ls_db_key ).
    DATA(ls_popup) = CONV ts_popup( 'XXXX' ).

    TRY.
        CHECK NEW zcl_eui_screen( ir_context = REF #( ls_popup )
                                  iv_dynnr   = zcl_eui_screen=>mc_dynnr-dynamic
                                  iv_cprog   = |{ sy-cprog }_ADD_T|
              )->customize( name = 'V_FLIGHT'         iv_label = |Flight : { lines( ls_template-t_flight ) } items|
              )->customize( name = 'V_HOTEL'          iv_label = |Hotel : { lines( ls_template-t_hotel ) } items|
              )->customize( name = 'V_TRANSPORT'      iv_label = |Transport : { lines( ls_template-t_transp ) } items|
              )->customize( name = 'V_KEEP_PREVIOUS'  iv_label = |Keep previous items|
              )->popup( iv_col_beg = 30
                        iv_col_end = 75
              )->set_status( VALUE #( title = |Copy table part from template| )
              )->show( ) = 'OK'.
      CATCH zcx_eui_exception INTO DATA(lo_error).
        MESSAGE lo_error TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    IF ls_popup-v_keep_previous <> abap_true.
      CLEAR: go_model->ms_cache-t_flight,
             go_model->ms_cache-t_hotel,
             go_model->ms_cache-t_transp.
    ENDIF.

    " PERNR & REINR will change during saving
    IF ls_popup-v_flight = abap_true.
      APPEND LINES OF ls_template-t_flight[] TO go_model->ms_cache-t_flight.
    ENDIF.
    IF ls_popup-v_hotel = abap_true.
      APPEND LINES OF ls_template-t_hotel[] TO go_model->ms_cache-t_hotel.
    ENDIF.
    IF ls_popup-v_transport = abap_true.
      APPEND LINES OF ls_template-t_transp[] TO go_model->ms_cache-t_transp.
    ENDIF.

    g_tabs-pressed_tab = mc_pai_cmd-tab_request_info.
    RAISE EVENT app_event EXPORTING iv_origin = mc_event-open.
  ENDMETHOD.

  METHOD _do_save.
    go_model->save( ).

    CHECK iv_re_open = abap_true.
    DATA(ls_command) = CORRESPONDING ts_command( zss_tv025_head ).
    ls_command-ucomm = mc_pai_cmd-open_request.
    go_model->exchange_command( ls_command ).
  ENDMETHOD.

  METHOD _is_saved.
    rv_ok = abap_true.
    CHECK go_model->is_changed( ) = abap_true.

    DATA(lv_answer) = zcl_eui_screen=>confirm(
        iv_title          = 'Confirmation'(cnf)
        iv_question       = |Save { zss_tv025_head-pernr ALPHA = OUT } - { zss_tv025_head-reinr ALPHA = OUT } before exit?|
        iv_icon_1         = 'ICON_SYSTEM_SAVE'
        iv_icon_2         = 'ICON_SYSTEM_END'
        iv_text_2         = 'Discards all changes'(dis)
        iv_display_cancel = abap_true ).

    CASE lv_answer.
      WHEN abap_true.
        _do_save( ).

      WHEN abap_false.
        MESSAGE 'Saving data canceled' TYPE 'S' DISPLAY LIKE 'W'.

      WHEN abap_undefined. " Cancel
        rv_ok = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD _do_open.
    g_tabs-pressed_tab = mc_pai_cmd-tab_request_info.

    go_model->lock( iv_unlock = abap_true ).

    go_model->get_by_key( EXPORTING is_db_key  = is_db_key
                          CHANGING  cs_db_item = zss_tv025_head ).
    IF iv_check_exists = abap_true AND zss_tv025_head IS INITIAL.
      MESSAGE |No travel request { is_db_key-pernr } - { is_db_key-reinr } exist in the database| TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

    IF mo_tree IS NOT INITIAL.
      mo_prefs->add_opened( is_db_key = is_db_key
                            iv_insert = abap_true ).
      mo_tree->add_opened( is_db_key = is_db_key
                           iv_insert = abap_true ).
    ENDIF.

    locked = abap_false.
    TRY.
        go_model->fill_cache( is_db_key ).
        IF go_model->lock( ) <> abap_true.
          locked = abap_true.
          zcx_eui_no_check=>raise_sys_error( ).
        ENDIF.

        IF go_model->ms_cache-s_head-zz_status = go_model->mc_status-approved OR
           go_model->ms_cache-s_head-zz_status = go_model->mc_status-canceled.
          locked = 'S'.
          zcx_eui_no_check=>raise_sys_error(
           iv_message = |It is not possible to edit '{ go_model->ms_cache-s_head-status_name }' requests| ).
        ENDIF.
      CATCH zcx_eui_no_check INTO DATA(lo_error).
        MESSAGE lo_error TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.

    zss_tv025_head = go_model->ms_cache-s_head.
    RAISE EVENT app_event EXPORTING iv_origin = mc_event-open.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

" 100, 11*
MODULE pbo_0100_main OUTPUT.
  go_editor->pbo_ui( ).
ENDMODULE.

MODULE f4_free_search INPUT.
  go_editor->mo_tree->f4_free_search( ).
ENDMODULE.
