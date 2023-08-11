CLASS zcl_d_tv025_auto_num_save DEFINITION
  PUBLIC
  INHERITING FROM /bobf/cl_lib_d_supercl_simple
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /bobf/if_frw_determination~execute
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_D_TV025_AUTO_NUM_SAVE IMPLEMENTATION.


  METHOD /bobf/if_frw_determination~execute.
    DATA(lr_table)     = VALUE dataref( ).
    DATA(lv_key_field) = ||.
    DATA(lv_max_num3)  = VALUE numc3( ).

    CASE is_ctx-node_key.
      WHEN zif_c_tv025_basis_c=>sc_node-zc_tv025_basis.
        lr_table     = NEW ztctv025_basis( ).
        lv_key_field = |BASIS_ID|.
        SELECT MAX( basis_id ) FROM zdtv025_basis INTO @lv_max_num3. "#EC CI_NOWHERE

      WHEN zif_c_tv025_agency_c=>sc_node-zc_tv025_agency.
        lr_table     = NEW ztctv025_agency( ).
        lv_key_field = |AGENCY_ID|.
        SELECT MAX( agency_id ) FROM zdtv025_agency INTO @lv_max_num3. "#EC CI_NOWHERE

      WHEN zif_c_tv025_approvedby_c=>sc_node-zc_tv025_approvedby.
        lr_table     =  NEW ztctv025_approvedby( ).
        lv_key_field = |APPR_BY|.
        SELECT MAX( appr_by ) FROM zdtv025_appr_by INTO @lv_max_num3. "#EC CI_NOWHERE

      WHEN OTHERS.
        zcx_eui_no_check=>raise_sys_error( iv_message = |Unknown key { is_ctx-node_key }| ).
    ENDCASE.

    FIELD-SYMBOLS <lt_table> TYPE STANDARD TABLE.
    ASSIGN lr_table->* TO <lt_table>.

    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = <lt_table> ).

    IF eo_message IS INITIAL.
      eo_message = /bobf/cl_frw_factory=>get_message( ).
    ENDIF.

    LOOP AT <lt_table> ASSIGNING FIELD-SYMBOL(<ls_item>).
      ASSIGN COMPONENT lv_key_field OF STRUCTURE <ls_item> TO FIELD-SYMBOL(<lv_key_field>).
      CHECK <lv_key_field> IS INITIAL.

      ADD 1 TO lv_max_num3.
      <lv_key_field> = lv_max_num3.

      ASSIGN COMPONENT 'KEY' OF STRUCTURE <ls_item> TO FIELD-SYMBOL(<lv_bopf_key>).
      io_modify->update( iv_node           = is_ctx-node_key
                         iv_key            = <lv_bopf_key>

                         is_data           = REF #( <ls_item> )
                         it_changed_fields = VALUE #( ( lv_key_field ) ) ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
