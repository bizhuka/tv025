CLASS zcl_tv025_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC

  GLOBAL FRIENDS zcl_eui_event_caller .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !iv_where TYPE string OPTIONAL .
    METHODS start_of_selection .

    METHODS get_xtt RETURNING VALUE(ro_xtt) TYPE REF TO zif_xtt.
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ts_alv,
        flight    TYPE icon_d,
        hotel     TYPE icon_d,
        transport TYPE icon_d.
        INCLUDE TYPE zcl_tv025_model=>ts_request_item.
      TYPES:
      END OF ts_alv .
    TYPES:
      tt_alv TYPE STANDARD TABLE OF ts_alv WITH DEFAULT KEY .

    DATA mv_where TYPE string .

    METHODS _show_alv
      IMPORTING
        !ir_table TYPE REF TO data .
    METHODS _on_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING
        !e_ucomm .
    METHODS _on_hotspot_click
        FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING
        !sender
        !e_row_id
        !e_column_id .
    METHODS _get_headers
      IMPORTING
        it_where          TYPE ddshselops
      RETURNING
        VALUE(rt_headers) TYPE REF TO data .
    METHODS _get_flights
      IMPORTING
        !iv_where         TYPE string OPTIONAL
      RETURNING
        VALUE(rt_flights) TYPE REF TO data .
    METHODS _get_hotels
      IMPORTING
        !iv_where        TYPE string OPTIONAL
      RETURNING
        VALUE(rt_hotels) TYPE REF TO data .
    METHODS _get_transports
      IMPORTING
        !iv_where            TYPE string OPTIONAL
      RETURNING
        VALUE(rt_transports) TYPE REF TO data .
    METHODS _new_copy
      IMPORTING
        !it_copy       TYPE ANY TABLE
      RETURNING
        VALUE(rr_copy) TYPE REF TO data .
    METHODS _set_zebra
      CHANGING
        !ct_table TYPE ANY TABLE .
ENDCLASS.



CLASS ZCL_TV025_REPORT IMPLEMENTATION.


  METHOD constructor.
    mv_where = iv_where.
    REPLACE ALL OCCURRENCES OF 'DATE_' IN mv_where WITH `t~DATE_`.
  ENDMETHOD.


  METHOD get_xtt.
    TYPES: BEGIN OF ts_root,
             f    TYPE REF TO data,
             h    TYPE REF TO data,
             t    TYPE REF TO data,
             date TYPE d,
             time TYPE t,
           END OF ts_root.

    ro_xtt = NEW zcl_xtt_excel_xlsx( NEW zcl_xtt_file_smw0( 'ZTV_025_REPORT.XLSX' )
                  )->merge( VALUE ts_root( f    = _get_flights( )
                                           h    = _get_hotels( )
                                           t    = _get_transports( )
                                           date = sy-datum
                                           time = sy-uzeit ) ).
  ENDMETHOD.


  METHOD start_of_selection.
    TYPES: BEGIN OF ts_popup,
             crdat    TYPE RANGE OF ftpt_req_head-zz_crdat,
             pernr    TYPE RANGE OF zss_tv025_tv_request_key-pernr,
             reinr    TYPE RANGE OF zss_tv025_tv_request_key-reinr,
             ename    TYPE RANGE OF p0001-ename,
             status   TYPE RANGE OF ftpt_req_head-zz_status,
             show_alv TYPE xsdboolean,
           END OF ts_popup.

    DATA(lr_popup) = NEW ts_popup( crdat = VALUE #( ( sign = 'I' option = 'GE' low = |{ sy-datum(4) }0101|  ) )
                                   show_alv      = 'X'  ).
    TRY.
        CHECK NEW zcl_eui_screen( ir_context = lr_popup
                                  iv_dynnr   = zcl_eui_screen=>mc_dynnr-dynamic
                                  iv_cprog   = |{ sy-cprog }_REPO|
                   )->customize( name = '*CRDAT*LOW*' required = '1'
                   )->customize( name = 'SHOW_ALV'    iv_label = |Show alv|
                   )->popup( iv_col_end = 85
                   )->show( ) = 'OK'.
      CATCH zcx_eui_exception INTO DATA(lo_error).
        MESSAGE lo_error TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

********************************************************************************************************************************************
********************************************************************************************************************************************
    DATA(lt_where) = VALUE ddshselops( FOR ls_crdat  IN lr_popup->crdat[]  ( CORRESPONDING #( BASE ( VALUE #( shlpfield = 'CRDAT'  ) ) ls_crdat ) ) ).
    APPEND  LINES OF VALUE ddshselops( FOR ls_pernr  IN lr_popup->pernr[]  ( CORRESPONDING #( BASE ( VALUE #( shlpfield = 'PERNR'  ) ) ls_pernr ) ) )  TO lt_where[].
    APPEND  LINES OF VALUE ddshselops( FOR ls_reinr  IN lr_popup->reinr[]  ( CORRESPONDING #( BASE ( VALUE #( shlpfield = 'REINR'  ) ) ls_reinr ) ) )  TO lt_where[].
    APPEND  LINES OF VALUE ddshselops( FOR ls_ename  IN lr_popup->ename[]  ( CORRESPONDING #( BASE ( VALUE #( shlpfield = 'ENAME'  ) ) ls_ename ) ) )  TO lt_where[].
    APPEND  LINES OF VALUE ddshselops( FOR ls_status IN lr_popup->status[] ( CORRESPONDING #( BASE ( VALUE #( shlpfield = 'STATUS' ) ) ls_status ) ) ) TO lt_where[].
    mv_where = zcl_tv025_model=>as_where( lt_where ).

    IF lr_popup->show_alv = abap_true.
      _show_alv( _get_headers( lt_where ) ).
      RETURN.
    ENDIF.
    get_xtt( )->download( ).
  ENDMETHOD.


  METHOD _get_flights.
    DATA(lv_where) = COND #( WHEN iv_where IS INITIAL
                             THEN mv_where
                             ELSE |{ iv_where } AND { mv_where }| ).

    SELECT r~s_index, r~type, r~agency, r~date_beg, r~date_end, r~airport_beg, r~airport_end, r~price, r~waers, r~penalty, r~penalty_waers,
           r~ticket, r~transport, r~cancelled,

           t~pernr, t~reinr, t~ename,
           t~zz_status AS status, s~ddtext AS status_text,
           activitytype~name AS activity_name,
           t~citizenship, CASE WHEN t~citizenship = 'KZ ' THEN ' ' ELSE 'X' END AS expat,
           appr_by~ddtext AS approved_by_text,
           a~agency_name,
           ' ' AS zebra
    FROM zdtv025_flight AS r
      RIGHT OUTER JOIN zvctv025_root AS t ON t~pernr = r~employee_number
                                         AND t~reinr = r~trip_number
      LEFT OUTER JOIN ta20r1 AS activitytype ON activitytype~acticity = t~activity_type AND activitytype~spras = @sy-langu
      LEFT OUTER JOIN dd07t AS s ON s~domvalue_l = t~zz_status AND s~domname = 'ZTV_022_STATUS' AND s~ddlanguage = @sy-langu AND s~as4local = 'A' AND s~as4vers = '0000'
      LEFT OUTER JOIN dd07t AS appr_by ON appr_by~domvalue_l = r~approved_by AND appr_by~domname = 'ZDD_TV022_APPROVED_BY' AND appr_by~ddlanguage = @sy-langu AND appr_by~as4local = 'A' AND appr_by~as4vers = '0000'
      LEFT OUTER JOIN zdtv025_agency AS a ON a~agency_id = r~agency "#EC CI_BUFFJOIN
    WHERE (lv_where)
    ORDER BY pernr, reinr
      INTO TABLE @DATA(lt_flights).

    _set_zebra( CHANGING ct_table = lt_flights ).

    rt_flights = _new_copy( lt_flights ).
  ENDMETHOD.


  METHOD _get_headers.
    DATA(lr_alv) = NEW tt_alv( CORRESPONDING #( zcl_tv025_model=>get_instance( )->get_request_items( it_where ) ) ).
    LOOP AT lr_alv->* ASSIGNING FIELD-SYMBOL(<ls_alv>).
      <ls_alv>-flight    = icon_flight.
      <ls_alv>-hotel     = icon_hotel.
      <ls_alv>-transport = icon_car.
    ENDLOOP.

    rt_headers = lr_alv.
  ENDMETHOD.


  METHOD _get_hotels.
    DATA(lv_where) = COND #( WHEN iv_where IS INITIAL
                             THEN mv_where
                             ELSE |{ iv_where } AND { mv_where }| ).

    SELECT r~s_index, r~early_check_in, r~later_check_out, r~date_beg, r~date_end, r~hotel_end, r~assigned_car, r~type_car,
           r~transport_price, r~transport_waers, r~transport_airport, r~transport_hotel, r~price, r~waers, r~penalty, r~penalty_waers, r~booked_nights, r~penalty_check,
           t~pernr, t~reinr, t~ename,
           t~zz_status AS status, s~ddtext AS status_text,
           activitytype~name AS activity_name,
           t~citizenship, CASE WHEN t~citizenship = 'KZ ' THEN ' ' ELSE 'X' END AS expat,
           typecar~ddtext AS type_cat_text,
           a~agency_name,
           b~hotel_basis, b~hotel_basis_txt,
           c~hotel_name, c~hotel_class, c~country_id, c~town_id,
           ' ' AS zebra
    FROM zdtv025_hotel AS r
      RIGHT OUTER JOIN zvctv025_root AS t ON t~pernr = r~employee_number
                                         AND t~reinr = r~trip_number
      LEFT OUTER JOIN ta20r1 AS activitytype ON activitytype~acticity = t~activity_type AND activitytype~spras = @sy-langu
      LEFT OUTER JOIN dd07t AS s ON s~domvalue_l = t~zz_status AND s~domname = 'ZTV_022_STATUS' AND s~ddlanguage = @sy-langu AND s~as4local = 'A' AND s~as4vers = '0000'
      LEFT OUTER JOIN dd07t AS typecar ON typecar~domvalue_l = r~type_car AND typecar~domname = 'ZTV_022_TYPE_CAR' AND typecar~ddlanguage = @sy-langu AND typecar~as4local = 'A' AND typecar~as4vers = '0000'
      LEFT OUTER JOIN zdtv025_agency AS a ON a~agency_id = r~agency "#EC CI_BUFFJOIN
      LEFT OUTER JOIN zdtv025_basis AS b ON b~basis_id = r~basis
      LEFT OUTER JOIN zdtv025_hotel_ca AS c ON c~hotel_id = r~hotel_end
    WHERE (lv_where)
    ORDER BY pernr, reinr
      INTO TABLE @DATA(lt_hotels).

    _set_zebra( CHANGING ct_table = lt_hotels ).

    rt_hotels = _new_copy( lt_hotels ).
  ENDMETHOD.


  METHOD _get_transports.
    DATA(lv_where) = COND #( WHEN iv_where IS INITIAL
                             THEN mv_where
                             ELSE |{ iv_where } AND { mv_where }| ).

    SELECT r~s_index, r~date_beg, r~time_beg, r~date_end, r~time_end, r~check_point, r~arrival, r~not_required, r~vip,
           ch~kurztext AS ch_text,
           ar~kurztext AS ar_text,

           t~pernr, t~reinr, t~ename,
           t~zz_status AS status, s~ddtext AS status_text,
           activitytype~name AS activity_name,
           t~citizenship, CASE WHEN t~citizenship = 'KZ ' THEN ' ' ELSE 'X' END AS expat,
           ' ' AS zebra
    FROM zdtv025_transp AS r
      RIGHT OUTER JOIN zvctv025_root AS t ON t~pernr = r~employee_number
                                         AND t~reinr = r~trip_number
      LEFT OUTER JOIN ta20r1 AS activitytype ON activitytype~acticity = t~activity_type AND activitytype~spras = @sy-langu
      LEFT OUTER JOIN dd07t AS s ON s~domvalue_l = t~zz_status AND s~domname = 'ZTV_022_STATUS' AND s~ddlanguage = @sy-langu AND s~as4local = 'A' AND s~as4vers = '0000'
      LEFT OUTER JOIN zdtv025_checkp AS ch ON r~check_point = ch~id
      LEFT OUTER JOIN zdtv025_checkp AS ar ON r~arrival = ch~id
    WHERE (lv_where)
    ORDER BY pernr, reinr
      INTO TABLE @DATA(lt_transps)                     "#EC CI_BUFFJOIN
   .

    _set_zebra( CHANGING ct_table = lt_transps ).

    rt_transports = _new_copy( lt_transps ).
  ENDMETHOD.


  METHOD _new_copy.
    FIELD-SYMBOLS <it_copy> TYPE STANDARD TABLE.
    CREATE DATA rr_copy LIKE it_copy.
    ASSIGN rr_copy->* TO <it_copy>.

    " Copy whole table
    <it_copy>[] = it_copy.
  ENDMETHOD.


  METHOD _on_hotspot_click.
    DATA(lr_alv) = CAST tt_alv( zcl_eui_conv=>get_grid_table( sender ) ).
    ASSIGN lr_alv->*[ e_row_id-index ] TO FIELD-SYMBOL(<ls_alv>).
    CHECK sy-subrc = 0.

    DATA(lv_where) = zcl_tv025_model=>get_instance( )->as_where(
      VALUE #( sign = 'I' option = 'EQ' ( shlpfield = 'r~EMPLOYEE_NUMBER' low = <ls_alv>-pernr )
                                        ( shlpfield = 'r~TRIP_NUMBER'     low = <ls_alv>-reinr ) ) ).

    DATA(lr_table) = SWITCH #( e_column_id-fieldname WHEN 'FLIGHT'    THEN _get_flights( lv_where )
                                                     WHEN 'HOTEL'     THEN _get_hotels( lv_where )
                                                     WHEN 'TRANSPORT' THEN _get_transports( lv_where ) ).

    DATA(lt_catalog) =  COND #( WHEN  zcl_tv025_opt=>is_super( sy-uname )
                                THEN VALUE lvc_t_fcat( FOR <ls_catalog> IN zcl_eui_type=>get_catalog( ir_table = lr_table )
                                                       ( fieldname = <ls_catalog>-fieldname
                                                         coltext   = <ls_catalog>-fieldname ) ) ).
    APPEND VALUE #( fieldname = |ZEBRA| tech = 'X' ) TO lt_catalog.

    NEW zcl_eui_alv( ir_table       = lr_table
                     it_mod_catalog = lt_catalog
                     is_layout      = VALUE #( grid_title = COND #( WHEN zcl_tv025_opt=>is_super( sy-uname )
                                                                    THEN |Use tech names for Excel template| ) )
    )->popup(
    )->show( ).
  ENDMETHOD.


  METHOD _on_user_command.
    CASE e_ucomm.
      WHEN 'DOWNLOAD'.
        get_xtt( )->download( ).
    ENDCASE.
  ENDMETHOD.


  METHOD _set_zebra.
    TYPES: BEGIN OF ts_item,
             pernr TYPE pernr-pernr,
             zebra TYPE abap_bool,
           END OF ts_item.

    " Zebra in excel
    DATA(lv_count) = 0.
    DATA(lv_prev_pernr) = CONV pernr-pernr( 0 ).
    LOOP AT ct_table ASSIGNING FIELD-SYMBOL(<ls_line>).
      DATA(ls_item) = CORRESPONDING ts_item( <ls_line> ).
      IF lv_prev_pernr <> ls_item-pernr.
        lv_count = lv_count + 1.
      ENDIF.
      lv_prev_pernr = ls_item-pernr.

      ls_item-zebra = xsdbool( lv_count MOD 2 = 1 ).
      MOVE-CORRESPONDING ls_item TO <ls_line>.
    ENDLOOP.
  ENDMETHOD.


  METHOD _show_alv.
    NEW zcl_eui_alv( ir_table       = ir_table
                     it_mod_catalog = VALUE #(
                     ( fieldname = '+' hotspot = 'X' fix_column = 'X' coltext = '____' )
                     ( fieldname = '+FLIGHT'     )
                     ( fieldname = '+HOTEL'      )
                     ( fieldname = '+TRANSPORT'  )
*                     ( fieldname = '' coltext = || )
                     )
                     it_toolbar = VALUE #( ( function = 'DOWNLOAD' icon = icon_xls text = |Report| ) )
    )->show( me ).
  ENDMETHOD.
ENDCLASS.
