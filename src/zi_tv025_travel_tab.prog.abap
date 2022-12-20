*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_tab DEFINITION INHERITING FROM lcl_ui_container ABSTRACT FRIENDS zcl_eui_event_caller.
  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF ms_tab,
        editor    TYPE string VALUE 'EDITOR',
        flight    TYPE string VALUE 'FLIGHT',
        hotel     TYPE string VALUE 'HOTEL',
        transport TYPE string VALUE 'TRANSP',
        attachmet TYPE string VALUE 'ATTACH',
      END OF ms_tab.

    CLASS-METHODS:
      get IMPORTING iv_name       TYPE string
          RETURNING VALUE(ro_tab) TYPE REF TO lcl_tab.

    METHODS:
      constructor
        IMPORTING
          iv_dynnr         TYPE sydynnr
          iv_title         TYPE csequence
          iv_row_end       TYPE i
          ir_table         TYPE REF TO data               OPTIONAL
          ir_screen_ui     TYPE REF TO data               OPTIONAL
          ir_penalty_bool  TYPE REF TO abap_bool          OPTIONAL
          ir_penalty_struc TYPE REF TO zss_tv025_penalty  OPTIONAL,

*      on_pbo_event FINAL FOR EVENT pbo_event OF zif_eui_manager IMPORTING sender,
      on_pai_event FINAL FOR EVENT pai_event OF zif_eui_manager IMPORTING sender iv_command cv_close,

      pbo_alv,

      pbo_ui IMPORTING it_customize    TYPE zcl_eui_screen=>tt_customize  OPTIONAL
                       iv_comment_text TYPE string                        OPTIONAL,

      pai_ui ABSTRACT IMPORTING VALUE(iv_command) TYPE syucomm
                      CHANGING  cv_close          TYPE abap_bool.
    CLASS-EVENTS:
       app_event " Move to lcl_editor ?
        EXPORTING VALUE(iv_origin) TYPE string.

  PROTECTED SECTION.
    DATA:
      mo_alv         TYPE REF TO zcl_eui_alv,
      ms_db_key      TYPE ts_db_key,
      mr_table       TYPE REF TO data,
      mr_screen_ui   TYPE REF TO data,
      mv_row_end     TYPE i,

      locked         TYPE abap_bool,
      name           TYPE string,
      dynnr          TYPE sydynnr,
      title          TYPE string,

      _penalty_bool  TYPE REF TO abap_bool,
      _penalty_struc TYPE REF TO zss_tv025_penalty,
      _saved_penalty TYPE zss_tv025_penalty.

    METHODS:
      _on_app_event FOR EVENT app_event OF lcl_tab IMPORTING iv_origin,

      _create_alv,

      _get_layout
        RETURNING VALUE(rs_layout) TYPE lvc_s_layo,

      _get_catalog
        RETURNING VALUE(rt_catalog) TYPE lvc_t_fcat,

      _get_toolbar
        RETURNING VALUE(rt_toolbar) TYPE ttb_button,

      _get_status
        RETURNING VALUE(rs_status) TYPE zif_eui_manager=>ts_status,

      _on_toolbar FOR EVENT toolbar OF cl_gui_alv_grid      "#EC CALLED
        IMPORTING
          e_object
          e_interactive,

      _on_user_command FOR EVENT user_command OF cl_gui_alv_grid "#EC CALLED
        IMPORTING
          sender
          e_ucomm,

      _on_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid "#EC CALLED
        IMPORTING sender es_row_no e_column_id,

      _edit_action IMPORTING io_grid    TYPE REF TO cl_gui_alv_grid
                             iv_command TYPE syucomm
                             iv_tabix   TYPE sytabix OPTIONAL,

      _show_item "CHANGING  cs_item        TYPE any
        RETURNING VALUE(rv_code) TYPE syucomm,

      need_refresh
        RETURNING VALUE(rv_refresh) TYPE abap_bool,

      _fill_table,

      _refresh_after,
      _refresh_now,

      _get_selected_index IMPORTING io_grid         TYPE REF TO cl_gui_alv_grid
                                    iv_error_msg    TYPE csequence
                          RETURNING VALUE(rv_tabix) TYPE sytabix,

      _get_comment_text FINAL RETURNING VALUE(rv_text) TYPE string,

      _check_recommended_fields RETURNING VALUE(rv_ok) TYPE abap_bool,

      _save_penalty_to_var IMPORTING iv_close TYPE abap_bool.
  PRIVATE SECTION.
    TYPES: BEGIN OF ts_tab,
             name TYPE string,
             ref  TYPE REF TO lcl_tab,
           END OF ts_tab.
    CLASS-DATA t_tab TYPE HASHED TABLE OF ts_tab WITH UNIQUE KEY name.
    DATA comment_memo TYPE REF TO cl_gui_textedit.
ENDCLASS.

CLASS lcl_tab IMPLEMENTATION.
  METHOD get.
    ASSIGN t_tab[ name = iv_name ] TO FIELD-SYMBOL(<ls_tab>).
    IF sy-subrc <> 0.
      INSERT VALUE #( name = iv_name ) INTO TABLE t_tab ASSIGNING <ls_tab>.
      DATA(lv_class_name) = |LCL_{ iv_name }|.
      CREATE OBJECT <ls_tab>-ref TYPE (lv_class_name).
      <ls_tab>-ref->name = iv_name.
    ENDIF.
    ro_tab = <ls_tab>-ref.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).
    dynnr         = iv_dynnr.
    mr_table      = ir_table.
    title         = iv_title.
    mv_row_end    = iv_row_end.

    mr_screen_ui  = ir_screen_ui.

    _penalty_bool  = ir_penalty_bool.
    _penalty_struc = ir_penalty_struc.

    SET HANDLER _on_app_event.
  ENDMETHOD.

  METHOD _on_app_event.
    CHECK iv_origin = mc_event-open.
    _refresh_after( ).
  ENDMETHOD.

  METHOD on_pai_event.
    CHECK sender IS INSTANCE OF zcl_eui_screen.

    IF iv_command CP '_NEW_*'.
      go_dict->create_item( iv_id = iv_command+5(1) ).
      RETURN.
    ENDIF.

    IF iv_command = 'OK' AND _check_recommended_fields( ) <> abap_true.
      cv_close->* = abap_false.
      RETURN.
    ENDIF.

    IF iv_command <> zif_eui_manager=>mc_cmd-cancel AND is_date_ok( ) <> abap_true.
      cv_close->* = abap_false.

      " go on for tab strip control
      IF iv_command NP 'TABS_*'.
        CLEAR iv_command.
      ENDIF.
      " RETURN. <---
    ENDIF.

    _save_penalty_to_var( cv_close->* ).

    " Redefine in sub classes only this method
    pai_ui( EXPORTING iv_command = iv_command
            CHANGING  cv_close   = cv_close->* ).
  ENDMETHOD.

  METHOD _save_penalty_to_var.
    CHECK _penalty_bool IS NOT INITIAL AND _penalty_struc IS NOT INITIAL.

    " For restoring previous
    IF _penalty_struc->* IS NOT INITIAL.
      _saved_penalty = _penalty_struc->*.
    ENDIF.
    _penalty_struc->* = COND #( WHEN _penalty_bool->* = 'X' THEN _saved_penalty ).

    IF iv_close = abap_true.
      CLEAR _saved_penalty.
    ENDIF.
  ENDMETHOD.

  METHOD pbo_alv.
    IF mo_alv IS INITIAL.
      _create_alv( ).
    ENDIF.

    IF need_refresh( ) = abap_true.
      _fill_table( ).
      mo_alv->get_grid( )->refresh_table_display( is_stable = VALUE #( row = 'X' col = 'X' ) ).
    ENDIF.
  ENDMETHOD.

  METHOD need_refresh.
    DATA ls_new_db_key LIKE ms_db_key.
    ls_new_db_key = VALUE #( pernr = zss_tv025_head-pernr
                             reinr = zss_tv025_head-reinr ).
    IF ms_db_key <> ls_new_db_key.
      ms_db_key = ls_new_db_key.
      rv_refresh = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD _fill_table.                                       "#EC NEEDED
    " Fill mr_table->*
    go_model->set_table_s_indices( ).
  ENDMETHOD.

  METHOD _refresh_after.
    CLEAR ms_db_key.
  ENDMETHOD.

  METHOD _refresh_now.
    CLEAR ms_db_key.
    pbo_alv( ).
    cl_gui_cfw=>set_new_ok_code( '-' ).
  ENDMETHOD.

  METHOD _create_alv.
    CREATE OBJECT mo_alv
      EXPORTING
        ir_table       = mr_table
        is_layout      = _get_layout( )
        it_mod_catalog = _get_catalog( ).
    mo_alv->add_handler( me ).
    "mo_alv->set_status( _get_status( ) ).

    " popup TAB for general purpose
    CHECK mv_row_end IS NOT INITIAL.
    mo_alv->pbo( io_container = NEW cl_gui_custom_container( container_name = |CONT_{ name }| ) ).
  ENDMETHOD.

  METHOD _get_layout.
    rs_layout = VALUE #( sel_mode = 'A' smalltitle = 'X' cwidth_opt = 'X' ).
  ENDMETHOD.

  METHOD _on_toolbar.
    CLEAR e_object->mt_toolbar[].
    CHECK e_interactive <> abap_true.
    e_object->mt_toolbar = _get_toolbar( ).
  ENDMETHOD.

  METHOD _get_toolbar.
    rt_toolbar = COND #( WHEN lcl_tab=>get( lcl_tab=>ms_tab-editor )->locked IS INITIAL
                         THEN VALUE #(
                          ( function = mc_pai_cmd-alv_insert text = |Create| icon = icon_insert_row )
                          ( function = mc_pai_cmd-alv_delete text = |Delete| icon = icon_delete_row )
    ) ).
  ENDMETHOD.

  METHOD _get_catalog.
    rt_catalog = VALUE #( ( fieldname = 'MANDT'           tech    = 'X' )
                          ( fieldname = 'REQUESTVRS'      tech    = 'X' )
                          ( fieldname = 'PLAN_REQUEST'    tech    = 'X' )
                          ( fieldname = 'EMPLOYEE_NUMBER' no_out  = 'X' )
                          ( fieldname = 'TRIP_NUMBER'     no_out  = 'X' )
                          ( fieldname = 'S_INDEX'         hotspot = 'X' coltext = `№` col_pos = 1 key = 'X' )
                          ).
  ENDMETHOD.

  METHOD _get_selected_index.
    io_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_row) ).
    IF lines( lt_row ) <> 1.
      MESSAGE iv_error_msg TYPE 'S'.
      RETURN.
    ENDIF.

    rv_tabix = lt_row[ 1 ]-index.
  ENDMETHOD.

  METHOD _on_user_command.
    _edit_action( io_grid    = sender
                  iv_command = e_ucomm ).
  ENDMETHOD.

  METHOD _on_hotspot_click.
    CHECK e_column_id-fieldname = 'S_INDEX'.

    _edit_action( io_grid    = sender
                  iv_command = mc_pai_cmd-alv_edit
                  iv_tabix   = es_row_no-row_id ).
  ENDMETHOD.

  METHOD _edit_action.
    ASSIGN mr_screen_ui->* TO FIELD-SYMBOL(<ls_screen_ui>).

    FIELD-SYMBOLS <lt_table> TYPE INDEX TABLE.
    ASSIGN mr_table->* TO <lt_table>.

    CASE iv_command.
      WHEN mc_pai_cmd-alv_insert.
        CLEAR <ls_screen_ui>.
        CHECK _show_item( ) = 'OK'. " CHANGING cs_item = <ls_screen_ui>
        APPEND <ls_screen_ui> TO <lt_table>.

      WHEN mc_pai_cmd-alv_edit. " mc_pai_cmd-alv_change OR mc_pai_cmd-alv_display.
        ASSIGN <lt_table>[ iv_tabix ] TO FIELD-SYMBOL(<ls_alv>).
        MOVE-CORRESPONDING <ls_alv> TO <ls_screen_ui>.

        CHECK _show_item( ) = 'OK'. " CHANGING cs_item = <ls_screen_ui>
        MOVE-CORRESPONDING <ls_screen_ui> TO <ls_alv>.

      WHEN mc_pai_cmd-alv_delete.
        DATA(lv_tabix) = _get_selected_index( io_grid      = io_grid
                                              iv_error_msg = 'Please select 1 item to remove'(plr) ).
        CHECK lv_tabix IS NOT INITIAL.

        CHECK zcl_eui_screen=>confirm( iv_title    = 'Are you sure'
                                       iv_question = |Delete selected 1 item?| ) = abap_true.
        DELETE <lt_table> INDEX lv_tabix.

      WHEN OTHERS.
        RETURN.
    ENDCASE.

    _refresh_now( ).
  ENDMETHOD.

  METHOD _show_item.
    TRY.
        DATA(lo_screen) = NEW zcl_eui_screen( iv_dynnr = dynnr ).
      CATCH zcx_eui_exception INTO DATA(lo_error).
        MESSAGE lo_error TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.

    lo_screen->set_status( _get_status( ) ).
    IF mv_row_end IS NOT INITIAL.
      lo_screen->popup( iv_col_end = 88
                        iv_row_end = mv_row_end ).
    ENDIF.

    rv_code = lo_screen->show( io_handler = me ).
  ENDMETHOD.

  METHOD pbo_ui.
    DATA(lv_locked) = lcl_tab=>get( lcl_tab=>ms_tab-editor )->locked.
    IF go_model->ms_cache-s_head IS INITIAL.
      lv_locked = abap_true.
    ENDIF.

    TRY.
        DATA(lo_screen) = NEW zcl_eui_screen( iv_dynnr = sy-dynnr
            )->customize( it_    = zcl_tv025_opt=>get_customize( sy-dynnr )
            )->customize( group2 = 'GRY'      input    = '0'
            )->customize( group2 = 'REQ'      required = COND #( WHEN lv_locked IS INITIAL                            THEN '1' ELSE '0' )
            )->customize( group1 = dynnr+1(3) input    = COND #( WHEN lv_locked IS INITIAL                            THEN '1' ELSE '0' )
            " For status LOCKED = 'S'
            )->customize( group1 = 'STA'      input    = COND #( WHEN lv_locked <>   abap_true                        THEN '1' ELSE '0' )
            )->customize( group2 = 'PEN'      input    = COND #( WHEN lv_locked IS INITIAL
                                                                  AND _penalty_bool IS NOT INITIAL
                                                                  AND _penalty_bool->* = abap_true
                                                                  THEN '1' ELSE '0' )
            )->customize( it_    = it_customize ).

        IF lv_locked IS NOT INITIAL.
          lo_screen->customize( group1 = 'VIS' input = '0' ).
        ENDIF.
        lo_screen->pbo( ).
      CATCH zcx_eui_exception INTO DATA(lo_error).
        MESSAGE lo_error TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    CHECK iv_comment_text IS SUPPLIED.
    IF comment_memo IS INITIAL.
      comment_memo = NEW #( parent = NEW cl_gui_custom_container( container_name = |{ name }_COMMENT| ) ).
    ENDIF.
    comment_memo->set_textstream( iv_comment_text ).

    comment_memo->set_readonly_mode( COND #( WHEN lv_locked IS NOT INITIAL THEN 1 ELSE 0 ) ).
    comment_memo->set_toolbar_mode(  COND #( WHEN lv_locked IS NOT INITIAL THEN 0 ELSE 1 ) ).
  ENDMETHOD.

  METHOD _check_recommended_fields.
    LOOP AT zcl_tv025_opt=>get_customize( dynnr ) ASSIGNING FIELD-SYMBOL(<ls_screen>) WHERE required = '2'.
      ASSIGN (<ls_screen>-name) TO FIELD-SYMBOL(<lv_field>).
      CHECK sy-subrc = 0 AND <lv_field> IS INITIAL.

      DATA(lv_empty_field) = CONV rollname( cl_abap_typedescr=>describe_by_data( <lv_field> )->get_relative_name( ) ).
      EXIT.
    ENDLOOP.

    IF lv_empty_field IS INITIAL AND
       _penalty_bool IS NOT INITIAL AND _penalty_bool->* = abap_true.
      lv_empty_field = find_empty( _penalty_struc->* ).
    ENDIF.

    IF lv_empty_field IS NOT INITIAL.
      show_filed_is_empty( lv_empty_field ).
      RETURN.
    ENDIF.

    rv_ok = abap_true.
  ENDMETHOD.

  METHOD _get_comment_text.
    comment_memo->get_textstream( EXPORTING  only_when_modified     = cl_gui_textedit=>true
                                  IMPORTING  text                   = rv_text
                                  EXCEPTIONS OTHERS                 = 3 ).
    CHECK sy-subrc = 0.
    cl_gui_cfw=>flush( EXCEPTIONS OTHERS = 0 ).
  ENDMETHOD.

  METHOD _get_status.
    rs_status = VALUE #( title = me->title ).
  ENDMETHOD.
ENDCLASS.
