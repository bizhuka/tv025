CLASS zcl_i_root_child_check DEFINITION
  PUBLIC
  INHERITING FROM /bobf/cl_lib_v_supercl_simple
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_sadl_exit .
    INTERFACES zif_sadl_prepare_batch .

    METHODS /bobf/if_frw_validation~execute
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ts_ind_key,
             employee_number TYPE pernr_d,
             trip_number     TYPE reinr,
             s_index         TYPE index,
           END OF ts_ind_key,
           tt_ind_key TYPE STANDARD TABLE OF ts_ind_key WITH DEFAULT KEY.
    DATA ms_ind_key TYPE ts_ind_key.

    METHODS:
      _check_flight IMPORTING is_flight     TYPE zsitv025_flight
                              io_message    TYPE REF TO /bobf/if_frw_message
                    CHANGING  ct_failed_key TYPE /bobf/t_frw_key,
      _check_hotel  IMPORTING is_hotel      TYPE zsitv025_hotel
                              io_message    TYPE REF TO /bobf/if_frw_message
                    CHANGING  ct_failed_key TYPE /bobf/t_frw_key,
      _check_transport IMPORTING is_transport  TYPE zsitv025_transport
                                 io_message    TYPE REF TO /bobf/if_frw_message
                       CHANGING  ct_failed_key TYPE /bobf/t_frw_key.
ENDCLASS.



CLASS ZCL_I_ROOT_CHILD_CHECK IMPLEMENTATION.


  METHOD /bobf/if_frw_validation~execute.
    CHECK is_ctx-val_time = 'CHECK_BEFORE_SAVE'.

    "CLEAR et_failed_key.
    IF eo_message IS INITIAL.
      eo_message = /bobf/cl_frw_factory=>get_message( ).
    ENDIF.

    DATA(lr_current_items) = zcl_tv025_odata_model=>get_child_table( is_ctx-node_key ).
    FIELD-SYMBOLS <lt_current_items> TYPE STANDARD TABLE.
    ASSIGN lr_current_items->* TO <lt_current_items>.

    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = <lt_current_items> ).

    DATA(lt_required) = zcl_i_tv025_root_check=>get_required_fields(
      iv_cds       = SWITCH #( is_ctx-node_key WHEN zif_i_tv025_root_c=>sc_node-zi_tv025_flight    THEN 'ZI_TV025_FLIGHT'
                                               WHEN zif_i_tv025_root_c=>sc_node-zi_tv025_hotel     THEN 'ZI_TV025_HOTEL'
                                               WHEN zif_i_tv025_root_c=>sc_node-zi_tv025_transport THEN 'ZI_TV025_Transport' )
*      " Problem with format it_fieldname = VALUE #( ( |DATE_BEG| ) ( |DATE_END| ) )
      ).

    LOOP AT <lt_current_items> ASSIGNING FIELD-SYMBOL(<ls_current_item>).
      DATA(ls_ind_key) = CAST zcl_i_root_child_check( zcl_sadl_annotation_ext=>create( 'ZCL_I_ROOT_CHILD_CHECK' ) )->ms_ind_key.
      IF ls_ind_key IS NOT INITIAL.
        CHECK ls_ind_key = CORRESPONDING ts_ind_key( <ls_current_item> ).
      ENDIF.

      DATA(ls_key) = CORRESPONDING /bobf/s_frw_key_incl( <ls_current_item> ).

      zcl_i_tv025_root_check=>check_required_fields(
        EXPORTING is_root           = <ls_current_item>
                  is_ctx            = is_ctx
                  io_message        = eo_message
                  it_required_field = lt_required
       CHANGING   ct_failed_key     = et_failed_key ).

      CASE is_ctx-node_key.
        WHEN zif_i_tv025_root_c=>sc_node-zi_tv025_flight.
          _check_flight( EXPORTING is_flight     = CONV #( <ls_current_item> )
                                   io_message    = eo_message
                         CHANGING  ct_failed_key = et_failed_key ).
        WHEN zif_i_tv025_root_c=>sc_node-zi_tv025_hotel.
          _check_hotel( EXPORTING is_hotel       = CONV #( <ls_current_item> )
                                   io_message    = eo_message
                         CHANGING  ct_failed_key = et_failed_key ).
        WHEN zif_i_tv025_root_c=>sc_node-zi_tv025_transport.
          _check_transport( EXPORTING is_transport  = CONV #( <ls_current_item> )
                                      io_message    = eo_message
                            CHANGING  ct_failed_key = et_failed_key ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_sadl_prepare_batch~prepare.
    CHECK lines( ct_update[] ) = 1
      AND lines( ct_create[] ) = 0
      AND lines( ct_delete[] ) = 0
      AND lines( ct_action[] ) = 0.

    DATA(lr_update_item) = ct_update[ 1 ]-rs_entity_data.
    CHECK lr_update_item IS NOT INITIAL.
    ASSIGN lr_update_item->* TO FIELD-SYMBOL(<ls_update_item>).

    ms_ind_key = CORRESPONDING #( <ls_update_item> ).
  ENDMETHOD.


  METHOD _check_flight.
    CHECK is_flight-date_beg IS NOT INITIAL
      AND is_flight-date_end IS NOT INITIAL.

    IF |{ is_flight-date_beg }{ is_flight-time_beg }| > |{ is_flight-date_end }{ is_flight-time_end }|.
      APPEND VALUE #( key = is_flight-key ) TO ct_failed_key.

      MESSAGE e002(ztv_025) WITH |{ is_flight-date_beg DATE = USER } { is_flight-time_beg TIME = USER }|
                                 |{ is_flight-date_end DATE = USER } { is_flight-time_end TIME = USER }|
                            INTO sy-msgli.
      io_message->add_message(
        is_msg       = CORRESPONDING #( sy )
        iv_node      = zif_i_tv025_root_c=>sc_node-zi_tv025_flight
      ).
    ENDIF.
  ENDMETHOD.


  METHOD _check_hotel.
    CHECK is_hotel-date_beg IS NOT INITIAL
      AND is_hotel-date_end IS NOT INITIAL.

    IF is_hotel-date_beg > is_hotel-date_end.
      APPEND VALUE #( key = is_hotel-key ) TO ct_failed_key.

      MESSAGE e002(ztv_025) WITH |{ is_hotel-date_beg DATE = USER }|
                                 |{ is_hotel-date_end DATE = USER }|
                            INTO sy-msgli.
      io_message->add_message(
        is_msg       = CORRESPONDING #( sy )
        iv_node      = zif_i_tv025_root_c=>sc_node-zi_tv025_hotel
      ).
    ENDIF.
  ENDMETHOD.


  METHOD _check_transport.
    CHECK is_transport-date_beg IS NOT INITIAL
      AND is_transport-date_end IS NOT INITIAL.

    IF |{ is_transport-date_beg }{ is_transport-time_beg }| > |{ is_transport-date_end }{ is_transport-time_end }|.
      APPEND VALUE #( key = is_transport-key ) TO ct_failed_key.

      MESSAGE e002(ztv_025) WITH |{ is_transport-date_beg DATE = USER } { is_transport-time_beg TIME = USER }|
                                 |{ is_transport-date_end DATE = USER } { is_transport-time_end TIME = USER }|
                            INTO sy-msgli.
      io_message->add_message(
        is_msg       = CORRESPONDING #( sy )
        iv_node      = zif_i_tv025_root_c=>sc_node-zi_tv025_transport
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
