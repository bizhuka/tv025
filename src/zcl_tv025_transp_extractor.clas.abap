class zcl_tv025_transp_extractor definition
  public
  create public .

  public section.

    types:
      begin of ts_selcrit,
        begda type begda,
        endda type endda,
      end of ts_selcrit .

    methods constructor
      importing
        !is_sel_crit type ts_selcrit .
    methods get_data
      returning
        value(rt_result) type ztt_tv025_travel_extract_erp .
    methods date_to_iso
      importing
        !i_date         type begda
      returning
        value(r_result) type string .
    methods time_to_iso
      importing
        !i_time         type tims
        !i_seconds      type abap_bool default abap_false
        !i_milli        type abap_bool default abap_false
      returning
        value(r_result) type string .
  protected section.
    data: ms_selcrit type ts_selcrit.
  private section.
ENDCLASS.



CLASS ZCL_TV025_TRANSP_EXTRACTOR IMPLEMENTATION.


  method constructor.
    super->constructor( ).
    ms_selcrit = is_sel_crit.
  endmethod.


  method date_to_iso.
    r_result = |{ i_date+0(4) }-{ i_date+4(2) }-{ i_date+6(2) }|.
  endmethod.


  method get_data.
    select transp~employee_number as empl_id,
           transp~trip_number as transportid,
           transp~date_beg as tr_date,
           transp~time_beg,
           transp~date_end,
           transp~time_end,
           check_point as checkpointid,
*    country,
*    transp~town as transp_town,
    arrival as arrivalid,
    transp~comment1 as comments,
*    arrival~airport_name as arrival,
    vip as vip,
    chpoint~kurztext as check_point,
    transp~not_required as trlsnotrequiered,

    flight~date_beg as flight_dep_date,
    flight~time_beg as flight_dep_time

    from zdtv025_transp as transp
        " Checkpoint
        left join zdtv025_checkp as chpoint on
            transp~check_point = chpoint~tradm_id
        " Arrival
*        left join zdtv025_airport as arrival on
*          transp~arrival = arrival~airport_id
        " Flight Data
        left join zdtv025_flight as flight on
            transp~trip_number = flight~trip_number and
            transp~employee_number = flight~employee_number and
            transp~s_index = flight~s_index
        into table @data(lt_data)
        where transp~date_beg >= @ms_selcrit-begda and
              transp~date_beg <= @ms_selcrit-endda.

    loop at lt_data assigning field-symbol(<ls_data>).
      append corresponding #( <ls_data> ) to rt_result assigning field-symbol(<ls_result>).

      <ls_result>-direction = |{ time_to_iso( <ls_data>-time_beg ) }/| &&
      |{ time_to_iso( <ls_data>-flight_dep_time ) }| &&
*      | - { <ls_data>-check_point } - { <ls_data>-arrival }|.
      | - { <ls_data>-check_point }|.

      try.
          <ls_result>-travelerfullname = zcl_hcm_wf=>get_fio_for_pernr( iv_pernr = <ls_data>-empl_id ).
        catch zcx_sy.
      endtry.

      <ls_result>-departure_date_time = |{ date_to_iso( <ls_data>-tr_date ) }| &&
      | { time_to_iso( i_time = <ls_data>-time_beg i_seconds = abap_true i_milli = abap_true ) }|.

      <ls_result>-plane_date_time = |{ date_to_iso( <ls_data>-flight_dep_date ) }| &&
      | { time_to_iso( i_time = <ls_data>-flight_dep_time i_seconds = abap_true i_milli = abap_true ) }|.

    endloop.
  endmethod.


  method time_to_iso.
    r_result = |{ i_time+0(2) }:{ i_time+2(2) }|.
    if i_seconds = abap_true.
      r_result = r_result && |:{ i_time+4(2) }|.
    endif.

    if i_milli = abap_true.
      r_result = r_result && `.000`.
    endif.
  endmethod.
ENDCLASS.
