CLASS zcl_v_tv025_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_sadl_exit .
    INTERFACES zif_sadl_stream_runtime .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_V_TV025_REPORT IMPLEMENTATION.


  METHOD zif_sadl_stream_runtime~create_stream.
    MESSAGE 'Not allowed' TYPE 'X'.
  ENDMETHOD.


  METHOD zif_sadl_stream_runtime~get_stream.
    CHECK io_tech_request_context IS NOT INITIAL
      AND io_tech_request_context IS INSTANCE OF /iwbep/cl_mgw_request.

    DATA(lv_filter) = lcl_request=>get_filter( CAST #( io_tech_request_context ) ).
    DATA(lo_xtt)    = NEW zcl_tv025_report( lv_filter )->get_xtt( ).

    io_srv_runtime->set_header(
         VALUE #( name  = 'Content-Disposition'
                  value = |attachment; filename="ZTV_025_REPORT.XLSX"| ) ).

    " Any binary file
    er_stream = NEW /iwbep/cl_mgw_abs_data=>ty_s_media_resource(
      value     = lo_xtt->get_raw( )
      mime_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ).



  ENDMETHOD.
ENDCLASS.
