*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_transp DEFINITION INHERITING FROM lcl_tab FRIENDS zcl_eui_event_caller.
  PUBLIC SECTION.
    METHODS:
      constructor,
      pbo_ui      REDEFINITION,
      pai_ui      REDEFINITION.

  PROTECTED SECTION.
    DATA:
      mt_transp      TYPE zcl_tv025_model=>ts_db_item-t_transp.
ENDCLASS.

CLASS lcl_transp IMPLEMENTATION.
  METHOD constructor.
    super->constructor( iv_dynnr      = '0400'
                        ir_table      = REF #( go_model->ms_cache-t_transp )
                        ir_screen_ui  = REF #( zdtv025_transp )
                        iv_title      = 'Transport arrangements'
                        iv_row_end    = 30  ).
    init_date_checker( it_low  = VALUE #( ( REF #( zdtv025_transp-date_beg ) )
                                          ( REF #( zdtv025_transp-time_beg ) ) )
                       it_high = VALUE #( ( REF #( zdtv025_transp-date_end ) )
                                          ( REF #( zdtv025_transp-time_end ) ) ) ).
  ENDMETHOD.

  METHOD pbo_ui.
    super->pbo_ui( iv_comment_text = CONV #( zdtv025_transp-comment1 ) ).

    zdtv025_transp_ui = VALUE #( ).

    SELECT SINGLE kurztext INTO zdtv025_transp_ui-arrival_txt
    FROM zdtv025_checkp
    WHERE id EQ zdtv025_transp-arrival.

    SELECT SINGLE kurztext INTO zdtv025_transp_ui-check_point_name
    FROM zdtv025_checkp
    WHERE id EQ zdtv025_transp-check_point.
  ENDMETHOD.

  METHOD pai_ui.
    zdtv025_transp-comment1 = _get_comment_text( ).
  ENDMETHOD.
ENDCLASS.


*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

MODULE pbo_0104 OUTPUT.
  lcl_tab=>get( lcl_tab=>ms_tab-transport )->pbo_alv( ).
ENDMODULE.

MODULE pbo_0400 OUTPUT.
  lcl_tab=>get( lcl_tab=>ms_tab-transport )->pbo_ui( ).
ENDMODULE.
