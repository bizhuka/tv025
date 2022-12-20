*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*


CLASS lcl_ui_container DEFINITION.
  PUBLIC SECTION.

    TYPES:
      tt_ref TYPE STANDARD TABLE OF REF TO data.

    METHODS:
      init_date_checker IMPORTING it_low  TYPE tt_ref
                                  it_high TYPE tt_ref,
      is_date_ok RETURNING VALUE(rv_ok) TYPE abap_bool,


      find_empty IMPORTING is_db           TYPE any
                 RETURNING VALUE(rv_empty) TYPE rollname,

      show_filed_is_empty IMPORTING iv_rollname TYPE rollname.

  PRIVATE SECTION.
    DATA: t_low  TYPE tt_ref,
          t_high TYPE tt_ref.

    METHODS:
      _get_date_time IMPORTING it_refs TYPE tt_ref
                     EXPORTING ev_raw  TYPE string
                               ev_user TYPE string.
ENDCLASS.


CLASS lcl_ui_container IMPLEMENTATION.
  METHOD init_date_checker.
    t_low  = it_low.
    t_high = it_high.
  ENDMETHOD.

  METHOD is_date_ok.
    rv_ok = abap_true.

    _get_date_time( EXPORTING it_refs    = t_low
                    IMPORTING ev_raw    = DATA(lv_begda_raw)
                              ev_user   = DATA(lv_begda_user) ).

    _get_date_time( EXPORTING it_refs    = t_high
                    IMPORTING ev_raw    = DATA(lv_endda_raw)
                              ev_user   = DATA(lv_endda_user) ).

    CHECK lv_begda_raw IS NOT INITIAL AND lv_endda_raw IS NOT INITIAL.

    CHECK lv_begda_raw > lv_endda_raw.
    rv_ok = abap_false.
    MESSAGE s002(ztv_025) WITH lv_begda_user lv_endda_user DISPLAY LIKE 'E'.
  ENDMETHOD.

  METHOD _get_date_time.
    CLEAR: ev_raw,
           ev_user.

    LOOP AT it_refs INTO DATA(lr_ref).
      ASSIGN lr_ref->* TO FIELD-SYMBOL(<lv_value>).
      ev_raw = ev_raw && <lv_value>.

      DATA lv_buffer TYPE text10.
      WRITE <lv_value> TO lv_buffer.
      ev_user = ev_user && ` ` && lv_buffer.
    ENDLOOP.
    CONDENSE ev_user.
  ENDMETHOD.

  METHOD find_empty.
    DATA(lv_table_name) = cl_abap_structdescr=>describe_by_data( is_db )->get_relative_name( ).

    SELECT fieldname, rollname INTO TABLE @DATA(lt_field)
    FROM dd03l
    WHERE tabname EQ @lv_table_name
      AND keyflag NE 'X'
      AND domname NE 'XSDBOOLEAN' AND domname NE 'OS_BOOLEAN'.

    LOOP AT lt_field ASSIGNING FIELD-SYMBOL(<ls_field>).
      ASSIGN COMPONENT <ls_field>-fieldname OF STRUCTURE is_db TO FIELD-SYMBOL(<lv_field>).

      CHECK <lv_field> IS INITIAL.
      rv_empty = <ls_field>-rollname.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD show_filed_is_empty.
    SELECT SINGLE ddtext INTO @DATA(lv_text)
    FROM dd04t
    WHERE rollname   = @iv_rollname
      AND ddlanguage = @sy-langu
      AND as4local   = 'A'
      AND as4vers    = '0000'.
    MESSAGE |The field '{ lv_text }' is empty| TYPE 'S' DISPLAY LIKE 'E'.
  ENDMETHOD.


ENDCLASS.
