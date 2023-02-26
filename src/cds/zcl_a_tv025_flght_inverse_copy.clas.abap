CLASS zcl_a_tv025_flght_inverse_copy DEFINITION
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



CLASS ZCL_A_TV025_FLGHT_INVERSE_COPY IMPLEMENTATION.


  METHOD /bobf/if_frw_action~execute.
    CLEAR et_failed_key.
    IF eo_message IS INITIAL.
      eo_message = /bobf/cl_frw_factory=>get_message( ).
    ENDIF.

    DATA(lt_flight) = NEW ztitv025_flight( ).
    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = lt_flight->* ).

    LOOP AT lt_flight->* ASSIGNING FIELD-SYMBOL(<ls_flight>).
      DATA(lt_root) = VALUE ztitv025_root( ).
      io_read->retrieve_by_association(
         EXPORTING
           iv_node                 = zif_i_tv025_root_c=>sc_node-zi_tv025_flight
           it_key                  = VALUE #( ( key = <ls_flight>-key ) )
           iv_association          = zif_i_tv025_root_c=>sc_association-zi_tv025_flight-to_root
           iv_fill_data            = abap_true
         IMPORTING
           et_data                 = lt_root ).
      CHECK lt_root[] IS NOT INITIAL.

      " Get end of inverse copy
      DATA(lv_root_end)   = lt_root[ 1 ]-date_end && lt_root[ 1 ]-time_end.
      DATA(lv_flight_end) = <ls_flight>-date_end  && <ls_flight>-time_end.
      DATA(lv_max)        = COND #( WHEN lv_root_end > lv_flight_end THEN lv_root_end ELSE lv_flight_end ).

      <ls_flight>-key = /bobf/cl_frw_factory=>get_new_key( ).

      " Index set automatically in -> ZCL_D_TV025_ROOT_SAVE
      CLEAR <ls_flight>-s_index.

      " Swap
      DATA(lv_temp) = <ls_flight>-airport_beg.
      <ls_flight>-airport_beg = <ls_flight>-airport_end.
      <ls_flight>-airport_end = lv_temp.

      " Go back at the same date
      <ls_flight>-date_beg = <ls_flight>-date_end.
      <ls_flight>-time_beg = <ls_flight>-time_end.
      <ls_flight>-date_end = lv_max(8).
      <ls_flight>-time_end = lv_max+8.

      io_modify->do_modify(
         VALUE #( ( node        = zif_i_tv025_root_c=>sc_node-zi_tv025_flight
                    change_mode = /bobf/if_frw_c=>sc_modify_create
                    source_node = zif_i_tv025_root_c=>sc_node-zi_tv025_root
                    association = zif_i_tv025_root_c=>sc_association-zi_tv025_root-_flight
                    source_key  = <ls_flight>-root_key " parent_key
                    root_key    = <ls_flight>-root_key
                    key         = <ls_flight>-key
                    data        = REF #( <ls_flight> )  ) ) ).

      " Result
      APPEND <ls_flight> TO et_data[].
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
