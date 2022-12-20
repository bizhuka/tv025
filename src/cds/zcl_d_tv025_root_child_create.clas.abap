CLASS zcl_d_tv025_root_child_create DEFINITION
  PUBLIC
  INHERITING FROM /bobf/cl_lib_d_supercl_simple
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /bobf/if_frw_determination~execute
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS _set_full_key
      IMPORTING
        !io_read TYPE REF TO /bobf/if_frw_read
        !is_ctx  TYPE /bobf/s_frw_ctx_det
        !is_key  TYPE /bobf/s_frw_key_incl
      CHANGING
        !cs_item TYPE any .
    METHODS _set_s_index
      IMPORTING
        !io_read    TYPE REF TO /bobf/if_frw_read
        !is_ctx     TYPE /bobf/s_frw_ctx_det
        !is_key     TYPE /bobf/s_frw_key_incl
      CHANGING
        !co_message TYPE REF TO /bobf/if_frw_message
        !cs_item    TYPE any .
ENDCLASS.



CLASS ZCL_D_TV025_ROOT_CHILD_CREATE IMPLEMENTATION.


  METHOD /bobf/if_frw_determination~execute.
    CLEAR et_failed_key.
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

    LOOP AT <lt_current_items> ASSIGNING FIELD-SYMBOL(<ls_current_item>).
      DATA(ls_key) = CORRESPONDING /bobf/s_frw_key_incl( <ls_current_item> ).

      _set_full_key( EXPORTING io_read    = io_read
                               is_ctx     = is_ctx
                               is_key     = ls_key
                     CHANGING  cs_item    = <ls_current_item> ).

      _set_s_index( EXPORTING io_read    = io_read
                              is_ctx     = is_ctx
                              is_key     = ls_key
                    CHANGING  co_message = eo_message
                              cs_item    = <ls_current_item> ).

      io_modify->update( iv_node           = is_ctx-node_key
                         iv_key            = ls_key-key
                         "IV_ROOT_KEY = is_ctx-root_node_key
                         is_data           = REF #( <ls_current_item> )
                         it_changed_fields = VALUE #( ( |EMPLOYEE_NUMBER| )
                                                      ( |TRIP_NUMBER| )
                                                      ( |REQUESTVRS| )
                                                      ( |PLAN_REQUEST| )
                                                      ( |S_INDEX| )
                                                    ) ).
    ENDLOOP.
  ENDMETHOD.


  METHOD _set_full_key.
    DATA(lt_root) = VALUE ztitv025_root( ).
    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-root_node_key
                it_key        = VALUE #( ( key = is_key-parent_key ) )
                iv_fill_data  = abap_true
      IMPORTING et_data       = lt_root ).

    MOVE-CORRESPONDING VALUE zcl_tv025_model=>ts_full_key(
      employee_number = lt_root[ 1 ]-pernr
      trip_number     = lt_root[ 1 ]-reinr
      requestvrs      = lt_root[ 1 ]-requestvrs
      plan_request    = lt_root[ 1 ]-plan_request
    ) TO cs_item.
  ENDMETHOD.


  METHOD _set_s_index.
    ASSIGN COMPONENT 'S_INDEX' OF STRUCTURE cs_item TO FIELD-SYMBOL(<lv_index>).
    CHECK <lv_index> IS INITIAL.

    DATA(lr_siblings) = zcl_tv025_odata_model=>get_child_table( is_ctx-node_key ).
    FIELD-SYMBOLS <lt_siblings> TYPE STANDARD TABLE.
    ASSIGN lr_siblings->* TO <lt_siblings>.

    io_read->retrieve_by_association(
        EXPORTING iv_node        = is_ctx-root_node_key
                  it_key         = VALUE #( ( key = is_key-parent_key ) )
                  iv_association = zcl_tv025_odata_model=>get_root_child_association( is_ctx-node_key )
                  "is_parameters  = VALUE #( )
                  iv_fill_data   = abap_true
        IMPORTING eo_message     = co_message
                  et_data        = <lt_siblings> ).

    DATA(lv_max_index) = VALUE index( ).
    LOOP AT <lt_siblings> ASSIGNING FIELD-SYMBOL(<ls_sibling>).
      ASSIGN COMPONENT 'S_INDEX' OF STRUCTURE <ls_sibling> TO FIELD-SYMBOL(<lv_max_index>).

      CHECK lv_max_index < <lv_max_index>.
      lv_max_index = <lv_max_index>.
    ENDLOOP.

    " And set MAX + 1
    <lv_index> = lv_max_index + 1.
  ENDMETHOD.
ENDCLASS.
