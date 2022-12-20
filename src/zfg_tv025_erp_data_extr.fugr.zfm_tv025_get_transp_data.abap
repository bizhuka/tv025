FUNCTION zfm_tv025_get_transp_data.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_DATE_FROM) TYPE  BEGDA
*"     VALUE(I_DATE_TO) TYPE  ENDDA
*"  EXPORTING
*"     VALUE(ET_TRANSPORT) TYPE  ZTT_TV025_TRAVEL_EXTRACT_ERP
*"----------------------------------------------------------------------

  et_transport = NEW zcl_tv025_transp_extractor( VALUE #( begda = i_date_from
                                                          endda = i_date_to )
                 )->get_data( ).
ENDFUNCTION.
