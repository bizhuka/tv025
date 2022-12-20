CLASS zcl_i_tv025_visitor_check DEFINITION
  PUBLIC
  INHERITING FROM /bobf/cl_lib_v_supercl_simple
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor .

    METHODS /bobf/if_frw_validation~execute
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: mt_required_field TYPE zcl_i_tv025_root_check=>tt_required_field.
ENDCLASS.



CLASS ZCL_I_TV025_VISITOR_CHECK IMPLEMENTATION.


  METHOD /bobf/if_frw_validation~execute.
    " Called 2 times. Skip 1 of them
    CHECK is_ctx-val_time = 'CHECK_BEFORE_SAVE'.

    IF eo_message IS INITIAL.
      eo_message = /bobf/cl_frw_factory=>get_message( ).
    ENDIF.

    DATA(lt_visitor) = VALUE ztitv025_visitor( ).
    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = lt_visitor ).

    LOOP AT lt_visitor ASSIGNING FIELD-SYMBOL(<ls_visitor>).
      zcl_i_tv025_root_check=>check_required_fields(
        EXPORTING is_root           = <ls_visitor>
                  is_ctx            = is_ctx
                  io_message        = eo_message
                  it_required_field = mt_required_field
        CHANGING  ct_failed_key     = et_failed_key ).

      IF    <ls_visitor>-passp_number IS NOT INITIAL
        AND find( val = |{ <ls_visitor>-passp_number }| regex = '^[0-9A-Z]*$' ) <> 0.

        MESSAGE e003(ztv_025) WITH <ls_visitor>-passp_number INTO sy-msgli.
        eo_message->add_message(
          is_msg       = CORRESPONDING #( sy )
          iv_node      = is_ctx-node_key
          iv_attribute = |PASSP_NUMBER| ).
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD constructor.
    super->constructor( ).
    mt_required_field = zcl_i_tv025_root_check=>get_required_fields( 'ZI_TV025_VISITOR' ).
  ENDMETHOD.
ENDCLASS.
