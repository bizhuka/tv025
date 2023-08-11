CLASS zcl_tv025_opt DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE

  GLOBAL FRIENDS zcl_aqo_option .

  PUBLIC SECTION.

    INTERFACES zif_aqo_ext .

    TYPES:
      BEGIN OF ts_dynnr,
        dynnr TYPE sydynnr,
        text  TYPE text100,
      END OF ts_dynnr .
    TYPES:
      BEGIN OF ts_screen,
        on          TYPE xsdboolean,
        dynnr       TYPE ts_dynnr-dynnr,
        name        TYPE zcl_eui_screen=>ts_customize-name,
        group1      TYPE zcl_eui_screen=>ts_customize-group1,
        req_typ     TYPE RANGE OF zss_tv025_head_ui-req_type,
        label       TYPE zcl_eui_screen=>ts_customize-label,
        input       TYPE zcl_eui_screen=>ts_customize-input,
        active      TYPE zcl_eui_screen=>ts_customize-active,
        required    TYPE zcl_eui_screen=>ts_customize-required,
        intensified TYPE zcl_eui_screen=>ts_customize-intensified,
        command     TYPE zcl_eui_screen=>ts_customize-command,
        desc        TYPE text100,
      END OF ts_screen.
    TYPES:
      BEGIN OF ts_file_opt,
        icon TYPE icon_d,
        ext  TYPE RANGE OF char4,
      END OF ts_file_opt .

    TYPES:
      BEGIN OF ts_cds_field,
        cds       TYPE ddlname,
        fieldname TYPE dd03l-fieldname,
        ddtext    TYPE dd04t-ddtext,
        required  TYPE xsdboolean,
      END OF ts_cds_field,
      tt_cds_field TYPE STANDARD TABLE OF ts_cds_field WITH EMPTY KEY.

    CONSTANTS:
      BEGIN OF mc_req_type,
        employee TYPE zss_tv025_head_ui-req_type VALUE 'E',
        visitor  TYPE zss_tv025_head_ui-req_type VALUE 'V',
      END OF mc_req_type .
    CLASS-DATA:
      r_super_user TYPE RANGE OF suid_st_bname-bname READ-ONLY .
    CLASS-DATA:
      t_dynnr      TYPE HASHED TABLE OF ts_dynnr WITH UNIQUE KEY dynnr READ-ONLY .
    CLASS-DATA:
      t_screen     TYPE SORTED TABLE OF ts_screen WITH NON-UNIQUE KEY dynnr name READ-ONLY .
    CLASS-DATA:
      t_file_opt   TYPE STANDARD TABLE OF ts_file_opt WITH DEFAULT KEY READ-ONLY .

    CLASS-DATA:
      t_cds_field   TYPE SORTED TABLE OF ts_cds_field WITH UNIQUE KEY cds fieldname READ-ONLY .

    CLASS-METHODS class_constructor .
    CLASS-METHODS get_customize
      IMPORTING
        !iv_dynnr           TYPE sydynnr
      RETURNING
        VALUE(rt_customize) TYPE zcl_eui_screen=>tt_customize .
    CLASS-METHODS is_super
      IMPORTING
        !iv_uname    TYPE uname
      RETURNING
        VALUE(rv_ok) TYPE abap_bool .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TV025_OPT IMPLEMENTATION.


  METHOD class_constructor.
    zcl_aqo_option=>create( NEW zcl_tv025_opt( ) ).
  ENDMETHOD.


  METHOD get_customize.
    DATA(lv_req_type) = COND #( WHEN zcl_tv025_model=>get_instance( )->is_visitor( )
                                THEN mc_req_type-visitor
                                ELSE mc_req_type-employee ).
    LOOP AT t_screen ASSIGNING FIELD-SYMBOL(<ls_screen>) WHERE dynnr = iv_dynnr
                                                           AND on    = abap_true.
      CHECK lv_req_type IN <ls_screen>-req_typ[].


      APPEND CORRESPONDING #( <ls_screen> ) TO rt_customize[].
    ENDLOOP.
  ENDMETHOD.


  METHOD is_super.
    rv_ok = xsdbool( r_super_user[] IS NOT INITIAL AND
                     iv_uname IN r_super_user[] ).
  ENDMETHOD.


  METHOD zif_aqo_ext~before_option_save.
    CHECK iv_in_editor = abap_true.

    " TODO update screen labels
    RETURN.

    CONSTANTS c_prog TYPE sycprog VALUE 'ZR_TV025_TRAVEL_ADMIN'.
    DATA(lt_updated_names) = VALUE string_table( ).

    DATA lt_d020s TYPE STANDARD TABLE OF d020s.
    CALL FUNCTION 'RS_SCREEN_LIST'
      EXPORTING
        dynnr    = ''
        progname = c_prog
      TABLES
        dynpros  = lt_d020s
      EXCEPTIONS
        OTHERS   = 2.
    CHECK sy-subrc = 0.

    DATA lt_screen LIKE REF TO t_screen.
    lt_screen ?= io_option->get_field_value( 'T_SCREEN' ).

    LOOP AT lt_screen->* ASSIGNING FIELD-SYMBOL(<ls_screen>) WHERE dynnr IS NOT INITIAL "#EC CI_SORTSEQ
                                                               AND name  NS '*'
                                                               AND label IS NOT INITIAL.
      CHECK line_exists( lt_d020s[ dnum = <ls_screen>-dynnr ] ).

      DATA(ls_header)               = VALUE rpy_dyhead( ).
      DATA(lt_containers)           = VALUE dycatt_tab( ).
      DATA(lt_fields_to_containers) = VALUE dyfatc_tab( ).
      DATA(lt_flow_logic)           = VALUE swydyflow( ).
      CALL FUNCTION 'RPY_DYNPRO_READ'
        EXPORTING
          progname             = c_prog
          dynnr                = <ls_screen>-dynnr
        IMPORTING
          header               = ls_header
        TABLES
          containers           = lt_containers
          fields_to_containers = lt_fields_to_containers
          flow_logic           = lt_flow_logic
        EXCEPTIONS
          OTHERS               = 4.
      CHECK sy-subrc = 0.

      ASSIGN lt_fields_to_containers[ name = <ls_screen>-name ] TO FIELD-SYMBOL(<ls_container>).
      CHECK sy-subrc = 0.
      <ls_container>-text = <ls_screen>-label.

      CALL FUNCTION 'RPY_DYNPRO_INSERT'
        EXPORTING
          header                = ls_header
          suppress_exist_checks = abap_true
        TABLES
          containers            = lt_containers
          fields_to_containers  = lt_fields_to_containers
          flow_logic            = lt_flow_logic
        EXCEPTIONS
          OTHERS                = 10.
      CHECK sy-subrc = 0.

      APPEND <ls_screen>-name TO lt_updated_names[].
    ENDLOOP.

    CHECK lt_updated_names IS NOT INITIAL.
    MESSAGE |Screens of { c_prog } regenerated. Delete labels from { concat_lines_of( table = lt_updated_names sep = `, `) }| TYPE 'I'.

    " TODO add
    " LIMU  CUAD  ZR_TV022_TRAVEL_ADMIN
    " to request
  ENDMETHOD.
ENDCLASS.
