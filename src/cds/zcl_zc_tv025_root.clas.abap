class ZCL_ZC_TV025_ROOT definition
  public
  inheriting from CL_SADL_GTK_EXPOSURE_MPC
  final
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.

  methods GET_PATHS
    redefinition .
  methods GET_TIMESTAMP
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZC_TV025_ROOT IMPLEMENTATION.


METHOD define.
  super->define( ).
  zcl_tv025_odata_model=>define_model( model ).
ENDMETHOD.


  method GET_PATHS.
et_paths = VALUE #(
( `CDS~ZC_TV025_ROOT` )
).
  endmethod.


  method GET_TIMESTAMP.
RV_TIMESTAMP = 20221222030903.
  endmethod.
ENDCLASS.
