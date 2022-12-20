CLASS zcl_d_tv025_root_save DEFINITION
  PUBLIC
  INHERITING FROM /bobf/cl_lib_d_supercl_simple
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA created_root TYPE zsitv025_root_d READ-ONLY.

    METHODS /bobf/if_frw_determination~execute
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS _set_key
      CHANGING
        !cs_root TYPE zsitv025_root .
ENDCLASS.



CLASS ZCL_D_TV025_ROOT_SAVE IMPLEMENTATION.


  METHOD /bobf/if_frw_determination~execute.
    DATA(lt_root) = VALUE ztitv025_root( ).
    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = lt_root ).

    LOOP AT lt_root ASSIGNING FIELD-SYMBOL(<ls_root>).
      DATA(lt_change_fields) = VALUE /bobf/t_frw_name( ( |UNAME| )
                                                       ( |DATES| )
                                                       ( |TIMES| )
                                                       ( |CREATEDBY| )
                                                       ( |ZZ_CRDAT| )
                                                       ( |ZZ_CRTIME| )
                                                       ( |ZZ_STATUS| )

                                                       ( |REQUESTVRS| )
                                                       ( |PLAN_REQUEST| )
                                                       ( |REINR| ) ).
      IF <ls_root>-zz_etag_usr = zcl_a_tv025_lock=>mc_etag_user.
        <ls_root>-zz_etag_usr = sy-uname.
        lt_change_fields      = VALUE #( ( |ZZ_ETAG_USR| ) ).
      ELSE.
        " Copy previous from changed
        IF <ls_root>-zz_crdat IS INITIAL.
          <ls_root>-zz_crdat = <ls_root>-dates.
        ENDIF.
        IF <ls_root>-zz_crtime IS INITIAL.
          <ls_root>-zz_crtime = <ls_root>-times.
        ENDIF.

        " Changed
        <ls_root>-uname = sy-uname.
        <ls_root>-dates = sy-datum.
        <ls_root>-times = sy-uzeit.

        " Created
        <ls_root>-createdby = COND #( WHEN <ls_root>-createdby IS NOT INITIAL THEN <ls_root>-createdby ELSE sy-uname ).
        <ls_root>-zz_crdat  = COND #( WHEN <ls_root>-zz_crdat  IS NOT INITIAL THEN <ls_root>-zz_crdat  ELSE sy-datum ).
        <ls_root>-zz_crtime = COND #( WHEN <ls_root>-zz_crtime IS NOT INITIAL THEN <ls_root>-zz_crtime ELSE sy-uzeit ).

        " Status
        <ls_root>-zz_status = COND #( WHEN <ls_root>-zz_status IS NOT INITIAL THEN <ls_root>-zz_status ELSE zcl_tv025_model=>mc_status-open ).
        _set_key( CHANGING cs_root = <ls_root> ).
      ENDIF.

      io_modify->update( iv_node           = is_ctx-node_key
                         iv_key            = <ls_root>-key
                         is_data           = REF #( <ls_root> )
                         it_changed_fields = lt_change_fields ).

      " Just retrieve new one IN ZCL_V_TV025_ROOT
      created_root = <ls_root>-node_data.
    ENDLOOP.
  ENDMETHOD.


  METHOD _set_key.
    cs_root-requestvrs   = 99.
    cs_root-plan_request = 'R'.

    CHECK cs_root-reinr IS INITIAL.

    "TODO read by BOPF
    SELECT MAX( reinr ) INTO @DATA(lv_max_reinr)
    FROM ftpt_req_head
    WHERE pernr = @cs_root-pernr.

    cs_root-reinr = lv_max_reinr + 1.
  ENDMETHOD.
ENDCLASS.
