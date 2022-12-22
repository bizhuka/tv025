*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_request DEFINITION INHERITING FROM /iwbep/cl_mgw_request FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      get_filter IMPORTING io_request       TYPE REF TO /iwbep/cl_mgw_request
                 RETURNING VALUE(rv_filter) TYPE string.
ENDCLASS.

CLASS lcl_request IMPLEMENTATION.
  METHOD get_filter.
    rv_filter = io_request->mo_filter->get_filter_string( ).
  ENDMETHOD.
ENDCLASS.
