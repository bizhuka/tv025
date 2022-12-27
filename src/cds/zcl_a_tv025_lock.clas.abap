CLASS zcl_a_tv025_lock DEFINITION
  PUBLIC
  INHERITING FROM /bobf/cl_lib_a_supercl_simple
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    CONSTANTS mc_etag_user TYPE syuname VALUE 'ZZ_ETAG_USER'.

    CLASS-DATA mv_error_message TYPE string READ-ONLY.

    METHODS /bobf/if_frw_action~execute
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_A_TV025_LOCK IMPLEMENTATION.


  METHOD /bobf/if_frw_action~execute.

    CLEAR et_failed_key.
    IF eo_message IS INITIAL.
      eo_message = /bobf/cl_frw_factory=>get_message( ).
    ENDIF.

    DATA(lt_root) = VALUE ztitv025_root( ).
    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = lt_root ).

**********************************************************************
**********************************************************************
    LOOP AT lt_root ASSIGNING FIELD-SYMBOL(<ls_root>).
      GET TIME STAMP FIELD DATA(lv_current_time).

      IF zcl_tv025_model=>get_instance( )->lock( iv_pernr = <ls_root>-pernr
                                                 iv_reinr = <ls_root>-reinr ) <> abap_true.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO mv_error_message.
*        MESSAGE s004(ztv_025) WITH |{ <ls_root>-pernr ALPHA = OUT }|
*                                   |{ <ls_root>-reinr ALPHA = OUT }|
*                                   zcl_tv025_model=>get_instance( )->get_user_ename( <ls_root>-zz_etag_usr )
*                                   |in SAP gui|
*                                   INTO mv_error_message.
        RETURN.
      ENDIF.

*      IF <ls_root>-zz_etag > lv_current_time AND <ls_root>-zz_etag_usr <> sy-uname.
*        cl_abap_tstmp=>subtract( EXPORTING  tstmp1 = <ls_root>-zz_etag
*                                            tstmp2 = lv_current_time
*                                 RECEIVING  r_secs = DATA(lv_sec)
*                                 EXCEPTIONS OTHERS = 0 ).
*        MESSAGE s004(ztv_025) WITH |{ <ls_root>-pernr ALPHA = OUT }|
*                                   |{ <ls_root>-reinr ALPHA = OUT }|
*                                   zcl_tv025_model=>get_instance( )->get_user_ename( <ls_root>-zz_etag_usr )
*                                   |for { CONV decfloat34( lv_sec / 60 ) DECIMALS = 1 } minutes|
*                                   INTO mv_error_message.
*        RETURN.
*      ENDIF.
*
*      " Block for 5 minutes
*      <ls_root>-zz_etag_usr = mc_etag_user.
*      <ls_root>-zz_etag     = cl_abap_tstmp=>add( tstmp = lv_current_time
*                                                  secs  = 60 * 5 ).
*      io_modify->update( iv_node           = is_ctx-node_key
*                         iv_key            = <ls_root>-key
*
*                         is_data           = REF #( <ls_root> )
*                         it_changed_fields = VALUE #( ( |ZZ_ETAG| )
*                                                      ( |ZZ_ETAG_USR| )
*                                                    ) ).
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
