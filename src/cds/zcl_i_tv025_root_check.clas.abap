CLASS zcl_i_tv025_root_check DEFINITION
  PUBLIC
  INHERITING FROM /bobf/cl_lib_v_supercl_simple
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ts_required_field,
        fieldname TYPE dd03l-fieldname,
        ddtext    TYPE dd04t-ddtext,
      END OF ts_required_field,
      tt_required_field TYPE STANDARD TABLE OF ts_required_field WITH DEFAULT KEY.

    CLASS-METHODS get_required_fields IMPORTING iv_cds                   TYPE ddlname
                                                it_fieldname             TYPE fieldname_t OPTIONAL
                                      RETURNING VALUE(rt_required_field) TYPE tt_required_field.

    CLASS-METHODS check_required_fields
      IMPORTING is_root           TYPE any
                is_ctx            TYPE /bobf/s_frw_ctx_val
                io_message        TYPE REF TO /bobf/if_frw_message
                it_required_field TYPE tt_required_field
      CHANGING  ct_failed_key     TYPE /bobf/t_frw_key .

    METHODS constructor .

    METHODS /bobf/if_frw_validation~execute REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      mt_required_field TYPE tt_required_field.
ENDCLASS.



CLASS ZCL_I_TV025_ROOT_CHECK IMPLEMENTATION.


  METHOD /bobf/if_frw_validation~execute.
    " Called 2 times. Skip 1 of them
    CHECK is_ctx-val_time = 'CHECK_BEFORE_SAVE'.

    IF eo_message IS INITIAL.
      eo_message = /bobf/cl_frw_factory=>get_message( ).
    ENDIF.

    DATA(lt_root) = VALUE ztitv025_root( ).
    io_read->retrieve(
      EXPORTING iv_node       = is_ctx-node_key
                it_key        = it_key
                iv_fill_data  = abap_true
      IMPORTING et_data       = lt_root ).

    LOOP AT lt_root ASSIGNING FIELD-SYMBOL(<ls_root>).
      check_required_fields( EXPORTING is_root           = <ls_root>
                                       is_ctx            = is_ctx
                                       io_message        = eo_message
                                       it_required_field = mt_required_field
                             CHANGING  ct_failed_key     = et_failed_key ).

      IF <ls_root>-date_beg > <ls_root>-date_end.
        APPEND VALUE #( key = <ls_root>-key ) TO et_failed_key.
        MESSAGE e002(ztv_025) WITH <ls_root>-date_beg <ls_root>-date_end INTO sy-msgli.
        eo_message->add_message(
          is_msg       = CORRESPONDING #( sy )
          iv_node      = is_ctx-node_key
          iv_attribute = 'DATE_BEG'
        ).
      ENDIF.
    ENDLOOP.

*    ZCL_BOPF_MESSAGES=>raise_error( IV_MESSAGE = 'Nooooo' ).
  ENDMETHOD.


  METHOD check_required_fields.
    ASSIGN COMPONENT 'KEY' OF STRUCTURE is_root TO FIELD-SYMBOL(<lv_key>).
    ASSERT sy-subrc = 0.

    LOOP AT it_required_field ASSIGNING FIELD-SYMBOL(<ls_field>).
      ASSIGN COMPONENT <ls_field>-fieldname OF STRUCTURE is_root TO FIELD-SYMBOL(<lv_val>).
      CHECK <lv_val> IS INITIAL.

      APPEND VALUE #( key = <lv_key> ) TO ct_failed_key.

      MESSAGE e001(ztv_025) WITH <ls_field>-ddtext INTO sy-msgli.
      io_message->add_message(
        is_msg       = CORRESPONDING #( sy )
        iv_node      = is_ctx-node_key
        "iv_key       = is_root-key
        iv_attribute = CONV #( <ls_field>-fieldname )
      ).
    ENDLOOP.
  ENDMETHOD.


  METHOD constructor.
    super->constructor( ).
    mt_required_field = VALUE #(
      ( fieldname = 'PERNR'           ddtext = |Visitor ID| )
      ( fieldname = 'DATE_BEG'        ddtext = |Begins On| )
      ( fieldname = 'DATE_END'        ddtext = |Ends On| )
      ( fieldname = 'ACTIVITY_TYPE'   ddtext = |Trip Activity Type| )
      ( fieldname = 'LOCATION_END'    ddtext = |Destination| )
      ( fieldname = 'COUNTRY_END'     ddtext = |Country| )
      ( fieldname = 'REQUEST_REASON'  ddtext = |Reason| ) ) .
  ENDMETHOD.


  METHOD get_required_fields.
    DATA(lt_fieldname) = it_fieldname[].
    SELECT attribute_name APPENDING TABLE @lt_fieldname
    FROM /bobf/obm_propty
    WHERE name           EQ @iv_cds
      AND property_name  EQ 'M' AND property_value EQ 'X' " Mandatory
      AND extension      EQ ''
      AND version        EQ 00000.
    IF sy-subrc <> 0.
      " Read annotations
      SELECT lfieldname APPENDING TABLE @lt_fieldname
      FROM ddfieldanno
      WHERE strucobjn EQ @iv_cds
        AND name      EQ 'OBJECTMODEL.MANDATORY'
        AND value     EQ 'true'.
    ENDIF.

    SELECT SINGLE objectname INTO @DATA(lv_table_name)
    FROM ddldependency
    WHERE ddlname    = @iv_cds
      AND state      = 'A'
      AND objecttype = 'VIEW'.
    CHECK sy-subrc = 0.

    SELECT d~fieldname, t~ddtext INTO TABLE @rt_required_field
    FROM dd03l AS d INNER JOIN dd04t AS t ON t~rollname   EQ d~rollname
                                         AND t~ddlanguage EQ @sy-langu
                                         AND t~as4local   EQ 'A'
                                         AND t~as4vers    EQ '0000'
    FOR ALL ENTRIES IN @lt_fieldname
    WHERE d~tabname    EQ @lv_table_name
      AND d~fieldname  EQ @lt_fieldname-table_line.
  ENDMETHOD.
ENDCLASS.
