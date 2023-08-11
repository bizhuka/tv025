CLASS zcl_a_tv025_transp_inverse_cop DEFINITION
  PUBLIC
  INHERITING FROM /bobf/cl_lib_a_supercl_simple
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /bobf/if_frw_action~execute
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_A_TV025_TRANSP_INVERSE_COP IMPLEMENTATION.


  METHOD /bobf/if_frw_action~execute.
    CLEAR et_failed_key.
    IF eo_message IS INITIAL.
      eo_message = /bobf/cl_frw_factory=>get_message( ).
    ENDIF.

    DATA(lt_transport) = NEW ztitv025_transport( ).
    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = lt_transport->* ).

    LOOP AT lt_transport->* ASSIGNING FIELD-SYMBOL(<ls_transport>).
      DATA(lt_root) = VALUE ztitv025_root( ).
      io_read->retrieve_by_association(
         EXPORTING
           iv_node                 = zif_i_tv025_root_c=>sc_node-zi_tv025_transport
           it_key                  = VALUE #( ( key = <ls_transport>-key ) )
           iv_association          = zif_i_tv025_root_c=>sc_association-zi_tv025_transport-to_root
           iv_fill_data            = abap_true
         IMPORTING
           et_data                 = lt_root ).
      CHECK lt_root[] IS NOT INITIAL.

      zcl_tv025_odata_model=>check_status( is_root    = lt_root[ 1 ]
                                           io_message = eo_message ).

      " Get end of inverse copy
      DATA(lv_root_end)   = lt_root[ 1 ]-date_end && lt_root[ 1 ]-time_end.
      DATA(lv_transport_end) = <ls_transport>-date_end  && <ls_transport>-time_end.
      DATA(lv_max)        = COND #( WHEN lv_root_end > lv_transport_end THEN lv_root_end ELSE lv_transport_end ).

      <ls_transport>-key = /bobf/cl_frw_factory=>get_new_key( ).

      " Index set automatically in -> ZCL_D_TV025_ROOT_SAVE
      CLEAR <ls_transport>-s_index.

      " Swap
      DATA(lv_temp) = <ls_transport>-check_point.
      <ls_transport>-check_point = <ls_transport>-arrival.
      <ls_transport>-arrival = lv_temp.

      " Go back at the same date
      <ls_transport>-date_beg = <ls_transport>-date_end.
      <ls_transport>-time_beg = <ls_transport>-time_end.
      <ls_transport>-date_end = lv_max(8).
      <ls_transport>-time_end = lv_max+8.

      io_modify->do_modify(
         VALUE #( ( node        = zif_i_tv025_root_c=>sc_node-zi_tv025_transport
                    change_mode = /bobf/if_frw_c=>sc_modify_create
                    source_node = zif_i_tv025_root_c=>sc_node-zi_tv025_root
                    association = zif_i_tv025_root_c=>sc_association-zi_tv025_root-_transport
                    source_key  = <ls_transport>-root_key " parent_key
                    root_key    = <ls_transport>-root_key
                    key         = <ls_transport>-key
                    data        = REF #( <ls_transport> )  ) ) ).

      " Result
      APPEND <ls_transport> TO et_data[].
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
