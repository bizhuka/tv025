*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_visitor_request DEFINITION INHERITING FROM lcl_ui_container FINAL.
  PUBLIC SECTION.
    INTERFACES lif_request.

    DATA: mr_popup        TYPE REF TO zss_tv025_empl_vis_popup,
          _previous_pernr TYPE zss_tv025_empl_vis_popup-pernr,
          _previous_reinr TYPE zss_tv025_empl_vis_popup-reinr_tr.

    METHODS:
      _on_pbo_new_visitor_request FOR EVENT pbo_event OF zif_eui_manager
        IMPORTING
          sender
          io_container,

      _on_pai_new_visitor_request FOR EVENT pai_event OF zif_eui_manager
        IMPORTING
          sender
          iv_command
          cv_close,

      _get_next_visitor_id RETURNING VALUE(rv_id) TYPE zss_tv025_empl_vis_popup-pernr,
      _get_next_reinr      IMPORTING iv_visitor_id   TYPE zss_tv025_empl_vis_popup-pernr
                           RETURNING VALUE(rv_reinr) TYPE zss_tv025_empl_vis_popup-reinr_tr,

      _can_save RETURNING VALUE(rv_ok) TYPE abap_bool,
      _check_visitor_exists IMPORTING iv_visitor_id    TYPE zss_tv025_empl_vis_popup-pernr
                            RETURNING VALUE(rv_exists) TYPE abap_bool,
      _check_travel_exists IMPORTING iv_visitor_id    TYPE zss_tv025_empl_vis_popup-pernr
                                     iv_reinr         TYPE zss_tv025_empl_vis_popup-reinr_tr
                           RETURNING VALUE(rv_exists) TYPE abap_bool.
ENDCLASS.


CLASS lcl_visitor_request IMPLEMENTATION.
  METHOD lif_request~get_db_key.
    mr_popup = NEW #( use_existing_visitor = 'X' ).

    init_date_checker( it_low  = VALUE #( ( REF #( mr_popup->date_beg_tr ) ) )
                       it_high = VALUE #( ( REF #( mr_popup->date_end_tr ) ) ) ).

    SELECT acticity AS key, name AS text INTO TABLE @DATA(lt_activity)
    FROM ta20r1
    WHERE spras = @sy-langu.

    TRY.
        CHECK NEW zcl_eui_screen( iv_dynnr   = zcl_eui_screen=>mc_dynnr-dynamic
                                  ir_context = mr_popup
                                  iv_cprog   = |{ sy-cprog }_NEW_VIS|
              )->customize( it_  = zcl_tv025_opt=>get_customize( 'VISI' )
              )->customize( name = 'ACTIVITY_TYPE_TR' it_listbox = CORRESPONDING #( lt_activity )

              )->set_status( VALUE #( prog    = sy-repid
                                      name    = 'OK_CANCEL'
                                      exclude = VALUE #( ( 'OK' ) ) )
              )->popup( iv_col_beg = 30
                        iv_col_end = 112

              )->show( me ) = mc_pai_cmd-save.
      CATCH zcx_eui_exception INTO DATA(lo_error).
        MESSAGE lo_error TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    rs_db_key = VALUE #( pernr = mr_popup->pernr
                         reinr = mr_popup->reinr_tr ).
  ENDMETHOD.

  METHOD _on_pbo_new_visitor_request.
    CHECK io_container IS INITIAL.
    DATA(lo_screen) = CAST zcl_eui_screen( sender ).
    DATA(lr_popup) = CAST zss_tv025_empl_vis_popup( lo_screen->get_context( ) ).

    lo_screen->customize( name = 'PERNR'    input = COND #( WHEN lr_popup->use_existing_visitor <> 'X' THEN '0' ELSE '1' ) ).
    lo_screen->customize( name = 'REINR_TR' input = COND #( WHEN lr_popup->use_existing_trip    <> 'X' THEN '0' ELSE '1' ) ).
  ENDMETHOD.

  METHOD _on_pai_new_visitor_request.
    " Screen data
    DATA(lo_screen) = CAST zcl_eui_screen( sender ).
    DATA(lr_popup) = CAST zss_tv025_empl_vis_popup( lo_screen->get_context( ) ).

**********************************************************************
    " For restoring previous
    IF lr_popup->pernr IS NOT INITIAL.
      _previous_pernr = lr_popup->pernr.
    ENDIF.
    lr_popup->pernr = COND #( WHEN lr_popup->use_existing_visitor <> 'X' THEN '' ELSE _previous_pernr ).

    IF lr_popup->reinr_tr IS NOT INITIAL.
      _previous_reinr = lr_popup->reinr_tr.
    ENDIF.
    lr_popup->reinr_tr = COND #( WHEN lr_popup->use_existing_trip <> 'X' THEN '' ELSE _previous_reinr ).
**********************************************************************

    CASE iv_command.
      WHEN mc_pai_cmd-copy.
        lcl_employee_request=>set_template( EXPORTING io_screen = lo_screen
                                            CHANGING  cs_db_key = lr_popup->_template ).
      WHEN mc_pai_cmd-save.
        IF _can_save( ) = abap_true.
          cv_close->* = abap_true.
        ENDIF.
    ENDCASE.

    lo_screen->set_init_params( ).
  ENDMETHOD.

  METHOD _can_save.
    DATA(lv_empty_field) = COND rollname( WHEN mr_popup->use_existing_visitor = 'X' AND mr_popup->pernr IS INITIAL    THEN 'ZDE_TV025_VISITOR_ID'
                                          WHEN mr_popup->use_existing_trip    = 'X' AND mr_popup->reinr_tr IS INITIAL THEN 'ZDE_TV025_VISITOR_REINR'
                                          ELSE find_empty( mr_popup->_visitor ) ).
    IF lv_empty_field IS INITIAL.
      lv_empty_field = find_empty( mr_popup->_visitor_request ).
    ENDIF.

    IF lv_empty_field IS NOT INITIAL.
      show_filed_is_empty( lv_empty_field ).
      RETURN.
    ENDIF.

    IF is_date_ok( ) <> abap_true.
      RETURN.
    ENDIF.

    IF mr_popup->pernr IS NOT INITIAL AND _check_visitor_exists( mr_popup->pernr ) <> abap_true.
      MESSAGE |The visitor id { mr_popup->pernr ALPHA = OUT } doesn't exists| TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    IF mr_popup->reinr_tr IS NOT INITIAL AND _check_travel_exists( iv_visitor_id = mr_popup->pernr
                                                                   iv_reinr      = mr_popup->reinr_tr ) <> abap_true.
      MESSAGE |The travel { mr_popup->pernr ALPHA = OUT } { mr_popup->reinr_tr ALPHA = OUT } doesn't exists| TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    IF mr_popup->pernr IS INITIAL.
      mr_popup->pernr = _get_next_visitor_id( ).
    ENDIF.

    mr_popup->pernr_tr = mr_popup->pernr.
    IF mr_popup->reinr_tr IS INITIAL.
      mr_popup->reinr_tr = _get_next_reinr( mr_popup->pernr ).
    ENDIF.

    IF mr_popup->pernr IS INITIAL OR mr_popup->reinr_tr IS INITIAL.
      RETURN.
    ENDIF.

    rv_ok = abap_true.
  ENDMETHOD.

  METHOD lif_request~after_created.
*    CHECK mr_popup IS NOT INITIAL. better dump

    CHECK is_db_key-pernr = mr_popup->pernr
      AND is_db_key-reinr = mr_popup->reinr_tr.

    " Both DB data stored in header
    MOVE-CORRESPONDING: mr_popup->_visitor_request TO go_model->ms_cache-s_head,
                        mr_popup->_visitor         TO go_model->ms_cache-s_head.
    zss_tv025_head = go_model->ms_cache-s_head.

    lcl_employee_request=>copy_positions_from( mr_popup->_template ).

    " And save
    go_model->exchange_command( VALUE #( ucomm = mc_pai_cmd-save ) ).
  ENDMETHOD.

  METHOD _check_visitor_exists.
    SELECT SINGLE @abap_true INTO @rv_exists
    FROM zdtv025_visitor
    WHERE pernr = @iv_visitor_id.
  ENDMETHOD.

  METHOD _check_travel_exists.
    SELECT SINGLE @abap_true INTO @rv_exists
    FROM zc_tv025_root
    WHERE pernr = @iv_visitor_id
      AND reinr = @iv_reinr.
  ENDMETHOD.

  METHOD _get_next_visitor_id.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '1'
        object      = 'ZTV025_VIS'
      IMPORTING
        number      = rv_id
      EXCEPTIONS
        OTHERS      = 8.

    CHECK sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
  ENDMETHOD.

  METHOD _get_next_reinr.
    SELECT SINGLE MAX( reinr ) INTO @rv_reinr
    FROM zc_tv025_root
    WHERE pernr = @iv_visitor_id.

    rv_reinr = rv_reinr + 1.
  ENDMETHOD.
ENDCLASS.
