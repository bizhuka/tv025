*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_flight DEFINITION INHERITING FROM lcl_tab FRIENDS zcl_eui_event_caller.
  PUBLIC SECTION.
    METHODS:
      constructor,

      pbo_ui      REDEFINITION,
      pai_ui      REDEFINITION.

  PROTECTED SECTION.

    DATA:
      mt_flight      TYPE zcl_tv025_model=>ts_db_item-t_flight.
ENDCLASS.

CLASS lcl_flight IMPLEMENTATION.
  METHOD constructor.
    super->constructor( iv_dynnr         = '0200'
                        ir_table         = REF #( go_model->ms_cache-t_flight )
                        ir_screen_ui     = REF #( zdtv025_flight )
                        iv_title         = 'Travel Arrangement'
                        iv_row_end       = 37
                        ir_penalty_bool  = REF #( zdtv025_flight-penalty_box )
                        ir_penalty_struc = REF #( zdtv025_flight-_penalty )
                      ).
    init_date_checker( it_low  = VALUE #( ( REF #( zdtv025_flight-date_beg ) )
                                          ( REF #( zdtv025_flight-time_beg ) ) )
                       it_high = VALUE #( ( REF #( zdtv025_flight-date_end ) )
                                          ( REF #( zdtv025_flight-time_end ) ) ) ).
  ENDMETHOD.

  METHOD pbo_ui.
    super->pbo_ui( iv_comment_text = CONV #( zdtv025_flight-comment1 ) ).

    zdtv025_flight_ui = VALUE #( ).

    SELECT SINGLE agency_name INTO zdtv025_flight_ui-agency_name
    FROM zdtv025_agency
    WHERE agency_id = zdtv025_flight-agency.

**********************************************************************
    SELECT SINGLE airport_name AS airport_beg_txt, town AS town_beg, country_id AS country_beg INTO CORRESPONDING FIELDS OF @zdtv025_flight_ui
    FROM zdtv025_airport
    WHERE airport_id = @zdtv025_flight-airport_beg.

    zdtv025_flight_ui-country_beg_txt = go_model->get_country_text( zdtv025_flight_ui-country_beg ).
**********************************************************************
    SELECT SINGLE airport_name AS airport_end_txt, town AS town_end, country_id AS country_end INTO CORRESPONDING FIELDS OF @zdtv025_flight_ui
    FROM zdtv025_airport
    WHERE airport_id = @zdtv025_flight-airport_end.

    zdtv025_flight_ui-country_end_txt = go_model->get_country_text( zdtv025_flight_ui-country_end ).
**********************************************************************
  ENDMETHOD.

  METHOD pai_ui.
    zdtv025_flight-comment1 = _get_comment_text( ).
  ENDMETHOD.
ENDCLASS.


*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

MODULE pbo_0102 OUTPUT.
  lcl_tab=>get( lcl_tab=>ms_tab-flight )->pbo_alv( ).
ENDMODULE.

MODULE pbo_0200 OUTPUT.
  lcl_tab=>get( lcl_tab=>ms_tab-flight )->pbo_ui( ).
ENDMODULE.
