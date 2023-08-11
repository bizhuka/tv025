CLASS zcl_tv025_model DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_request_item.
        INCLUDE TYPE zss_tv025_head AS _head.
      TYPES:
      END OF ts_request_item .
    TYPES:
      tt_request_item TYPE STANDARD TABLE OF ts_request_item WITH DEFAULT KEY .
    TYPES:
      BEGIN OF ts_country,
        land1 TYPE land1,
        landx TYPE landx,
      END OF ts_country .
    TYPES:
      tt_country TYPE HASHED TABLE OF ts_country WITH UNIQUE KEY land1 .
    TYPES:
      BEGIN OF ts_domain_text,
        key  TYPE dd07v-domvalue_l,
        text TYPE dd07v-ddtext,
      END OF ts_domain_text .
    TYPES:
      tt_domain_text TYPE SORTED TABLE OF ts_domain_text    WITH UNIQUE KEY key .
    TYPES:
      tt_flights     TYPE STANDARD TABLE OF zdtv025_flight  WITH DEFAULT KEY .
    TYPES:
      tt_hotels      TYPE STANDARD TABLE OF zdtv025_hotel   WITH DEFAULT KEY .
    TYPES:
      tt_transps     TYPE STANDARD TABLE OF zdtv025_transp  WITH DEFAULT KEY .
    TYPES ts_db_key TYPE zss_tv025_tv_request_key .
    TYPES:
      BEGIN OF ts_full_key,
        employee_number TYPE pernr_d,
        trip_number     TYPE reinr,
        requestvrs      TYPE request_version,
        plan_request    TYPE plan_request,
      END OF ts_full_key .
    TYPES:
      BEGIN OF ts_command.
        INCLUDE TYPE ts_db_key AS db_key.
      TYPES:
        ucomm TYPE syucomm,
      END OF ts_command .
    TYPES:
      BEGIN OF ts_db_item,
        s_head   TYPE zss_tv025_head,
        t_flight TYPE tt_flights,
        t_transp TYPE tt_transps,
        t_hotel  TYPE tt_hotels,

        visitor  TYPE zdtv025_visitor,
        vis_req  TYPE zss_tv025_visitor_req_fields, "zdtv025_vis_req,
      END OF ts_db_item .
    TYPES:
      BEGIN OF ts_cache.
        INCLUDE TYPE zss_tv_travel_request_key AS _key.
        INCLUDE TYPE ts_db_item                AS _val.
      TYPES:
        hash TYPE char16,
      END OF ts_cache .

    CONSTANTS:
      BEGIN OF mc_status,
        open     TYPE zss_tv025_head-zz_status VALUE 'O',
        approved TYPE zss_tv025_head-zz_status VALUE 'A',
        canceled TYPE zss_tv025_head-zz_status VALUE 'C',
      END OF mc_status .
    DATA ms_cache TYPE ts_cache .

    CLASS-METHODS get_instance
      RETURNING
        VALUE(ro_model) TYPE REF TO zcl_tv025_model .
    METHODS get_by_key
      IMPORTING
        !is_db_key  TYPE ts_db_key
      CHANGING
        !cs_db_item TYPE any .
    METHODS get_request_items
      IMPORTING
        !it_select        TYPE ddshselops
        !iv_count         TYPE any OPTIONAL
        !iv_order_by      TYPE string OPTIONAL
      RETURNING
        VALUE(rt_travels) TYPE tt_request_item .
    METHODS get_header
      IMPORTING
        !is_db_key     TYPE ts_db_key
      RETURNING
        VALUE(rs_head) TYPE zss_tv025_head .
    METHODS fill_cache
      IMPORTING
        !is_key         TYPE ts_db_key
      RETURNING
        VALUE(rr_cache) TYPE REF TO ts_cache .
    METHODS calc_db_hash
      IMPORTING
        !is_db_item    TYPE ts_db_item
      RETURNING
        VALUE(rv_hash) TYPE char16 .
    METHODS lock
      IMPORTING
        iv_pernr     TYPE pernr_d OPTIONAL
        iv_reinr     TYPE reinr OPTIONAL
        iv_unlock    TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(rv_ok) TYPE abap_bool .
    METHODS is_changed
      RETURNING
        VALUE(rv_changed) TYPE abap_bool .
    METHODS save .
    METHODS delete
      IMPORTING
        !is_key TYPE zss_tv_travel_request_key .
    METHODS get_domain_texts
      IMPORTING
        !iv_domian     TYPE dd07l-domname
      RETURNING
        VALUE(rt_text) TYPE tt_domain_text .
    METHODS get_user_ename
      IMPORTING
        !iv_uname      TYPE syuname
      RETURNING
        VALUE(rv_text) TYPE string .
    METHODS set_table_s_indices .
    METHODS exchange_command
      IMPORTING
        !is_command TYPE ts_command OPTIONAL
      EXPORTING
        !es_command TYPE ts_command .
    METHODS read_db
      IMPORTING
        !is_key           TYPE ts_db_key
      RETURNING
        VALUE(rs_db_item) TYPE ts_db_item .
    METHODS is_visitor
      IMPORTING
        !iv_pernr         TYPE pernr-pernr OPTIONAL
      RETURNING
        VALUE(rv_visitor) TYPE abap_bool .
    CLASS-METHODS as_where
      IMPORTING
        !it_select      TYPE ddshselops
      RETURNING
        VALUE(rv_where) TYPE string .
    METHODS get_country_text IMPORTING iv_land1       TYPE t005t-land1
                             RETURNING VALUE(rv_text) TYPE t005t-landx.
    METHODS get_status_text IMPORTING iv_key         TYPE csequence
                            RETURNING VALUE(rv_text) TYPE ts_domain_text-text.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA _instance TYPE REF TO zcl_tv025_model .
    DATA _mt_status_name TYPE tt_domain_text.
    DATA _mt_country TYPE tt_country.

    METHODS _set_index
      IMPORTING
        !is_key   TYPE zss_tv_travel_request_key
      CHANGING
        !ct_table TYPE ANY TABLE .
    METHODS _read_current_root EXPORTING er_root    TYPE REF TO zsitv025_root
                                         eo_manager TYPE REF TO /bobf/if_tra_service_manager
                                         eo_message TYPE REF TO /bobf/if_frw_message.
ENDCLASS.



CLASS ZCL_TV025_MODEL IMPLEMENTATION.


  METHOD as_where.
    DATA(lt_select) = it_select[].
    CALL FUNCTION 'F4_CONV_SELOPT_TO_WHERECLAUSE'
      EXPORTING
        escape_allowed = 'X'
      IMPORTING
        where_clause   = rv_where
      TABLES
        selopt_tab     = lt_select.
  ENDMETHOD.


  METHOD calc_db_hash.
    rv_hash = NEW zcl_eui_crc64(
              )->add_to_hash( is_db_item
              )->get_hash( ).
  ENDMETHOD.


  METHOD delete.
    DELETE FROM:
               zdtv025_flight WHERE employee_number = is_key-employee_number
                                AND trip_number     = is_key-trip_number,

               zdtv025_hotel  WHERE employee_number = is_key-employee_number
                                AND trip_number     = is_key-trip_number,

               zdtv025_transp WHERE employee_number = is_key-employee_number
                                AND trip_number     = is_key-trip_number.
    COMMIT WORK AND WAIT.
  ENDMETHOD.


  METHOD exchange_command.
    CLEAR es_command.

    IF is_command IS SUPPLIED.
      SET PARAMETER ID: 'ZTV025_PERNR'   FIELD is_command-pernr,
                        'ZTV025_REINR'   FIELD is_command-reinr,
                        'ZTV025_COMMAND' FIELD is_command-ucomm.
      IF is_command-ucomm IS NOT INITIAL.
        " send PAI command
        CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
          EXPORTING
            functioncode = is_command-ucomm
          EXCEPTIONS
            OTHERS       = 0.
      ENDIF.

      RETURN.
    ENDIF.

    CHECK es_command IS REQUESTED.
    GET PARAMETER ID: 'ZTV025_PERNR'   FIELD es_command-pernr,
                      'ZTV025_REINR'   FIELD es_command-reinr,
                      'ZTV025_COMMAND' FIELD es_command-ucomm.
    " Send empty command
    exchange_command( is_command = VALUE #( ) ).
  ENDMETHOD.


  METHOD fill_cache.
    " 1 item is enogh for now
    ms_cache-_key = is_key.
    ms_cache-_val = read_db( is_key ).
    ms_cache-hash = calc_db_hash( ms_cache-_val ).

    " New item?
    CHECK ms_cache-s_head-zz_status IS INITIAL AND ms_cache-s_head-crname IS INITIAL.
    ms_cache-hash = '~~~'.
  ENDMETHOD.


  METHOD get_by_key.
    CLEAR cs_db_item.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF cs_db_item
    FROM ftpt_req_head
    WHERE pernr = is_db_key-pernr
      AND reinr = is_db_key-reinr.
  ENDMETHOD.


  METHOD get_country_text.
    IF _mt_country[] IS INITIAL.
      SELECT land1 landx INTO TABLE _mt_country
      FROM t005t
      WHERE spras EQ sy-langu.
    ENDIF.

    ASSIGN _mt_country[ land1 = iv_land1 ] TO FIELD-SYMBOL(<ls_country>).
    CHECK sy-subrc = 0.
    rv_text = <ls_country>-landx.
  ENDMETHOD.


  METHOD get_domain_texts.
    DATA lt_table TYPE STANDARD TABLE OF dd07v WITH DEFAULT KEY.
    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname       = iv_domian
        text          = abap_true
        bypass_buffer = abap_true
      TABLES
        dd07v_tab     = lt_table
      EXCEPTIONS
        OTHERS        = 0.

    SORT lt_table BY domvalue_l.
    rt_text = VALUE #( FOR <ls_line> IN lt_table
                      ( key  = <ls_line>-domvalue_l
                        text = <ls_line>-ddtext ) ).
  ENDMETHOD.


  METHOD get_header.
    DATA(lt_items) = get_request_items(
       it_select = VALUE #( sign = 'I' option = 'EQ' ( shlpfield = 'PERNR' low = is_db_key-pernr )
                                                     ( shlpfield = 'REINR' low = is_db_key-reinr ) )
       " iv_head_optional = abap_true
       " iv_count         = 1  Always should 1
    ).

    IF lt_items[] IS INITIAL AND is_visitor( is_db_key-pernr ).
      rs_head = CORRESPONDING #( is_db_key ).
      RETURN.
    ENDIF.

    ASSERT lines( lt_items ) = 1.
    rs_head = lt_items[ 1 ].

    " Creating ? Other fields filled during saving
    rs_head-zz_status = COND #( WHEN rs_head-zz_status IS INITIAL AND rs_head-crname IS INITIAL
                                THEN mc_status-open
                                ELSE rs_head-zz_status ).
  ENDMETHOD.


  METHOD get_instance.
    IF _instance IS INITIAL.
      _instance = NEW #( ).
    ENDIF.

    ro_model = _instance.

*  types:
*    BEGIN OF ts_mwskz,
*        spkzl TYPE spkzl,
*        mwskz TYPE mwskz,
*      END OF ts_mwskz .
*  types:
*    tt_mwskz TYPE HASHED TABLE OF ts_mwskz WITH UNIQUE KEY spkzl .
*      SELECT spkzl mwskz INTO TABLE _instance->mt_mwskz
*      FROM t706b1
*      WHERE morei EQ 'KZ'
*        AND endda GE sy-datum.
  ENDMETHOD.


  METHOD get_request_items.
    DATA(lv_where)  = as_where( it_select ).

    SELECT *
    FROM zc_tv025_root
    WHERE (lv_where)
    ORDER BY (iv_order_by)
      INTO CORRESPONDING FIELDS OF TABLE @rt_travels UP TO @iv_count ROWS.

    " Based on ZDTV025_HEAD fields
    LOOP AT rt_travels ASSIGNING FIELD-SYMBOL(<ls_travels>).
      <ls_travels>-status_name = get_status_text( <ls_travels>-zz_status ).
      <ls_travels>-crname      = get_user_ename( <ls_travels>-crunm ).
      <ls_travels>-chname      = get_user_ename( <ls_travels>-chunm ).
    ENDLOOP.

    SORT rt_travels BY pernr reinr.
  ENDMETHOD.


  METHOD get_status_text.
    IF _mt_status_name[] IS NOT INITIAL.
      _mt_status_name = _instance->get_domain_texts( 'ZTV_022_STATUS' ).
    ENDIF.

    ASSIGN _mt_status_name[ key = iv_key ] TO FIELD-SYMBOL(<ls_status>).
    CHECK sy-subrc = 0.
    rv_text = <ls_status>-text.
  ENDMETHOD.


  METHOD get_user_ename.
    CHECK iv_uname IS NOT INITIAL.
    SELECT SINGLE name_textc INTO rv_text
    FROM user_addr
    WHERE bname = iv_uname " ##WARN_OK  backward compatibility
    .
  ENDMETHOD.


  METHOD is_changed.
    CHECK ms_cache-hash IS NOT INITIAL.
    rv_changed = xsdbool( ms_cache-hash <> calc_db_hash( ms_cache-_val ) ).
  ENDMETHOD.


  METHOD is_visitor.
    DATA(lv_pernr) = COND #( WHEN iv_pernr IS NOT INITIAL
                             THEN iv_pernr
                             ELSE ms_cache-s_head-pernr ).
    rv_visitor = xsdbool( lv_pernr CP '9*' ).
  ENDMETHOD.


  METHOD lock.
    DATA(l_pernr) = COND #( WHEN iv_pernr IS NOT INITIAL THEN iv_pernr ELSE ms_cache-_key-employee_number ).
    DATA(l_reinr) = COND #( WHEN iv_reinr IS NOT INITIAL THEN iv_reinr ELSE ms_cache-_key-trip_number ).

    IF l_pernr IS INITIAL OR l_reinr IS INITIAL.
      zcx_eui_no_check=>raise_sys_error( iv_message = |Cannot lock item with empty key!| ).
    ENDIF.

    " Locks
    IF iv_unlock = abap_true.
      CALL FUNCTION 'DEQUEUE_EPTRV' " 'DEQUEUE_EZDTV025_ROOT'
        EXPORTING
          pernr  = l_pernr
          reinr  = l_reinr
        EXCEPTIONS
          OTHERS = 3.
    ELSE.
      CALL FUNCTION 'ENQUEUE_EPTRV' "'ENQUEUE_EZDTV025_ROOT'
        EXPORTING
          "mode_ftpt_req_head = 'X'
          pernr  = l_pernr
          reinr  = l_reinr
        EXCEPTIONS
          OTHERS = 3.
    ENDIF.

    " Show message in caller
    CHECK sy-subrc = 0.

    " Ok locked
    rv_ok = abap_true.
  ENDMETHOD.


  METHOD read_db.
    rs_db_item-s_head = get_header( is_key ).
    SELECT *  INTO TABLE @rs_db_item-t_flight
    FROM zdtv025_flight
    WHERE employee_number = @is_key-pernr
      AND trip_number     = @is_key-reinr.

    SELECT *  INTO TABLE @rs_db_item-t_hotel
    FROM zdtv025_hotel
    WHERE employee_number = @is_key-pernr
      AND trip_number     = @is_key-reinr.

    SELECT *  INTO TABLE @rs_db_item-t_transp
    FROM zdtv025_transp
    WHERE employee_number = @is_key-pernr
      AND trip_number     = @is_key-reinr.
  ENDMETHOD.


  METHOD save.
    "MODIFY ZDTV025_VIS_REQ and ZDTV025_HEAD
    _read_current_root( IMPORTING er_root    = DATA(lr_root)
                                  eo_manager = DATA(lo_manager)
                                  eo_message = DATA(lo_message) ).
    DATA(lv_change_mode) = /bobf/if_frw_c=>sc_modify_update.
    IF lr_root->key IS INITIAL.
      lv_change_mode = /bobf/if_frw_c=>sc_modify_create.
      lr_root->key   = /bobf/cl_frw_factory=>get_new_key( ).
    ENDIF.

    " Always update fields ZSS_TV025_ROOT_UPDATE_FIELDS
    DATA(lt_field) = VALUE /bobf/t_frw_name( FOR ls_comp IN CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data_ref( NEW zss_tv025_root_update_fields( ) ) )->components[]
                                            ( |{ ls_comp-name }| ) ).
    IF is_visitor( ) = abap_true.
      " Add fields of ZSS_TV025_VISITOR_REQ_FIELDS
      LOOP AT CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data_ref( NEW zss_tv025_visitor_req_fields( ) ) )->components[] ASSIGNING FIELD-SYMBOL(<ls_comp>).
        APPEND <ls_comp>-name TO lt_field.
      ENDLOOP.
    ENDIF.

    lo_manager->modify(
        EXPORTING it_modification =
          VALUE #( ( node           = zif_i_tv025_root_c=>sc_node-zi_tv025_root
                        change_mode	   = lv_change_mode
                        key	           = lr_root->key
                        root_key       = lr_root->key
                        data           = lr_root
                        changed_fields = lt_field
                     ) )
        IMPORTING eo_message    = lo_message ).

    DATA(lo_transaction) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
    lo_transaction->save(
        IMPORTING ev_rejected = DATA(lv_rejected)
                  eo_message  = lo_message ).


**********************************************************************
**********************************************************************
    delete( ms_cache-_key ).
    set_table_s_indices( ).

    MODIFY: zdtv025_flight FROM TABLE ms_cache-t_flight,
            zdtv025_hotel  FROM TABLE ms_cache-t_hotel,
            zdtv025_transp FROM TABLE ms_cache-t_transp.

    IF is_visitor( ) = abap_true.
      DATA(ls_visitor) = CORRESPONDING zdtv025_visitor( ms_cache-s_head ).
      MODIFY zdtv025_visitor FROM ls_visitor.
    ENDIF.
    COMMIT WORK AND WAIT.

    ms_cache-hash = calc_db_hash( ms_cache-_val ).
    MESSAGE 'Changes saved' TYPE 'S'.
  ENDMETHOD.


  METHOD set_table_s_indices.
    _set_index( EXPORTING is_key = ms_cache-_key CHANGING ct_table = ms_cache-t_flight ).
    _set_index( EXPORTING is_key = ms_cache-_key CHANGING ct_table = ms_cache-t_hotel ).
    _set_index( EXPORTING is_key = ms_cache-_key CHANGING ct_table = ms_cache-t_transp ).
  ENDMETHOD.


  METHOD _read_current_root.
    eo_manager = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( zif_i_tv025_root_c=>sc_bo_key ).
    eo_message = /bobf/cl_frw_factory=>get_message( ).

    DATA(lt_root_key) = VALUE /bobf/t_frw_key( ).
    eo_manager->convert_altern_key( EXPORTING iv_node_key	  = zif_i_tv025_root_c=>sc_node-zi_tv025_root
                                              iv_altkey_key = zif_i_tv025_root_c=>sc_alternative_key-zi_tv025_root-db_key
                                              it_key        = VALUE ztk_itv025_root_db_key( (
                                                                  pernr        = ms_cache-s_head-pernr
                                                                  reinr        = ms_cache-s_head-reinr
                                                                  plan_request = ms_cache-s_head-plan_request
                                                                  requestvrs   = ms_cache-s_head-requestvrs ) )
                                    IMPORTING et_key        = lt_root_key
                                              eo_message    = eo_message ).
    IF lt_root_key[] IS INITIAL.
      er_root = NEW #( ).
    ELSE.
      DATA(lt_root) = NEW ztitv025_root( ).
      eo_manager->retrieve(
        EXPORTING iv_node_key   = zif_i_tv025_root_c=>sc_node-zi_tv025_root
                  it_key        = lt_root_key
                  iv_fill_data  = abap_true
        IMPORTING et_data       = lt_root->*
                  eo_message    = eo_message ).
      er_root = REF #( lt_root->*[ 1 ] ).
    ENDIF.
    MOVE-CORRESPONDING ms_cache-s_head TO er_root->*.

    " Copy previous from changed
    IF er_root->zz_crdat IS INITIAL.
      er_root->zz_crdat = er_root->dates.
    ENDIF.
    IF er_root->zz_crtime IS INITIAL.
      er_root->zz_crtime = er_root->times.
    ENDIF.
    " Changed
    er_root->uname     = sy-uname.
    er_root->dates     = sy-datum.
    er_root->times     = sy-uzeit.
    " Created
    er_root->createdby = COND #( WHEN er_root->createdby IS NOT INITIAL THEN er_root->createdby ELSE sy-uname ).
    er_root->zz_crdat  = COND #( WHEN er_root->zz_crdat  IS NOT INITIAL THEN er_root->zz_crdat  ELSE sy-datum ).
    er_root->zz_crtime = COND #( WHEN er_root->zz_crtime IS NOT INITIAL THEN er_root->zz_crtime ELSE sy-uzeit ).
    " Status
    er_root->zz_status = COND #( WHEN er_root->zz_status IS NOT INITIAL THEN er_root->zz_status ELSE mc_status-open ).
  ENDMETHOD.


  METHOD _set_index.
    TYPES: BEGIN OF ts_key_fields,
             employee_number TYPE pernr_d,
             trip_number     TYPE reinr,
             requestvrs      TYPE request_version,
             plan_request    TYPE plan_request,
             s_index         TYPE index,
           END OF ts_key_fields.

    LOOP AT ct_table ASSIGNING FIELD-SYMBOL(<ls_item>).
      MOVE-CORRESPONDING VALUE ts_key_fields(
              employee_number = ms_cache-s_head-pernr
              trip_number     = ms_cache-s_head-reinr
              requestvrs      = ms_cache-s_head-requestvrs
              plan_request    = ms_cache-s_head-plan_request
              s_index	        = sy-tabix
      ) TO <ls_item>.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
