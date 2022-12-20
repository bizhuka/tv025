*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_employee_request DEFINITION INHERITING FROM lcl_ui_container FINAL.
  PUBLIC SECTION.
    INTERFACES lif_request.

    DATA:
      mr_popup TYPE REF TO zss_tv025_empl_req_popup.

    METHODS:
      _on_pai_new_employee_request FOR EVENT pai_event OF zif_eui_manager
        IMPORTING
          sender
          iv_command.

    CLASS-METHODS:
      copy_positions_from IMPORTING is_db_key TYPE ts_db_key,

      set_template IMPORTING io_screen TYPE REF TO zcl_eui_screen
                   CHANGING  cs_db_key TYPE ts_db_key.
ENDCLASS.


CLASS lcl_employee_request IMPLEMENTATION.
  METHOD lif_request~get_db_key.
    DATA(ls_db_key) = go_editor->mo_tree->show_f4( abap_false ).
    CHECK ls_db_key IS NOT INITIAL.

    " Is the key exists?
    DATA ls_key TYPE zss_tv_travel_request_key.
    go_model->get_by_key( EXPORTING is_db_key  = ls_db_key
                          CHANGING  cs_db_item = ls_key ).
    IF ls_key IS NOT INITIAL.
      MESSAGE |Item { ls_db_key-pernr ALPHA = OUT } - { ls_db_key-reinr ALPHA = OUT } already created| TYPE 'S' DISPLAY LIKE 'W'.
      rs_db_key = ls_db_key.
      RETURN.
    ENDIF.

**********************************************************************
**********************************************************************
    DATA(ls_travel) = go_model->get_header( ls_db_key ).
    mr_popup = NEW #( pernr = ls_db_key-pernr
                      reinr = ls_db_key-reinr ).
    TRY.
        CHECK NEW zcl_eui_screen( iv_dynnr   = zcl_eui_screen=>mc_dynnr-dynamic
                                  ir_context = mr_popup
                                  iv_cprog   = |{ sy-cprog }_NEW_REQ|
              )->customize( it_  = zcl_tv025_opt=>get_customize( 'EMPL' )
              )->customize( name = 'PERNR' iv_label = ls_travel-ename
              )->customize( name = 'REINR' iv_label = ls_travel-request_reason

              )->set_status( VALUE #( prog    = sy-repid
                                      name    = 'OK_CANCEL'
                                      title   = 'Please specify travel Request key'
                                      exclude = VALUE #( ( mc_pai_cmd-save ) ) )
              )->popup( iv_col_beg = 30
                        iv_col_end = 78

              )->show( me ) = 'OK'.
      CATCH zcx_eui_exception INTO DATA(lo_error).
        MESSAGE lo_error TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    rs_db_key = mr_popup->_new.
  ENDMETHOD.

  METHOD _on_pai_new_employee_request.
    CHECK iv_command = mc_pai_cmd-copy.

    " Screen data
    DATA(lo_screen) = CAST zcl_eui_screen( sender ).
    DATA(lr_popup) = CAST zss_tv025_empl_req_popup( lo_screen->get_context( ) ).

    set_template( EXPORTING io_screen = lo_screen
                  CHANGING  cs_db_key = lr_popup->_template ).
  ENDMETHOD.

  METHOD lif_request~after_created.
    CHECK mr_popup IS NOT INITIAL
      AND is_db_key = mr_popup->_new.

    copy_positions_from( mr_popup->_template ).
  ENDMETHOD.

  METHOD set_template.
    DATA(ls_db_key) = go_editor->mo_tree->show_f4( abap_true ).
    CHECK ls_db_key IS NOT INITIAL.

    cs_db_key = ls_db_key.

    DATA(ls_template) = go_model->get_header( ls_db_key ).
    io_screen->customize( name = 'PERNR_TM'    iv_label = ls_template-ename
            )->customize( name = 'REINR_TM'    iv_label = ls_template-request_reason
            )->set_init_params( ).
  ENDMETHOD.

  METHOD copy_positions_from.
    CHECK is_db_key IS NOT INITIAL.

    DATA(ls_template) = go_model->read_db( is_db_key ).

    " PERNR & REINR will change during saving
    go_model->ms_cache-t_flight = ls_template-t_flight[].
    go_model->ms_cache-t_hotel  = ls_template-t_hotel[].
    go_model->ms_cache-t_transp = ls_template-t_transp[].
  ENDMETHOD.
ENDCLASS.
