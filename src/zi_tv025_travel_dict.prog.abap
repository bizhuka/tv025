*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_dict DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES: BEGIN OF ts_field,
             id        TYPE char1,
             db_table  TYPE tabname16,
             scr_field TYPE string,
           END OF ts_field.
    CONSTANTS: BEGIN OF ms_operation,
                 create TYPE string VALUE 'Create',
                 edit   TYPE string VALUE 'Edit',
               END OF ms_operation.

    DATA: mt_field     TYPE STANDARD TABLE OF ts_field,
          mr_db_item   TYPE REF TO data,
          mv_key_field TYPE string,
          mv_scr_field TYPE string.

    METHODS:
      constructor,
      show_all,
      show_f4 IMPORTING iv_scr_field  TYPE csequence
              RETURNING VALUE(rv_key) TYPE string,

      create_item IMPORTING iv_id TYPE char1,

      _get_key_field IMPORTING iv_db_table         TYPE tabname16
                     RETURNING VALUE(rv_key_field) TYPE string,

      _is_exists IMPORTING iv_db_key        TYPE any
                 RETURNING VALUE(rv_exists) TYPE abap_bool,

      _customize_ui  IMPORTING io_screen    TYPE REF TO zcl_eui_screen
                               is_field     TYPE ts_field
                               iv_operation TYPE string,

      _set_status IMPORTING io_screen    TYPE REF TO zcl_eui_screen
                            is_field     TYPE ts_field
                            iv_operation TYPE string,

      _on_pai_event FOR EVENT pai_event OF zif_eui_manager IMPORTING sender iv_command.
ENDCLASS.


CLASS lcl_dict IMPLEMENTATION.
  METHOD constructor.
    mt_field = VALUE #(
        " Hotel - screen 300
      ( id = '1' db_table = |ZDTV025_HOTEL_CA| scr_field = |ZDTV025_HOTEL-HOTEL_END| )
      ( id = '2' db_table = |ZDTV025_BASIS|    scr_field = |ZDTV025_HOTEL-BASIS| )
      ( id = '3' db_table = |ZDTV025_AGENCY|   scr_field = |ZDTV025_HOTEL-AGENCY| )
        " Flight - screen 200
      ( id = '4' db_table = |ZDTV025_AGENCY|   scr_field = |ZDTV025_FLIGHT-AGENCY| )
      ( id = '5' db_table = |ZDTV025_AIRPORT|  scr_field = |ZDTV025_FLIGHT-AIRPORT_BEG| )
      ( id = '6' db_table = |ZDTV025_AIRPORT|  scr_field = |ZDTV025_FLIGHT-AIRPORT_END| )
        " Transport - screen 400
      ( id = '7' db_table = |ZDTV025_CHECKP|   scr_field = |ZDTV025_TRANSP-CHECK_POINT| )
      ( id = '8' db_table = |ZDTV025_CHECKP|   scr_field = |ZDTV025_TRANSP-ARRIVAL| ) ).
  ENDMETHOD.

  METHOD show_all.
    SELECT m~tabname, t~ddtext INTO TABLE @DATA(lt_dict)
    FROM dd02l AS m INNER JOIN dd02t AS t ON t~tabname    = m~tabname
                                         AND t~ddlanguage = @sy-langu
                                         AND t~as4local   = m~as4local
                                         AND t~as4vers    = m~as4vers
    WHERE m~tabname  LIKE 'ZDTV025_%'
      AND m~tabclass EQ   'TRANSP'
      AND m~mainflag EQ   'X'.

    DATA(lt_return) = VALUE hrreturn_tab( ).
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield   = 'TABNAME'
        dynpprog   = sy-repid
        dynpnr     = sy-dynnr
        value_org  = 'S'
      TABLES
        value_tab  = lt_dict
        return_tab = lt_return
      EXCEPTIONS
        OTHERS     = 0.
    CHECK lt_return[] IS NOT INITIAL.

    DATA(lv_table_name) = CONV char30( lt_return[ 1 ]-fieldval ).
    CALL FUNCTION 'SE16N_INTERFACE'
      EXPORTING
        i_tab         = lv_table_name
        i_edit        = zcl_tv025_opt=>is_super( sy-uname )
        i_sapedit     = abap_true
        i_display_all = abap_true
      EXCEPTIONS
        OTHERS        = 0.
  ENDMETHOD.

  METHOD show_f4.
    ASSIGN mt_field[ scr_field = iv_scr_field ] TO FIELD-SYMBOL(<ls_field>).
    ASSERT sy-subrc = 0.

    SELECT SINGLE shlpname INTO @DATA(lv_search_help) "#EC CI_GENBUFF
    FROM dd30l
    WHERE selmethod = @<ls_field>-db_table
      AND selmtype  = 'T'
      AND as4local  = 'A'.
    ASSERT sy-subrc = 0.

    DATA lt_ret  TYPE STANDARD TABLE OF ddshretval.
    CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
      EXPORTING
        tabname    = ''                               "#EC NOTEXT
        fieldname  = ''                               "#EC NOTEXT
        searchhelp = lv_search_help
        dynpprog   = sy-repid
        dynpnr     = sy-dynnr
      TABLES
        return_tab = lt_ret
      EXCEPTIONS
        OTHERS     = 0.
    CHECK lt_ret[] IS NOT INITIAL.

    rv_key = lt_ret[ recordpos = 1 ]-fieldval.
  ENDMETHOD.

  METHOD create_item.
    ASSIGN mt_field[ id = iv_id ] TO FIELD-SYMBOL(<ls_field>).
    ASSERT sy-subrc = 0.
    mv_scr_field = <ls_field>-scr_field.

    CREATE DATA mr_db_item TYPE (<ls_field>-db_table).
    ASSIGN mr_db_item->* TO FIELD-SYMBOL(<ls_db_item>).

    TRY.
        DATA(lo_screen) = NEW zcl_eui_screen( ir_context = mr_db_item
                                              iv_dynnr   = zcl_eui_screen=>mc_dynnr-dynamic
                                              iv_cprog   = |{ <ls_field>-db_table }_INS| ).
      CATCH zcx_eui_exception INTO DATA(lo_error).
        MESSAGE lo_error TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    mv_key_field = _get_key_field( <ls_field>-db_table ).

    ASSIGN : COMPONENT mv_key_field OF STRUCTURE <ls_db_item> TO FIELD-SYMBOL(<lv_key_field>),
             (mv_scr_field)                                   TO FIELD-SYMBOL(<lv_screen_result_field>).

    DATA(lv_operation) = COND #( WHEN _is_exists( <lv_screen_result_field> )
                                 THEN ms_operation-edit
                                 ELSE ms_operation-create ).

    " From screen to popup
    <lv_key_field> = <lv_screen_result_field>.

    _customize_ui(  io_screen    = lo_screen
                    is_field     = <ls_field>
                    iv_operation = lv_operation  ).

    _set_status( io_screen    = lo_screen
                 is_field     = <ls_field>
                 iv_operation = lv_operation  ).

    " Show popup screen
    WHILE lo_screen->show( me ) = 'OK'.
      CASE lv_operation.
        WHEN ms_operation-create. INSERT (<ls_field>-db_table) FROM <ls_db_item>.
        WHEN ms_operation-edit.   MODIFY (<ls_field>-db_table) FROM <ls_db_item>.
      ENDCASE.

      " For create only!
      IF sy-subrc <> 0.
        MESSAGE |Item '{ <lv_key_field> }' already exists. { lv_operation } operation failed.| TYPE 'S' DISPLAY LIKE 'E'.
        " Show popup again
        CONTINUE.
      ENDIF.
      COMMIT WORK AND WAIT.

      " To screen from popup
      <lv_screen_result_field> = <lv_key_field>.
      MESSAGE |{ lv_operation } operation completed successfully| TYPE 'S'.
      EXIT.
    ENDWHILE.
  ENDMETHOD.

  METHOD _get_key_field.
    SELECT DISTINCT fieldname INTO TABLE @DATA(lt_required_fld)
    FROM dd03l
    WHERE tabname   EQ @iv_db_table
      AND keyflag   EQ @abap_true
      AND fieldname NE 'MANDT'
      AND as4local  EQ 'A'
      AND as4vers   EQ 0000.

    " key = MANDT + some field
    ASSERT lines( lt_required_fld ) = 1.
    rv_key_field = lt_required_fld[ 1 ]-fieldname.
  ENDMETHOD.

  METHOD _is_exists.
    ASSIGN mt_field[ scr_field = mv_scr_field ] TO FIELD-SYMBOL(<ls_field>).
    ASSERT sy-subrc = 0.

    DATA(lv_where)  = |{ mv_key_field } = '{ iv_db_key }'|.

    ASSIGN mr_db_item->* TO FIELD-SYMBOL(<ls_db_item>).
    SELECT SINGLE * INTO @<ls_db_item>
    FROM (<ls_field>-db_table)
    WHERE (lv_where).

    rv_exists = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.

  METHOD _set_status.
    SELECT SINGLE ddtext INTO @DATA(lv_db_title)
    FROM dd02t
    WHERE tabname    = @is_field-db_table
      AND ddlanguage = @sy-langu
      AND as4local   = 'A'
      AND as4vers    = 0000.
    io_screen->set_status( VALUE #( prog    = sy-repid
                                    name    = 'OK_CANCEL'
                                    " Show copy button for 'Create' only
                                    exclude = COND #( WHEN iv_operation <> ms_operation-create THEN VALUE #( ( mc_pai_cmd-copy ) ) )
                                    title   = lv_db_title ) ).
    APPEND mc_pai_cmd-save TO io_screen->ms_status-exclude[].

    io_screen->get_dimension( IMPORTING ev_col_end = DATA(lv_col_end) ).
    io_screen->popup( iv_col_end = lv_col_end ).
  ENDMETHOD.

  METHOD _customize_ui.
    io_screen->customize( name     = mv_key_field
                          required = '1'
                          input    = COND #( WHEN iv_operation = ms_operation-edit THEN '0' ELSE '1' ) ).
    io_screen->customize( name = 'MANDT' active = '0' iv_label = |{ iv_operation }:| ).
  ENDMETHOD.

  METHOD _on_pai_event.
    CHECK iv_command = mc_pai_cmd-copy.
    DATA(lv_f4_key) = go_dict->show_f4( mv_scr_field ).
    CHECK lv_f4_key IS NOT INITIAL.

    ASSIGN mr_db_item->* TO FIELD-SYMBOL(<ls_db_item>).
    ASSIGN COMPONENT mv_key_field OF STRUCTURE <ls_db_item> TO FIELD-SYMBOL(<lv_key_field>).

    " Update <lv_key_field> from screen
    DATA(lo_screen) = CAST zcl_eui_screen( sender ).
    lo_screen->get_context( ).
    DATA(lv_screen_key) = CONV string( <lv_key_field> ).

    _is_exists( lv_f4_key ).
    <lv_key_field> = lv_screen_key.

    lo_screen->set_init_params( ).
  ENDMETHOD.
ENDCLASS.


MODULE general_pov INPUT.
  PERFORM general_pov.
ENDMODULE.


FORM general_pov.
  DATA(lv_scr_field) = ||.
  GET CURSOR FIELD lv_scr_field.

  DATA(lv_key) = go_dict->show_f4( lv_scr_field ).
  CHECK lv_key IS NOT INITIAL.

  " Write back
  ASSIGN (lv_scr_field) TO FIELD-SYMBOL(<lv_scr_field>).
  <lv_scr_field> = lv_key.

  go_model->exchange_command( VALUE #( ucomm = 'DUMMY' ) ).
ENDFORM.
