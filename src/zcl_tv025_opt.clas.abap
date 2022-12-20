class ZCL_TV025_OPT definition
  public
  final
  create private

  global friends ZCL_AQO_OPTION .

public section.

  interfaces ZIF_AQO_EXT .

  types:
    begin of ts_dynnr,
        dynnr type sydynnr,
        text  type text100,
      end of ts_dynnr .
  types:
    begin of ts_screen,
        on          type xsdboolean,
        dynnr       type ts_dynnr-dynnr,
        name        type zcl_eui_screen=>ts_customize-name,
        group1      type zcl_eui_screen=>ts_customize-group1,
        req_typ     type range of zss_tv025_head_ui-req_type,
        label       type zcl_eui_screen=>ts_customize-label,
        input       type zcl_eui_screen=>ts_customize-input,
        active      type zcl_eui_screen=>ts_customize-active,
        required    type zcl_eui_screen=>ts_customize-required,
        intensified type zcl_eui_screen=>ts_customize-intensified,
        command     type zcl_eui_screen=>ts_customize-command,
        desc        type text100,
      end of ts_screen .
  types:
    begin of ts_file_opt,
        icon type icon_d,
        ext  type range of char4,
      end of ts_file_opt .

  constants:
    begin of mc_req_type,
        employee type zss_tv025_head_ui-req_type value 'E',
        visitor  type zss_tv025_head_ui-req_type value 'V',
      end of mc_req_type .
  class-data:
    r_super_user type range of suid_st_bname-bname read-only .
  class-data:
    t_dynnr      type hashed table of ts_dynnr with unique key dynnr read-only .
  class-data:
    t_screen     type sorted table of ts_screen with non-unique key dynnr name read-only .
  class-data:
    t_file_opt   type standard table of ts_file_opt with default key read-only .

  class-methods CLASS_CONSTRUCTOR .
  class-methods GET_CUSTOMIZE
    importing
      !IV_DYNNR type SYDYNNR
    returning
      value(RT_CUSTOMIZE) type ZCL_EUI_SCREEN=>TT_CUSTOMIZE .
  class-methods IS_SUPER
    importing
      !IV_UNAME type UNAME
    returning
      value(RV_OK) type ABAP_BOOL .
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

    LOOP AT lt_screen->* ASSIGNING FIELD-SYMBOL(<ls_screen>) WHERE dynnr IS NOT INITIAL   "#EC CI_SORTSEQ
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
