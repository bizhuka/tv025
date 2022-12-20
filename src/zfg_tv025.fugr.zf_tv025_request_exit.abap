FUNCTION zf_tv025_request_exit.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR
*"     REFERENCE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------

  " @see -> SE37 - > F4IF_SHLP_EXIT_EXAMPLE

  CHECK callcontrol-step = 'SELONE'
     OR callcontrol-step = 'SELECT'.

  IF shlp-selopt[] IS INITIAL.
*    STATICS lv_head_optional TYPE abap_bool VALUE abap_undefined.
*    lv_head_optional = SWITCH #( shlp-shlpname WHEN 'ZSH_TV025_REQUEST' THEN abap_false
*                                               WHEN 'ZSH_TV025_TRAVEL'  THEN abap_true
*                                               ELSE abap_undefined ).

    " Fields of ZDTV025_HEAD           COND #( WHEN lv_head_optional <> abap_true THEN ).
    shlp-selopt = VALUE #( ( shlpfield = 'CRUNM' sign = 'I' option = 'EQ' low = sy-uname )
                           ( shlpfield = 'CRDAT' sign = 'I' option = 'GE' low = |{ sy-datum(4) }0101| ) ) .


    APPEND VALUE #( shlpfield = 'ENAME' sign = 'I' option = 'CP' low = |**| ) TO shlp-selopt[].

    callcontrol-maxrecords = 100.

    callcontrol-step       = 'PRESEL'.
    "MESSAGE |Use can use select options with * mask| TYPE 'S'.
    RETURN.
  ENDIF.

*  ASSERT lv_head_optional <> abap_undefined.
  DATA(lt_result) = zcl_tv025_model=>get_instance( )->get_request_items(
    it_select        = shlp-selopt
    iv_count         = callcontrol-maxrecords
*    iv_head_optional = lv_head_optional
  ).
  f4ut_results_map lt_result.

  " Just display
  callcontrol-step = 'DISP'.
ENDFUNCTION.
