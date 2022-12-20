CLASS zcl_zc_tv025_root DEFINITION
  PUBLIC
  INHERITING FROM cl_sadl_gtk_exposure_mpc
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS define
        REDEFINITION .
  PROTECTED SECTION.

    METHODS get_paths
        REDEFINITION .
    METHODS get_timestamp
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZC_TV025_ROOT IMPLEMENTATION.


  METHOD define.
    super->define( ).
    zcl_tv025_odata_model=>define_model( model ).
  ENDMETHOD.


  METHOD get_paths.
    et_paths = VALUE #(
    ( `CDS~ZC_TV025_ROOT` )
    ).
  ENDMETHOD.


  METHOD get_timestamp.
    rv_timestamp = 20221220021038.
  ENDMETHOD.
ENDCLASS.
