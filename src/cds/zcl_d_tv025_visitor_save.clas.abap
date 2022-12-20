class ZCL_D_TV025_VISITOR_SAVE definition
  public
  inheriting from /BOBF/CL_LIB_D_SUPERCL_SIMPLE
  final
  create public .

public section.

  class-data CREATED_VISITOR type ZSITV025_VISITOR read-only .

  methods /BOBF/IF_FRW_DETERMINATION~EXECUTE
    redefinition .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS _set_key
      IMPORTING io_message    TYPE REF TO /bobf/if_frw_message
      CHANGING  ct_failed_key TYPE /bobf/t_frw_key
                cs_visitor    TYPE zsitv025_visitor .
ENDCLASS.



CLASS ZCL_D_TV025_VISITOR_SAVE IMPLEMENTATION.


  METHOD /bobf/if_frw_determination~execute.
    DATA(lt_visitor) = VALUE ztitv025_visitor( ).
    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = lt_visitor ).

    IF eo_message IS INITIAL.
      eo_message = /bobf/cl_frw_factory=>get_message( ).
    ENDIF.


    LOOP AT lt_visitor ASSIGNING FIELD-SYMBOL(<ls_visitor>).
      _set_key( EXPORTING io_message    = eo_message
                CHANGING  ct_failed_key = et_failed_key
                          cs_visitor    = <ls_visitor> ).

      io_modify->update( iv_node           = is_ctx-node_key
                         iv_key            = <ls_visitor>-key

                         is_data           = REF #( <ls_visitor> )
                         it_changed_fields = VALUE #( ( |PERNR| )
                                                    ) ).

      " Just return if created
      created_visitor = <ls_visitor>.
    ENDLOOP.
  ENDMETHOD.


  METHOD _set_key.
    CHECK cs_visitor-pernr IS INITIAL.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '1'
        object      = 'ZTV025_VIS'
      IMPORTING
        number      = cs_visitor-pernr
      EXCEPTIONS
        OTHERS      = 8.

    CHECK sy-subrc <> 0.
    APPEND VALUE #( key = cs_visitor-key ) TO ct_failed_key.

    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
    io_message->add_message(
          is_msg       = CORRESPONDING #( sy )
          iv_node      = zif_i_tv025_visitor_c=>sc_node-zi_tv025_visitor
          iv_attribute = 'PERNR' ).
  ENDMETHOD.
ENDCLASS.
