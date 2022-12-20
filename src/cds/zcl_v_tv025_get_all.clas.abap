class ZCL_V_TV025_GET_ALL definition
  public
  final
  create public .

public section.

  interfaces ZIF_SADL_EXIT .
  interfaces ZIF_SADL_PREPARE_READ_RUNTIME .
  interfaces ZIF_SADL_PREPARE_BATCH .
  interfaces ZIF_SADL_READ_RUNTIME .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_V_TV025_GET_ALL IMPLEMENTATION.


  METHOD zif_sadl_prepare_batch~prepare.
    LOOP AT ct_create ASSIGNING FIELD-SYMBOL(<ls_create>) WHERE source-association_name CP 'TO_FAKE*'.
      CLEAR <ls_create>-source-association_name.
      <ls_create>-source-entity_id = <ls_create>-entity_id.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_sadl_prepare_read_runtime~change_condition.
    CHECK iv_where CP `*^TO_FAKE*\CDS_ZC_TV025_ROOT*`.
    CLEAR ct_sadl_condition[].
  ENDMETHOD.


  METHOD zif_sadl_read_runtime~execute.
    IF iv_node_name = 'ZC_TV025_FakeVisitor' AND ct_data_rows[] IS INITIAL AND zcl_d_tv025_visitor_save=>created_visitor IS NOT INITIAL.
      APPEND INITIAL LINE TO ct_data_rows ASSIGNING FIELD-SYMBOL(<ls_row>).
      MOVE-CORRESPONDING zcl_d_tv025_visitor_save=>created_visitor TO <ls_row>.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
