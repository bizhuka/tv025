CLASS zcl_a_tv025_copy_from DEFINITION
  PUBLIC
  INHERITING FROM /bobf/cl_lib_a_supercl_simple
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /bobf/if_frw_action~execute
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      mo_read    TYPE REF TO /bobf/if_frw_read,
      mo_modify  TYPE REF TO /bobf/if_frw_modify,
      mo_message TYPE REF TO /bobf/if_frw_message.
    METHODS:
      _do_copy IMPORTING iv_src_key       TYPE /bobf/conf_key
                         iv_dest_key      TYPE /bobf/conf_key
                         iv_child_node    TYPE /bobf/obm_node_key
                         iv_child_assoc   TYPE /bobf/obm_assoc_key
                         iv_keep_previous TYPE abap_bool,

      _delete_previous IMPORTING iv_dest_key    TYPE /bobf/conf_key
                                 iv_child_node  TYPE /bobf/obm_node_key
                                 iv_child_assoc TYPE /bobf/obm_assoc_key.
ENDCLASS.



CLASS ZCL_A_TV025_COPY_FROM IMPLEMENTATION.


  METHOD /bobf/if_frw_action~execute.
    CLEAR et_failed_key.
    IF eo_message IS INITIAL.
      eo_message = /bobf/cl_frw_factory=>get_message( ).
    ENDIF.
    mo_read        = io_read.
    mo_modify      = io_modify.
    mo_message     = eo_message.

    DATA(lt_root) = VALUE ztitv025_root( ).
    mo_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = lt_root ).
    " Input parameters
    DATA(ls_param) = CAST zss_tv025_copy_from_params( is_parameters ).

**********************************************************************
**********************************************************************

    DATA(lo_service_manager) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( zif_i_tv025_root_c=>sc_bo_key ).

    DATA(lt_src_key) = VALUE /bobf/t_frw_key( ).
    lo_service_manager->convert_altern_key( EXPORTING iv_node_key	  = zif_i_tv025_root_c=>sc_node-zi_tv025_root
                                                      iv_altkey_key = zif_i_tv025_root_c=>sc_alternative_key-zi_tv025_root-db_key
                                                      it_key        = VALUE ztk_itv025_root_db_key( (
                                                                          pernr        = ls_param->src_pernr
                                                                          reinr        = ls_param->src_reinr
                                                                          plan_request = 'R'
                                                                          requestvrs   = '99' ) )
                                            IMPORTING et_key        = lt_src_key ).
    ASSERT lines( lt_src_key ) = 1.

**********************************************************************
**********************************************************************
    LOOP AT lt_root ASSIGNING FIELD-SYMBOL(<ls_root>).
      " №1
      IF ls_param->copy_flight = abap_true.
        _do_copy( iv_src_key       = lt_src_key[ 1 ]-key
                  iv_dest_key      = <ls_root>-key
                  iv_child_node    = zif_i_tv025_root_c=>sc_node-zi_tv025_flight
                  iv_child_assoc   = zif_i_tv025_root_c=>sc_association-zi_tv025_root-_flight
                  iv_keep_previous = ls_param->keep_previous ).
      ENDIF.

      " №2
      IF ls_param->copy_hotel = abap_true.
        _do_copy( iv_src_key       = lt_src_key[ 1 ]-key
                  iv_dest_key      = <ls_root>-key
                  iv_child_node    = zif_i_tv025_root_c=>sc_node-zi_tv025_hotel
                  iv_child_assoc   = zif_i_tv025_root_c=>sc_association-zi_tv025_root-_hotel
                  iv_keep_previous = ls_param->keep_previous ).
      ENDIF.

      " №3
      IF ls_param->copy_transport = abap_true.
        _do_copy( iv_src_key       = lt_src_key[ 1 ]-key
                  iv_dest_key      = <ls_root>-key
                  iv_child_node    = zif_i_tv025_root_c=>sc_node-zi_tv025_transport
                  iv_child_assoc   = zif_i_tv025_root_c=>sc_association-zi_tv025_root-_transport
                  iv_keep_previous = ls_param->keep_previous ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD _delete_previous.
    FIELD-SYMBOLS <lt_dest_items> TYPE STANDARD TABLE.
    DATA(lr_dest_items) = zcl_tv025_odata_model=>get_child_table( iv_child_node ).
    ASSIGN lr_dest_items->* TO <lt_dest_items>.

    mo_read->retrieve_by_association( EXPORTING iv_node        = zif_i_tv025_root_c=>sc_node-zi_tv025_root
                                                it_key         = VALUE #( ( key = iv_dest_key ) )
                                                iv_association = iv_child_assoc
                                                iv_fill_data   = abap_true
                                      IMPORTING eo_message     = mo_message
                                                et_data        = <lt_dest_items>
                                                et_failed_key  = DATA(lt_dest_failed_key) ).
    ASSERT lt_dest_failed_key[] IS INITIAL.

    LOOP AT <lt_dest_items> ASSIGNING FIELD-SYMBOL(<ls_dest_item>).
      ASSIGN COMPONENT 'KEY' OF STRUCTURE <ls_dest_item> TO FIELD-SYMBOL(<lv_key>).

      mo_modify->do_modify(
         VALUE #( ( node        = iv_child_node
                    change_mode = /bobf/if_frw_c=>sc_modify_delete
                    source_node = zif_i_tv025_root_c=>sc_node-zi_tv025_root
                    association = iv_child_assoc
                    source_key  = iv_dest_key
                    root_key    = iv_dest_key
                    key         = <lv_key>
                    data        = REF #( <ls_dest_item> )  ) ) ).
    ENDLOOP.
  ENDMETHOD.


  METHOD _do_copy.
    IF iv_keep_previous <> abap_true.
      _delete_previous( iv_dest_key    = iv_dest_key
                        iv_child_node  = iv_child_node
                        iv_child_assoc = iv_child_assoc ).
    ENDIF.

    FIELD-SYMBOLS <lt_src_items> TYPE STANDARD TABLE.
    DATA(lr_src_items) = zcl_tv025_odata_model=>get_child_table( iv_child_node ).
    ASSIGN lr_src_items->* TO <lt_src_items>.

    mo_read->retrieve_by_association( EXPORTING iv_node        = zif_i_tv025_root_c=>sc_node-zi_tv025_root
                                                it_key         = VALUE #( ( key = iv_src_key ) )
                                                iv_association = iv_child_assoc
                                                iv_fill_data   = abap_true
                                      IMPORTING eo_message     = mo_message
                                                et_data        = <lt_src_items>
                                                et_failed_key  = DATA(lt_src_failed_key) ).
    ASSERT lt_src_failed_key[] IS INITIAL.

    LOOP AT <lt_src_items> ASSIGNING FIELD-SYMBOL(<ls_src_item>).
      ASSIGN COMPONENT 'S_INDEX' OF STRUCTURE <ls_src_item> TO FIELD-SYMBOL(<lv_index>).
      <lv_index> = 0.

      ASSIGN COMPONENT 'KEY' OF STRUCTURE <ls_src_item> TO FIELD-SYMBOL(<lv_key>).
      <lv_key> = /bobf/cl_frw_factory=>get_new_key( ).

      mo_modify->do_modify(
         VALUE #( ( node        = iv_child_node
                    change_mode = /bobf/if_frw_c=>sc_modify_create
                    source_node = zif_i_tv025_root_c=>sc_node-zi_tv025_root
                    association = iv_child_assoc
                    source_key  = iv_dest_key
                    root_key    = iv_dest_key
                    key         = <lv_key>
                    data        = REF #( <ls_src_item> )  ) ) ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
