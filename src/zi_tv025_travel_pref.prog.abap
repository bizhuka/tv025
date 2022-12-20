*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_user_prefs DEFINITION FINAL FRIENDS zcl_eui_event_caller.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ts_opt,
        v_max_count TYPE num2,
      END OF ts_opt.
    DATA:
      t_opened TYPE ztt_tv025_tv_req_key READ-ONLY,
      s_opt    TYPE ts_opt               READ-ONLY.

    METHODS:
      constructor,

      show_screen,

      add_opened
        IMPORTING
          is_db_key TYPE ts_db_key
          iv_insert TYPE abap_bool DEFAULT abap_true.

  PRIVATE SECTION.
    METHODS:
      _check_opened,

      _save_all,

      _on_pref_pai FOR EVENT pai_event OF zif_eui_manager
        IMPORTING
          sender
          iv_command
          cv_close.
ENDCLASS.

CLASS lcl_user_prefs IMPLEMENTATION.
  METHOD constructor.
    SELECT SINGLE prefs INTO @DATA(lv_prefs)
    FROM zdtv025_prefs
    WHERE uname = @sy-uname.

    TRY.
        CALL TRANSFORMATION id
         SOURCE XML lv_prefs
         RESULT t_opened = me->t_opened
                s_opt    = me->s_opt.
      CATCH cx_transformation_error.
        CLEAR: me->t_opened[],
               me->s_opt.
    ENDTRY.

    _check_opened( ).

    " Some error in prefs?
    CHECK s_opt-v_max_count IS INITIAL.
    s_opt-v_max_count = 7.
  ENDMETHOD.

  METHOD _check_opened.
    CHECK t_opened[] IS NOT INITIAL.

    SELECT pernr, reinr INTO TABLE @DATA(lt_exist)
    FROM zc_tv025_root
    FOR ALL ENTRIES IN @t_opened
    WHERE pernr = @t_opened-pernr
      AND reinr = @t_opened-reinr.
    SORT lt_exist BY pernr reinr.

    FIELD-SYMBOLS <ls_opened> LIKE LINE OF t_opened.
    LOOP AT t_opened[] ASSIGNING <ls_opened>.
      DATA lv_tabix TYPE sytabix.
      lv_tabix = sy-tabix.

      READ TABLE lt_exist TRANSPORTING NO FIELDS BINARY SEARCH
       WITH KEY pernr = <ls_opened>-pernr
                reinr = <ls_opened>-reinr.
      CHECK sy-subrc <> 0.

      DELETE t_opened[] INDEX lv_tabix.
    ENDLOOP.
  ENDMETHOD.

  METHOD add_opened.
    " Delete same travel
    DELETE t_opened WHERE pernr = is_db_key-pernr
                      AND reinr = is_db_key-reinr.

    IF iv_insert = abap_true.
      INSERT is_db_key INTO t_opened[] INDEX 1.
    ENDIF.

    " Delete oversized
    DELETE t_opened FROM s_opt-v_max_count + 1.

    _save_all( ).
  ENDMETHOD.

  METHOD _save_all.
    DATA(ls_db) = VALUE zdtv025_prefs( uname = sy-uname ).

    CALL TRANSFORMATION id
     SOURCE t_opened = me->t_opened
            s_opt    = me->s_opt
     RESULT XML ls_db-prefs.

    MODIFY zdtv025_prefs FROM ls_db.
  ENDMETHOD.

  METHOD show_screen.
    DATA(lr_opt) = NEW ts_opt( s_opt ).
    TRY.
        DATA(lo_screen) = NEW zcl_eui_screen(
            ir_context = lr_opt
            iv_cprog   = |{ sy-cprog }_PREF|
            iv_dynnr   = zcl_eui_screen=>mc_dynnr-dynamic ).
      CATCH zcx_eui_exception INTO DATA(lo_error).
        MESSAGE lo_error TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.
    lo_screen->customize( name = 'V_MAX_COUNT' iv_label = 'Maximum node count in tree'(mnc)  required = '1' ).

    lo_screen->popup( iv_col_beg = 30
                      iv_col_end = 70 ).
    CHECK lo_screen->show(
      io_handler      = me
      iv_handlers_map = '_ON_PREF_PAI' ) = 'OK'.

    s_opt = lr_opt->*.
    _save_all( ).
  ENDMETHOD.

  METHOD _on_pref_pai.
    CHECK iv_command = 'OK'.

    " Screen data
    DATA(lr_opt) = CAST ts_opt( CAST zcl_eui_screen( sender )->get_context( ) ).
    IF lr_opt->v_max_count > 10 OR lr_opt->v_max_count < 1.
      MESSAGE 'Set maximum from 1 to 10'(m10) TYPE 'S' DISPLAY LIKE 'E'.
      cv_close->* = abap_false.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
