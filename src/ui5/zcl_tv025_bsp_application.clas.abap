class ZCL_TV025_BSP_APPLICATION definition
  public
  inheriting from CL_BSP_APPLICATION
  final
  create public .

public section.

  types:
    BEGIN OF ts_lock_result,
             message TYPE string,
             error   TYPE string,
           END OF ts_lock_result .

  methods LOCK
    returning
      value(RS_RESULT) type TS_LOCK_RESULT .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TV025_BSP_APPLICATION IMPLEMENTATION.


  METHOD lock.
    DATA(lt_params) = VALUE tihttpnvp( ).
    get_runtime( )->server->request->get_form_fields( CHANGING fields = lt_params ).

    TRY.
        IF zcl_tv025_model=>get_instance( )->lock( iv_pernr = CONV #( lt_params[ name = 'pernr' ]-value )
                                                   iv_reinr = CONV #( lt_params[ name = 'reinr' ]-value ) ) = abap_true.
          rs_result-message = 'OK'.
          RETURN.
        ENDIF.

        zcx_eui_exception=>raise_sys_error( ).
      CATCH cx_root INTO DATA(lo_error).
        rs_result-message = lo_error->get_text( ).
        rs_result-error   = abap_true.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
