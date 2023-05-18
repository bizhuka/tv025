class ZCL_ZC_TV025_ROOT definition
  public
  inheriting from CL_SADL_GTK_EXPOSURE_MPC
  final
  create public .

public section.
protected section.

  methods GET_PATHS
    redefinition .
  methods GET_TIMESTAMP
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZC_TV025_ROOT IMPLEMENTATION.


  method GET_PATHS.
et_paths = VALUE #(
( `CDS~ZC_TV025_ROOT` )
).
  endmethod.


  method GET_TIMESTAMP.
RV_TIMESTAMP = 20230517061759.
  endmethod.
ENDCLASS.
