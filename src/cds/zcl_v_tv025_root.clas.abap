class ZCL_V_TV025_ROOT definition
  public
  final
  create public .

public section.

  interfaces ZIF_SADL_EXIT .
  interfaces ZIF_SADL_READ_RUNTIME .
  interfaces ZIF_SADL_MPC .

  types:
    BEGIN OF ts_passport,
        " Importing
        pernr        TYPE pernr-pernr,
        reinr        TYPE reinr,
        " Exporting
        passp_expiry TYPE ptk99-zz_passp_expiry,
        passp_number TYPE ptk99-zz_passp_number,
      END OF ts_passport .
  types:
    BEGIN OF ts_total,
        " Importing
        pernr       TYPE ftpt_req_head-pernr,
        reinr       TYPE ftpt_req_head-reinr,
        currency    TYPE ftpt_req_head-currency,
        " Exporting
        total_price TYPE decfloat34,
      END OF ts_total .
  types:
    tt_passport TYPE STANDARD TABLE OF ts_passport WITH DEFAULT KEY .

  methods FILL_ALV
    importing
      !IV_FILL_TOTAL type ABAP_BOOL optional
    changing
      !CT_ALV type STANDARD TABLE .
  PROTECTED SECTION.
private section.

  methods _CALCULATE_TOTAL
    changing
      !CS_TOTAL type TS_TOTAL .
  methods _CURRENCY_CONVERSION
    importing
      !IV_DATE type D
      !IV_TARGET_CURR type WAERS
      !IV_SOURCE_CURR type WAERS
      !IV_AMOUNT type PAD_AMT7S
    returning
      value(RV_AMOUNT) type PAD_AMT7S .
ENDCLASS.



CLASS ZCL_V_TV025_ROOT IMPLEMENTATION.


  METHOD fill_alv.
    DATA(lv_datum) = sy-datum.
    LOOP AT ct_alv ASSIGNING FIELD-SYMBOL(<ls_row>).

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

      DATA(ls_total) = CORRESPONDING ts_total( <ls_row> ).
      IF iv_fill_total = abap_true.
        _calculate_total( CHANGING cs_total = ls_total ).
      ENDIF.

      MOVE-CORRESPONDING: ls_passport TO <ls_row>,
                          ls_total    TO <ls_row>.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_sadl_mpc~define.
    zcl_tv025_odata_model=>define_model( io_model ).
  ENDMETHOD.


  METHOD zif_sadl_read_runtime~execute.
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

    fill_alv( EXPORTING iv_fill_total = xsdbool( line_exists( is_requested-elements[ table_line = |TOTAL_PRICE| ] ) )
              CHANGING  ct_alv        = ct_data_rows ).
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
