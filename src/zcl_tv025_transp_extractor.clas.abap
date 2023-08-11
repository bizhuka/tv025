CLASS zcl_tv025_transp_extractor DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_selcrit,
        begda TYPE begda,
        endda TYPE endda,
      END OF ts_selcrit .

    METHODS constructor
      IMPORTING
        !is_sel_crit TYPE ts_selcrit .
    METHODS get_data
      RETURNING
        VALUE(rt_result) TYPE ztt_tv025_travel_extract_erp .
    METHODS date_to_iso
      IMPORTING
        !i_date         TYPE begda
      RETURNING
        VALUE(r_result) TYPE string .
    METHODS time_to_iso
      IMPORTING
        !i_time         TYPE tims
        !i_seconds      TYPE abap_bool DEFAULT abap_false
        !i_milli        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(r_result) TYPE string .
  PROTECTED SECTION.
    DATA: ms_selcrit TYPE ts_selcrit.

  PRIVATE SECTION.
    METHODS to_number
      IMPORTING iv_string        TYPE string
      RETURNING VALUE(rv_number) TYPE i.
ENDCLASS.



CLASS ZCL_TV025_TRANSP_EXTRACTOR IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    ms_selcrit = is_sel_crit.
  ENDMETHOD.


  METHOD date_to_iso.
    r_result = |{ i_date+0(4) }-{ i_date+4(2) }-{ i_date+6(2) }|.
  ENDMETHOD.


  METHOD get_data.
    SELECT  main~employee_number   AS empl_id,
            main~trip_number,
            main~s_index,
            main~date_beg          AS tr_date,
            main~time_beg          AS tr_time,
            main~date_end,
            main~time_end,
            check_point            AS checkpointid,
*            main~country,
*            main~town             AS main_town,
            main~arrival           AS arrivalid,
            main~comment1          AS comments,
            main~not_required      AS trlsnotrequiered,
            main~vip               AS vip,

            arrival~kurztext       AS arrival,
            chpoint~kurztext       AS check_point,

            flight~date_beg        AS flight_dep_date,
            flight~time_beg        AS flight_dep_time

    FROM zdtv025_transp AS main
        INNER JOIN ftpt_req_head AS head ON head~pernr        = main~employee_number
                                        AND head~reinr        = main~trip_number
                                        AND head~requestvrs   = 99
                                        AND head~plan_request = 'R'
                                        AND head~zz_status    = 'A' " Approved

        " Checkpoint
        LEFT JOIN zdtv025_checkp AS chpoint ON
            main~check_point = chpoint~id
        " Arrival
        LEFT JOIN zdtv025_checkp AS arrival ON
            main~arrival = arrival~id
        " Flight Data
        LEFT JOIN zdtv025_flight AS flight ON
            main~trip_number = flight~trip_number AND
            main~employee_number = flight~employee_number AND
            main~s_index = flight~s_index
        INTO TABLE @DATA(lt_data)
        WHERE main~date_beg >= @ms_selcrit-begda AND
              main~date_beg <= @ms_selcrit-endda.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
      APPEND CORRESPONDING #( <ls_data> ) TO rt_result ASSIGNING FIELD-SYMBOL(<ls_result>).

      <ls_result>-transportid   = |{ <ls_data>-trip_number }{ <ls_data>-s_index  }|.
      <ls_result>-trrrequesstid = <ls_result>-transportid.

      <ls_result>-direction = |{ time_to_iso( <ls_data>-tr_time ) }/| &&
      |{ time_to_iso( <ls_data>-flight_dep_time ) }| &&
*      | - { <ls_data>-check_point } - { <ls_data>-arrival }|.
      | - { <ls_data>-check_point }|.

      TRY.
          <ls_result>-travelerfullname = zcl_hcm_wf=>get_fio_for_pernr( iv_pernr = <ls_data>-empl_id ).
        CATCH zcx_sy.
      ENDTRY.

      <ls_result>-departure_date_time = |{ date_to_iso( <ls_data>-tr_date ) }| &&
      | { time_to_iso( i_time = <ls_data>-tr_time i_seconds = abap_true i_milli = abap_true ) }|.

      <ls_result>-plane_date_time = |{ date_to_iso( <ls_data>-flight_dep_date ) }| &&
      | { time_to_iso( i_time = <ls_data>-flight_dep_time i_seconds = abap_true i_milli = abap_true ) }|.

      <ls_result>-checkpointid  = to_number( <ls_result>-checkpointid ).
      <ls_result>-arrivalid     = to_number( <ls_result>-arrivalid ).

      <ls_result>-tr_date       = |{ <ls_data>-tr_date COUNTRY = 'US ' }|.
      <ls_result>-tr_time       = |{ time_to_iso( <ls_data>-tr_time ) }|.

      <ls_result>-dateofupdatet = |{ date_to_iso( sy-datum ) }| &&
                                  | { time_to_iso( i_time = sy-uzeit i_seconds = abap_true i_milli = abap_true ) }|.
    ENDLOOP.
  ENDMETHOD.


  METHOD time_to_iso.
    r_result = |{ i_time+0(2) }:{ i_time+2(2) }|.
    IF i_seconds = abap_true.
      r_result = r_result && |:{ i_time+4(2) }|.
    ENDIF.

    IF i_milli = abap_true.
      r_result = r_result && `.000`.
    ENDIF.
  ENDMETHOD.


  METHOD to_number.
    DATA(lv_number) = iv_string.
    REPLACE ALL OCCURRENCES OF REGEX '[^(0-9.,)]' IN lv_number WITH ''.
    rv_number = lv_number.
  ENDMETHOD.
ENDCLASS.
