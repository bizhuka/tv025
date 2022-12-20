*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_attach DEFINITION INHERITING FROM lcl_tab FRIENDS zcl_eui_event_caller.
  PUBLIC SECTION.
    METHODS:
      constructor,
      pai_ui            REDEFINITION.

  PROTECTED SECTION.
    DATA:
      mo_attach TYPE REF TO zcl_v_tv025_attach,
      mt_attach TYPE mo_attach->tt_attach_alv.

    METHODS:
      _fill_table       REDEFINITION,
      _on_user_command  REDEFINITION,
      _get_layout       REDEFINITION,
      _get_catalog      REDEFINITION,

      _add_file,
      _delete_file      IMPORTING io_grid TYPE REF TO cl_gui_alv_grid,

      _on_hotspot_click REDEFINITION.
ENDCLASS.

CLASS lcl_attach IMPLEMENTATION.
  METHOD constructor.
    super->constructor( iv_dynnr     = '0400'
                        ir_table     = REF #( mt_attach )
                        iv_title     = 'Attachments'
                        iv_row_end   = -1  ).
    mo_attach = NEW #( ).
  ENDMETHOD.

  METHOD pai_ui.
  ENDMETHOD.

  METHOD _fill_table.
    mo_attach->set_key( CORRESPONDING #( zss_tv025_head )
            )->read( IMPORTING et_attach_alv = mt_attach[] ).
  ENDMETHOD.

  METHOD _get_layout.
    rs_layout = super->_get_layout( ).
    rs_layout-cwidth_opt = abap_false.
  ENDMETHOD.

  METHOD _get_catalog.
    rt_catalog = VALUE #( ( fieldname = 'CLASS'          tech = 'X' ) ( fieldname = 'OBJID'   tech = 'X' ) ( fieldname = 'DOC_ID' tech = 'X' )
                          ( fieldname = 'MESSAGE'        tech = 'X' ) ( fieldname = 'DOC_URL' tech = 'X' )
                          ( fieldname = 'PERNR'          tech = 'X' ) ( fieldname = 'REINR'   tech = 'X' )
                          ( fieldname = 'ICON'           coltext   = '---' )
                          ( fieldname = 'CREATED_*'      outputlen = 15 )
                          ( fieldname = 'CREATED_BY_TXT' outputlen = 40 )
                          ( fieldname = 'FILE_NAME'      outputlen = 50 )
                          ( fieldname = 'FILE_SIZE'      coltext   = |File size| )
                          ).
    APPEND LINES OF super->_get_catalog( ) TO rt_catalog[].
  ENDMETHOD.

  METHOD _on_hotspot_click.                                 "#EC NEEDED
    CHECK e_column_id-fieldname = 'S_INDEX'.

    ASSIGN mt_attach[ es_row_no-row_id ] TO FIELD-SYMBOL(<ls_oaor_file>).
    CHECK sy-subrc = 0.

    mo_attach->get_file_content( EXPORTING is_obj_key  = <ls_oaor_file>-_oaor_id
                                 IMPORTING ev_content  = DATA(lv_content)
                                           ev_filetype = DATA(lv_filetype) ).
    TRY.
        NEW zcl_eui_file( )->import_from_xstring( iv_xstring = lv_content
        )->download( iv_full_path   = <ls_oaor_file>-file_name
                     iv_filetype    = lv_filetype
                     iv_save_dialog = abap_true
        )->open( ).
      CATCH zcx_eui_exception INTO DATA(lo_error).
        MESSAGE lo_error TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD _on_user_command.
    CASE e_ucomm.
      WHEN mc_pai_cmd-alv_insert.
        _add_file( ).
      WHEN mc_pai_cmd-alv_delete.
        _delete_file( sender ).
    ENDCASE.
  ENDMETHOD.

  METHOD _add_file.
    TRY.
        DATA(lo_file) = NEW zcl_eui_file( ).
        lo_file->import_from_file( iv_window_title      = 'Please select a file'
                                   iv_default_extension = '*' ).
        CHECK lo_file->mv_xstring IS NOT INITIAL.
      CATCH zcx_eui_exception INTO DATA(lo_error).
        MESSAGE lo_error TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    TRY.
        CHECK mo_attach->add_file(
          iv_file_name    = lo_file->get_full_path( )
          iv_file_content = lo_file->mv_xstring ) = abap_true.
      CATCH /iwbep/cx_mgw_busi_exception INTO DATA(lo_load_error).
        MESSAGE lo_load_error->message_unlimited TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    MESSAGE |File { lo_file->get_full_path( ) } added successfully| TYPE 'S'.
    _refresh_now( ).
  ENDMETHOD.

  METHOD _delete_file.
    DATA(lv_tabix) = _get_selected_index( io_grid      = io_grid
                                          iv_error_msg = 'Please select 1 file to remove'(prf) ).
    CHECK lv_tabix IS NOT INITIAL.

    ASSIGN mt_attach[ lv_tabix ] TO FIELD-SYMBOL(<ls_attach>).
    CHECK zcl_eui_screen=>confirm( iv_title    = 'Are you sure'
                                   iv_question = |Delete selected { <ls_attach>-file_name } file?| ) = abap_true.

    TRY.
        mo_attach->zif_sadl_delete_runtime~execute(
         it_key_values = VALUE mo_attach->tt_attach_alv( ( <ls_attach> ) )
        ).
      CATCH cx_sadl_static INTO DATA(lo_error).
        MESSAGE lo_error TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    MESSAGE |File { <ls_attach>-file_name } deleted successfully| TYPE 'S'.
    _refresh_now( ).
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*


MODULE pbo_0105 OUTPUT.
  lcl_tab=>get( lcl_tab=>ms_tab-attachmet )->pbo_alv( ).
ENDMODULE.
