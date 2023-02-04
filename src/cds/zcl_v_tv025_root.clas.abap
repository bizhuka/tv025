CLASS zcl_v_tv025_root DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_sadl_exit .
    INTERFACES zif_sadl_read_runtime .

    TYPES:
      BEGIN OF ts_passport,
        " Importing
        pernr        TYPE pernr-pernr,
        reinr        TYPE reinr,
        " Exporting
        passp_expiry TYPE ptk99-zz_passp_expiry,
        passp_number TYPE ptk99-zz_passp_number,
      END OF ts_passport .
    TYPES:
      BEGIN OF ts_image,
        " Importing
        pernr      TYPE pernr-pernr,
        " Exporting
        photo_path TYPE text255,
      END OF ts_image .
    TYPES:
      BEGIN OF ts_total,
        " Importing
        pernr       TYPE ftpt_req_head-pernr,
        reinr       TYPE ftpt_req_head-reinr,
        currency    TYPE ftpt_req_head-currency,
        " Exporting
        total_price TYPE decfloat34,
      END OF ts_total .
    TYPES:
      tt_passport TYPE STANDARD TABLE OF ts_passport WITH DEFAULT KEY .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS: _calculate_total CHANGING cs_total TYPE ts_total,
      _currency_conversion IMPORTING iv_date          TYPE d
                                     iv_target_curr   TYPE waers
                                     iv_source_curr   TYPE waers
                                     iv_amount        TYPE pad_amt7s
                           RETURNING VALUE(rv_amount) TYPE pad_amt7s.
ENDCLASS.



CLASS ZCL_V_TV025_ROOT IMPLEMENTATION.


  METHOD zif_sadl_read_runtime~execute.
    DATA(lv_datum) = sy-datum.

    IF iv_node_name = 'ZC_TV025_ROOT'.
      CASE lines( ct_data_rows[] ).
        WHEN 0.
          IF zcl_d_tv025_root_save=>created_root IS NOT INITIAL.
            APPEND INITIAL LINE TO ct_data_rows ASSIGNING FIELD-SYMBOL(<ls_row>).
            MOVE-CORRESPONDING zcl_d_tv025_root_save=>created_root TO <ls_row>.
          ENDIF.

        WHEN 1.
          ASSIGN COMPONENT 'ERROR_MESSAGE' OF STRUCTURE ct_data_rows[ 1 ] TO FIELD-SYMBOL(<lv_error_message>).
          IF sy-subrc = 0 AND zcl_a_tv025_lock=>mv_error_message IS NOT INITIAL.
            <lv_error_message> = zcl_a_tv025_lock=>mv_error_message.
          ENDIF.
      ENDCASE.
    ENDIF.

    cl_http_server=>if_http_server~get_location(
      IMPORTING host         = DATA(lv_host)
                port         = DATA(lv_port)
                out_protocol = DATA(lv_protocol) ).
    DATA(lv_fill_total) = xsdbool( line_exists( is_requested-elements[ table_line = |TOTAL_PRICE| ] ) ).

    LOOP AT ct_data_rows ASSIGNING <ls_row>.

      DATA(ls_passport) = CORRESPONDING ts_passport( <ls_row> ).
      DO 1 TIMES.
        CHECK ls_passport-reinr IS NOT INITIAL
          AND zcl_tv025_model=>get_instance( )->is_visitor( ls_passport-pernr ) <> abap_true.

        SELECT perio, pdvrs INTO TABLE @DATA(lt_ptrv_perio)
        FROM ptrv_perio
        WHERE pernr = @ls_passport-pernr AND
              reinr = @ls_passport-reinr.
        CHECK lt_ptrv_perio IS NOT INITIAL.

        SORT lt_ptrv_perio BY perio DESCENDING pdvrs DESCENDING.
        DATA(ls_te_key) = VALUE ptp00( pernr = ls_passport-pernr
                                       reinr = ls_passport-reinr
                                       perio = lt_ptrv_perio[ 1 ]-perio
                                       pdvrs = lt_ptrv_perio[ 1 ]-pdvrs ).
        DATA(lt_ptk99) = VALUE ptk99_t( ).
        IMPORT user TO lt_ptk99 FROM DATABASE pcl1(te) ID ls_te_key.
        CHECK lt_ptk99[] IS NOT INITIAL.

        ls_passport-passp_number = lt_ptk99[ 1 ]-zz_passp_number.
        ls_passport-passp_expiry = lt_ptk99[ 1 ]-zz_passp_expiry.
      ENDDO.

      " №2nd Attemp
      IF ls_passport-passp_number IS INITIAL.
        DATA(ls_0290) = CAST p0290( zcl_hr_read=>infty_row(
               iv_pernr   = ls_passport-pernr
               iv_infty   = '0290'
               iv_begda   = lv_datum
               iv_endda   = lv_datum
               iv_where   = |subty = 'KZFP'|
               iv_no_auth = 'X'
               is_default = VALUE p0290( ) ) )->*.
        ls_passport-passp_number = |{ ls_0290-seria }{ ls_0290-seri0 }{ ls_0290-nomer }|.
        ls_passport-passp_expiry = ls_0290-daten.
      ENDIF.

      DATA(ls_photo) = CORRESPONDING ts_image( <ls_row> ).
      ls_photo-photo_path = |{ lv_protocol }://{ lv_host }:{ lv_port }/sap/opu/odata/sap/ZC_TV025_ROOT_CDS/ZC_TV025_Attach(pernr='{
         ls_photo-pernr }',reinr='0000000000',doc_id='EMPLOYEE_PHOTO')/$value?sap-client={ sy-mandt }|.

      DATA(ls_total) = CORRESPONDING ts_total( <ls_row> ).
      IF lv_fill_total = abap_true.
        _calculate_total( CHANGING cs_total = ls_total ).
      ENDIF.

      MOVE-CORRESPONDING: ls_passport TO <ls_row>,
                          ls_photo    TO <ls_row>,
                          ls_total    TO <ls_row>.
    ENDLOOP.
  ENDMETHOD.


  METHOD _calculate_total.
    cs_total-currency = COND #( WHEN cs_total-currency IS NOT INITIAL THEN cs_total-currency
                                                                      ELSE 'KZT' ).
    SELECT date_beg,
           price,   waers,
           penalty, penalty_waers INTO TABLE @DATA(lt_flight)
    FROM zdtv025_flight
    WHERE employee_number = @cs_total-pernr
      AND trip_number     = @cs_total-reinr.

    SELECT date_beg,
           price,           waers,
           penalty,         penalty_waers,
           transport_price, transport_waers INTO TABLE @DATA(lt_hotel)
    FROM zdtv025_hotel
    WHERE employee_number = @cs_total-pernr
      AND trip_number     = @cs_total-reinr.

    LOOP AT lt_flight ASSIGNING FIELD-SYMBOL(<ls_flight>).
      cs_total-total_price = cs_total-total_price + _currency_conversion(
                                                        iv_date        = <ls_flight>-date_beg
                                                        iv_target_curr = cs_total-currency
                                                        iv_source_curr = <ls_flight>-waers
                                                        iv_amount      = <ls_flight>-price ) +
                                                   _currency_conversion(
                                                        iv_date        = <ls_flight>-date_beg
                                                        iv_target_curr = cs_total-currency
                                                        iv_source_curr = <ls_flight>-penalty_waers
                                                        iv_amount      = <ls_flight>-penalty ).
    ENDLOOP.


    LOOP AT lt_hotel ASSIGNING FIELD-SYMBOL(<ls_hotel>).
      cs_total-total_price = cs_total-total_price + _currency_conversion(
                                                        iv_date        = <ls_hotel>-date_beg
                                                        iv_target_curr = cs_total-currency
                                                        iv_source_curr = <ls_hotel>-waers
                                                        iv_amount      = <ls_hotel>-price ) +
                                                   _currency_conversion(
                                                        iv_date        = <ls_hotel>-date_beg
                                                        iv_target_curr = cs_total-currency
                                                        iv_source_curr = <ls_hotel>-penalty_waers
                                                        iv_amount      = <ls_hotel>-penalty ) +
                                                   _currency_conversion(
                                                        iv_date        = <ls_hotel>-date_beg
                                                        iv_target_curr = cs_total-currency
                                                        iv_source_curr = <ls_hotel>-transport_waers
                                                        iv_amount      = <ls_hotel>-transport_price ).
    ENDLOOP.
  ENDMETHOD.


  METHOD _currency_conversion.
    " TODO if no covertion rate exists
    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
      EXPORTING
        date             = iv_date
        foreign_amount   = iv_amount
        foreign_currency = iv_source_curr
        local_currency   = iv_target_curr
      IMPORTING
        local_amount     = rv_amount
      EXCEPTIONS
        OTHERS           = 0.
  ENDMETHOD.
ENDCLASS.
