*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_hotel DEFINITION INHERITING FROM lcl_tab FRIENDS zcl_eui_event_caller.
  PUBLIC SECTION.
    METHODS:
      constructor,

      pbo_ui      REDEFINITION,
      pai_ui      REDEFINITION.

  PROTECTED SECTION.
    DATA:
      mt_hotel   TYPE zcl_tv025_model=>ts_db_item-t_hotel,

      _saved_car TYPE zss_tv025_hotel_car.
    METHODS:
      _check_recommended_fields REDEFINITION.
ENDCLASS.

CLASS lcl_hotel IMPLEMENTATION.
  METHOD constructor.
    super->constructor( iv_dynnr         = '0300'
                        ir_table         = REF #( go_model->ms_cache-t_hotel )
                        ir_screen_ui     = REF #( zdtv025_hotel )
                        iv_title         = 'Accomodation Arrangement'
                        iv_row_end       = 35
                        ir_penalty_bool  = REF #( zdtv025_hotel-penalty_check )
                        ir_penalty_struc = REF #( zdtv025_hotel-_penalty ) ).

    init_date_checker( it_low  = VALUE #( ( REF #( zdtv025_hotel-date_beg ) ) )
                       it_high = VALUE #( ( REF #( zdtv025_hotel-date_end ) ) ) ).
  ENDMETHOD.

  METHOD pbo_ui.
    DATA(lv_locked) = lcl_tab=>get( lcl_tab=>ms_tab-editor )->locked.
    super->pbo_ui( iv_comment_text = CONV #( zdtv025_hotel-comment1 )
                   it_customize    = VALUE #( ( group2 = 'CAR'  input = COND #( WHEN lv_locked IS INITIAL AND zdtv025_hotel-assigned_car = abap_true THEN '1' ELSE '0' ) ) ) ).

    zdtv025_hotel_ui = VALUE #( ).

**********************************************************************
    SELECT SINGLE hotel_name, hotel_class, town_id, country_id AS country_end INTO CORRESPONDING FIELDS OF @zdtv025_hotel_ui
    FROM zdtv025_hotel_ca
    WHERE hotel_id = @zdtv025_hotel-hotel_end.

    ASSIGN go_model->mt_country[ land1 = zdtv025_hotel_ui-country_end ] TO FIELD-SYMBOL(<ls_country_end>).
    IF sy-subrc = 0.
      zdtv025_hotel_ui-country_end_txt = <ls_country_end>-landx.
    ENDIF.
**********************************************************************

    SELECT SINGLE hotel_basis_txt INTO zdtv025_hotel_ui-hotel_basis_txt
    FROM zdtv025_basis
    WHERE basis_id = zdtv025_hotel-basis.

    SELECT SINGLE agency_name INTO zdtv025_hotel_ui-agency_name
    FROM zdtv025_agency
    WHERE agency_id = zdtv025_hotel-agency.
  ENDMETHOD.

  METHOD pai_ui.
    IF zdtv025_hotel-date_beg IS NOT INITIAL AND zdtv025_hotel-date_end IS NOT INITIAL AND zdtv025_hotel-booked_nights IS NOT INITIAL
       AND zdtv025_hotel-booked_nights - 1 > zdtv025_hotel-date_end - zdtv025_hotel-date_beg.
      MESSAGE |Booked nights { zdtv025_hotel-booked_nights } exceeds range { zdtv025_hotel-date_beg DATE = USER } - { zdtv025_hotel-date_end DATE = USER }| TYPE 'S' DISPLAY LIKE 'W'.
    ENDIF.

    " For restoring previous
    IF zdtv025_hotel-_car IS NOT INITIAL.
      _saved_car = zdtv025_hotel-_car.
    ENDIF.
    zdtv025_hotel-_car = COND #( WHEN zdtv025_hotel-assigned_car = 'X' THEN _saved_car ).

    IF cv_close = abap_true.
      CLEAR _saved_car.
    ENDIF.

    zdtv025_hotel-comment1 = _get_comment_text( ).
  ENDMETHOD.

  METHOD _check_recommended_fields.
    DATA(lv_ok) = super->_check_recommended_fields( ).

    DO 1 TIMES.
      CHECK zdtv025_hotel-assigned_car = 'X'.

      DATA(lv_empty_field) = find_empty( zdtv025_hotel-_car ).
      CHECK lv_empty_field IS NOT INITIAL.

      show_filed_is_empty( lv_empty_field ).
      RETURN.
    ENDDO.

    rv_ok = lv_ok.
  ENDMETHOD.


ENDCLASS.


*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

MODULE pbo_0103 OUTPUT.
  lcl_tab=>get( lcl_tab=>ms_tab-hotel )->pbo_alv( ).
ENDMODULE.

MODULE pbo_0300 OUTPUT.
  lcl_tab=>get( lcl_tab=>ms_tab-hotel )->pbo_ui( ).
ENDMODULE.
