class ZCL_V_TV025_ATTACH definition
  public
  final
  create public .

public section.

  interfaces ZIF_SADL_EXIT .
  interfaces ZIF_SADL_DELETE_RUNTIME .
  interfaces ZIF_SADL_READ_RUNTIME .
  interfaces ZIF_SADL_STREAM_RUNTIME .

  types:
    tt_attach_alv TYPE STANDARD TABLE OF zdtv025_attach_d WITH DEFAULT KEY .

  methods SET_KEY
    importing
      !IS_DB_KEY type ZCL_TV025_MODEL=>TS_DB_KEY
    returning
      value(RO_ATTACH) type ref to ZCL_V_TV025_ATTACH .
  methods ADD_FILE
    importing
      !IV_FILE_NAME type STRING
      !IV_FILE_CONTENT type XSTRING
    returning
      value(RV_OK) type ABAP_BOOL
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION .
  methods READ
    exporting
      !ET_SIGNATURE type SBDST_SIGNATURE
      !ET_ATTACH_ALV type TT_ATTACH_ALV .
  methods GET_FILE_CONTENT
    importing
      !IS_OBJ_KEY type SDOKOBJECT
    exporting
      !EV_FILETYPE type CHAR10
      !EV_CONTENT type XSTRING .
  PROTECTED SECTION.
private section.

  constants:
    BEGIN OF ms_oaor,
        name           TYPE bapibds01-classname VALUE 'ZTV_025_ATTACH',
        type           TYPE bapibds01-classtype VALUE 'OT',
        expense_pdf    TYPE bds_docid VALUE 'EXPENSE_PDF',
      END OF ms_oaor .
  data MV_ATTACH_KEY type SWOTOBJID-OBJKEY .
  data MS_DB_KEY type ZCL_TV025_MODEL=>TS_DB_KEY .

  methods _CHECK_IS_ALREADY_EXISTS
    importing
      !IV_FILENAME type CSEQUENCE
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION .
  methods _GET_FILE_SIZE_TXT
    importing
      !IV_SIZE type BDS_COMPSI
    returning
      value(RV_TEXT) type STRING .
  methods _GET_EXPENSE_PDF
    returning
      value(RV_PDF) type XSTRING .
ENDCLASS.



CLASS ZCL_V_TV025_ATTACH IMPLEMENTATION.


  METHOD add_file.
    DATA(lv_file_name) = ||.
    DATA(lv_file_ext)  = ||.
    zcl_eui_file=>split_file_path( EXPORTING iv_fullpath  = iv_file_name
                                   IMPORTING ev_filename  = lv_file_name
                                             ev_extension = lv_file_ext ).
    _check_is_already_exists( lv_file_name ).

    TRY.
        DATA(lt_bindata) = VALUE sbdst_content( ).
        cl_bcs_convert=>xstring_to_xtab(
         EXPORTING iv_xstring = iv_file_content
         IMPORTING et_xtab    = lt_bindata ).
      CATCH cx_bcs INTO DATA(lo_exception).
        MESSAGE lo_exception TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    DATA(lt_signature) = VALUE sbdst_signature(
     ( prop_name  = 'DESCRIPTION'
       prop_value = to_lower( lv_file_name )
       doc_count  = 1 doc_ver_no = 1 doc_var_id = 1 )

     ( prop_name  = 'BDS_DOCUMENTCLASS'
       prop_value = to_upper( lv_file_ext )
       doc_count  = 1 doc_ver_no = 1 doc_var_id = 1 ) ).

    DATA(lv_attach_key) = me->mv_attach_key.
    cl_bds_document_set=>create_with_table(
      EXPORTING  classname       = ms_oaor-name
                 classtype       = ms_oaor-type
                 components      = VALUE sbdst_components( (
                                      comp_id    = lv_file_name
                                      comp_size  = xstrlen( iv_file_content )
                                      doc_count  = 1 comp_count = 1 ) )
                 content         = lt_bindata
      CHANGING   object_key      = lv_attach_key
                 signature       = lt_signature
      EXCEPTIONS OTHERS          = 7 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_error_msg).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_unlimited = lv_error_msg.
      RETURN.
    ENDIF.

    rv_ok = abap_true.
  ENDMETHOD.


  METHOD get_file_content.
    CLEAR: ev_filetype,
           ev_content.

    DATA lt_info      TYPE STANDARD TABLE OF sdokfilaci.
    DATA lt_text      TYPE STANDARD TABLE OF sdokcntasc.
    DATA lt_bin       TYPE STANDARD TABLE OF sdokcntbin.
    CALL FUNCTION 'SDOK_PHIO_LOAD_CONTENT'
      EXPORTING
        object_id           = is_obj_key
        text_as_stream      = abap_true
      TABLES
        file_access_info    = lt_info
        file_content_ascii  = lt_text
        file_content_binary = lt_bin
      EXCEPTIONS
        OTHERS              = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    " Text or binary
    FIELD-SYMBOLS <lt_table> TYPE STANDARD TABLE.
    IF lt_bin[] IS NOT INITIAL.
      ASSIGN lt_bin TO <lt_table>.
      ev_filetype  = CONV char10( 'BIN' ).
      DATA(lv_file_size) = CONV i( lt_info[ 1 ]-file_size ).
    ELSE.
      ASSIGN lt_text TO <lt_table>.
      ev_filetype  = 'ASC'.
    ENDIF.

    ev_content = zcl_eui_conv=>binary_to_xstring( it_table  = <lt_table>
                                                  iv_length = lv_file_size ).
  ENDMETHOD.


  METHOD read.
    CLEAR: et_signature,
           et_attach_alv.
    cl_bds_document_set=>get_info(
         EXPORTING      classname           = ms_oaor-name
                        classtype           = ms_oaor-type
                        object_key          = mv_attach_key
         IMPORTING      extended_components = DATA(lt_component)
         CHANGING       signature           = et_signature
         EXCEPTIONS     OTHERS              = 1 ).
    CHECK sy-subrc = 0
      AND et_attach_alv IS REQUESTED.

    LOOP AT et_signature ASSIGNING FIELD-SYMBOL(<ls_signature>).
      AT NEW doc_id.
        ASSIGN lt_component[ <ls_signature>-doc_count ] TO FIELD-SYMBOL(<ls_component>).
        APPEND VALUE #( file_name  = <ls_component>-file_name
                        file_size  = _get_file_size_txt( <ls_component>-file_size )
                        _oaor_id   = VALUE #( class = <ls_component>-class
                                              objid = <ls_component>-objid )
                        doc_id     = <ls_signature>-doc_id
                   ) TO et_attach_alv ASSIGNING FIELD-SYMBOL(<ls_attach>).
        MOVE-CORRESPONDING ms_db_key TO <ls_attach>.
      ENDAT.
      "APPEND <ls_signature> TO <ls_attach>-t_signature.

      CASE <ls_signature>-prop_name.
        WHEN 'CREATED_AT'.
          <ls_attach>-created_at_date = <ls_signature>-prop_value(8).
          <ls_attach>-created_at_time = CONV t( <ls_signature>-prop_value+8 ) + sy-tzone.
        WHEN 'CREATED_BY'.
          <ls_attach>-created_by     = <ls_signature>-prop_value.
          <ls_attach>-created_by_txt = zcl_tv025_model=>get_instance( )->get_user_ename( <ls_attach>-created_by ).
        WHEN 'BDS_DOCUMENTCLASS'.
          LOOP AT zcl_tv025_opt=>t_file_opt ASSIGNING FIELD-SYMBOL(<ls_file_opt>).
            CHECK to_upper( <ls_signature>-prop_value ) IN <ls_file_opt>-ext[].
            <ls_attach>-icon = <ls_file_opt>-icon.
            EXIT.
          ENDLOOP.
        WHEN OTHERS.
          ASSIGN COMPONENT <ls_signature>-prop_name OF STRUCTURE <ls_attach> TO FIELD-SYMBOL(<l_val>).
          CHECK sy-subrc = 0.
          <l_val> = <ls_signature>-prop_value.
      ENDCASE.
    ENDLOOP.

    SORT et_attach_alv BY created_at_date DESCENDING
                          created_at_time DESCENDING.
    LOOP AT et_attach_alv ASSIGNING <ls_attach>.
      <ls_attach>-s_index = lines( et_attach_alv ) - sy-tabix + 1.
    ENDLOOP.
  ENDMETHOD.


  METHOD set_key.
    ms_db_key = is_db_key.

    " as OAOR key
    DATA(lt_parts) = VALUE string_table( ( condense( |{ ms_db_key-pernr ALPHA = OUT  }| ) )
                                         ( condense( |{ ms_db_key-reinr ALPHA = OUT  }| ) ) ).
    mv_attach_key = concat_lines_of( table = lt_parts sep = `-` ).

    " For chain calls
    ro_attach = me.
  ENDMETHOD.


  METHOD zif_sadl_delete_runtime~execute.
    DATA(ls_prev_key) = VALUE zcl_tv025_model=>ts_db_key( ).

    LOOP AT it_key_values ASSIGNING FIELD-SYMBOL(<ls_value>).
      DATA(ls_key)    = CORRESPONDING zcl_tv025_model=>ts_db_key( <ls_value> ).
      DATA(ls_attach) = CORRESPONDING zdtv025_attach_d( <ls_value> ).

      " Get signature for all files
      IF ls_prev_key <> ls_key.
        set_key( ls_key ).
        ls_prev_key = ls_key.
        read( IMPORTING et_signature = DATA(lt_signature) ).
      ENDIF.

      DATA(lt_1_signature) = VALUE sbdst_signature(
       FOR ls_part IN lt_signature WHERE ( doc_id = ls_attach-doc_id ) ( ls_part ) ).
      cl_bds_document_set=>delete(
            EXPORTING  classname      = ms_oaor-name
                       classtype      = ms_oaor-type
                       object_key     = mv_attach_key
                       x_force_delete = abap_true
            CHANGING   signature      = lt_1_signature
            EXCEPTIONS OTHERS         = 1 ).
      CHECK sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_error).
      TRY.
          zcx_eui_no_check=>raise_sys_error( iv_message = lv_error ).
        CATCH zcx_eui_no_check INTO DATA(lo_error).
          RAISE EXCEPTION TYPE cx_sadl_gw_annotation
            EXPORTING
              previous = lo_error.
      ENDTRY.

      RETURN.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_sadl_read_runtime~execute.
    CLEAR ct_data_rows[].

    IF it_range[] IS NOT INITIAL.
      DATA(ls_attach) = VALUE zdtv025_attach_d( ).
      LOOP AT it_range ASSIGNING FIELD-SYMBOL(<ls_range>).
        ASSIGN COMPONENT <ls_range>-column_name OF STRUCTURE ls_attach TO FIELD-SYMBOL(<lv_value>).
        <lv_value> = <ls_range>-t_selopt[ 1 ]-low.
      ENDLOOP.

      DATA(ls_key) = CORRESPONDING zcl_tv025_model=>ts_db_key( ls_attach ).
    ELSEIF iv_where IS NOT INITIAL.
      SELECT SINGLE pernr, reinr INTO CORRESPONDING FIELDS OF @ls_key
      FROM zi_tv025_root
      WHERE (iv_where).
    ENDIF.

    set_key( ls_key )->read( IMPORTING et_attach_alv = DATA(lt_alv) ).

    cl_http_server=>if_http_server~get_location(
      IMPORTING host         = DATA(lv_host)
                port         = DATA(lv_port)
                out_protocol = DATA(lv_protocol) ).
    LOOP AT lt_alv ASSIGNING FIELD-SYMBOL(<ls_alv>).
      <ls_alv>-doc_url = |{ lv_protocol }://{ lv_host }:{ lv_port }/sap/opu/odata/sap/ZC_TV025_ROOT_CDS/ZC_TV025_Attach(pernr='{ <ls_alv>-pernr
         }',reinr='{ <ls_alv>-reinr }',doc_id='{ <ls_alv>-doc_id }')/$value|.
    ENDLOOP.


    IF ls_attach-doc_id IS NOT INITIAL.
      DELETE lt_alv WHERE doc_id <> ls_attach-doc_id.
      " Select SINGLE by key fields
      cv_number_all_hits = lines( lt_alv ).
    ENDIF.

    MOVE-CORRESPONDING lt_alv TO ct_data_rows[].
  ENDMETHOD.


  METHOD zif_sadl_stream_runtime~create_stream.
    DATA(ls_db_key) = VALUE zcl_tv025_model=>ts_db_key( ).
    SPLIT iv_slug AT `|` INTO ls_db_key-pernr
                              ls_db_key-reinr
                              DATA(lv_file_name).
    set_key( ls_db_key ).

    add_file( iv_file_content = is_media_resource-value
              iv_file_name    = lv_file_name ).


*    io_srv_runtime->set_header(
*      VALUE #( name  = 'ok-message'
*               value = |File "{ escape( val = lv_file_name format = cl_abap_format=>e_url ) }" uploaded| ) ).
*    er_entity = NEW /iwbep/cl_mgw_abs_data=>ty_s_media_resource( is_media_resource ).

    er_entity = NEW zdtv025_attach_d(
     pernr     = ls_db_key-pernr
     reinr     = ls_db_key-reinr
     doc_id    = ''
     message   = |File "{ lv_file_name }" uploaded|
    ).
  ENDMETHOD.


  METHOD zif_sadl_stream_runtime~get_stream.
    DATA(ls_attach) = VALUE zdtv025_attach_d( ).
    LOOP AT it_key_tab ASSIGNING FIELD-SYMBOL(<ls_key>).
      ASSIGN COMPONENT <ls_key>-name OF STRUCTURE ls_attach TO FIELD-SYMBOL(<lv_value>).
      <lv_value> = <ls_key>-value.
    ENDLOOP.

    " Info about all files
    set_key( CORRESPONDING zcl_tv025_model=>ts_db_key( ls_attach ) ).

    IF ls_attach-doc_id = ms_oaor-expense_pdf.
      DATA(lv_content)   = _get_expense_pdf( ).
      DATA(lv_mime_type) = |application/pdf|.
      io_srv_runtime->set_header(
           VALUE #( name  = 'Content-Disposition'
                    value = |outline; filename="expense.pdf"| ) ).
    ELSE.
      lv_mime_type = |application/binary|.
      read( IMPORTING et_attach_alv = DATA(lt_alv) ).
      " Get full info about file
      ASSIGN lt_alv[ doc_id = ls_attach-doc_id ] TO FIELD-SYMBOL(<ls_alv>).
      CHECK sy-subrc = 0.

      io_srv_runtime->set_header(
           VALUE #( name  = 'Content-Disposition'
                    value = |outline; filename="{ escape( val    = <ls_alv>-file_name
                                                          format = cl_abap_format=>e_url ) }"| ) ).
      get_file_content( EXPORTING is_obj_key = <ls_alv>-_oaor_id
                        IMPORTING ev_content = lv_content ).
    ENDIF.

    " Any binary file
    er_stream = NEW /iwbep/cl_mgw_abs_data=>ty_s_media_resource(
      value     = lv_content
      mime_type =  lv_mime_type ).
  ENDMETHOD.


  METHOD _check_is_already_exists.
    read( IMPORTING et_attach_alv = DATA(lt_alv) ).

    LOOP AT lt_alv ASSIGNING FIELD-SYMBOL(<ls_attach>).
      CHECK to_lower( <ls_attach>-file_name ) = to_lower( iv_filename ).

      DATA(lv_message) = |Delete '{ iv_filename }' file first. Since is already exists. Index { <ls_attach>-s_index }|.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_unlimited = lv_message.
    ENDLOOP.
  ENDMETHOD.


  METHOD _get_expense_pdf.
    DATA(lt_return) = VALUE bapirettab( ).
    CALL FUNCTION 'PTRM_WEB_FORM_PDF_GET'
      EXPORTING
        i_employeenumber = ms_db_key-pernr
        i_tripnumber     = ms_db_key-reinr
        i_display_form   = ' '
      IMPORTING
        e_pdf_form       = rv_pdf
      TABLES
        et_return        = lt_return.
  ENDMETHOD.


  METHOD _get_file_size_txt.
    DATA(lt_text) = VALUE string_table( ( |B| )
                                        ( |kB| )
                                        ( |MB| )
                                        ( |GB| )
                                        ( |TB| )
                                        ).
    DATA(lv_size) = CONV decfloat34( iv_size ).
    LOOP AT lt_text ASSIGNING FIELD-SYMBOL(<lv_text>).
      IF lv_size < 1024.
        rv_text = |{ lv_size DECIMALS = 1 WIDTH = 7 } { <lv_text> }|.
        RETURN.
      ENDIF.

      lv_size = lv_size / 1024.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
