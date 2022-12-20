FUNCTION zf_tv025_visitor_exit.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR
*"     REFERENCE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------


  CHECK callcontrol-step = 'RETURN'
    AND sy-tcode cp 'ZTV*025*'.

  " Bug with activation
  DO 1 TIMES.
    ASSIGN shlp-interface[ shlpfield = 'CITIZENSHIP' ] TO FIELD-SYMBOL(<ls_citizenship>).
    CHECK sy-subrc = 0.

    DATA(ls_passport_field) = shlp-interface[ shlpfield = 'PASSP_NUMBER' ].
    DATA(lv_before_num) = CONV num7( ls_passport_field-valfield+1 - 1 ).

    " Always stay befor passport
    <ls_citizenship>-valfield = ls_passport_field-valfield(1) && lv_before_num.
  ENDDO.

  " just return all fields
  LOOP AT shlp-fieldprop ASSIGNING FIELD-SYMBOL(<ls_prop>).
    <ls_prop>-shlpoutput = abap_true.
  ENDLOOP.
ENDFUNCTION.
