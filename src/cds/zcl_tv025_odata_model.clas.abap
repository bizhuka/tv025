CLASS zcl_tv025_odata_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_child_table
      IMPORTING
        !iv_node_key    TYPE /bobf/obm_node_key
      RETURNING
        VALUE(rr_table) TYPE REF TO data .
    CLASS-METHODS get_root_child_association
      IMPORTING
        !iv_node_key        TYPE /bobf/obm_node_key
      RETURNING
        VALUE(rv_assoc_key) TYPE /bobf/obm_assoc_key .
    CLASS-METHODS define_model
      IMPORTING
        io_model TYPE REF TO /iwbep/if_mgw_odata_model
      RAISING
        /iwbep/cx_mgw_med_exception .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TV025_ODATA_MODEL IMPLEMENTATION.


  METHOD define_model.
    CHECK io_model IS NOT INITIAL.

*    io_model->get_entity_type( 'ZC_TV025_StatusType' )->get_property( 'Status' )->set_value_list(
*       /iwbep/if_mgw_odata_property=>gcs_value_list_type_property-fixed_values
*    ).

*    io_model->get_entity_type( 'ZC_TV025_AgencyType' )->set_creatable( abap_true ).
*    io_model->get_entity_type( 'ZC_TV025_AgencyType' )->set_updatable( abap_true ).

    io_model->get_entity_type( 'ZC_TV025_AttachType' )->set_is_media( abap_true ).
    io_model->get_entity_type( 'ZC_TV025_AttachType' )->get_property( 'pernr' )->set_as_content_type( ).
    io_model->get_entity_type( 'ZC_TV025_AttachType' )->get_property( 'reinr' )->set_as_content_type( ).
    io_model->get_entity_type( 'ZC_TV025_AttachType' )->get_property( 'doc_id' )->set_as_content_type( ).

    io_model->get_entity_type( 'ZC_TV025_ROOTType' )->set_updatable( abap_true ).

    io_model->get_entity_type( 'ZC_TV025_F4_Copy_FromType' )->set_is_media( abap_true ).
    io_model->get_entity_type( 'ZC_TV025_F4_Copy_FromType' )->get_property( 'pernr' )->set_as_content_type( ).
  ENDMETHOD.


  METHOD get_child_table.
    rr_table = SWITCH #( iv_node_key WHEN zif_i_tv025_root_c=>sc_node-zi_tv025_flight    THEN NEW ztitv025_flight( )
                                     WHEN zif_i_tv025_root_c=>sc_node-zi_tv025_hotel     THEN NEW ztitv025_hotel( )
                                     WHEN zif_i_tv025_root_c=>sc_node-zi_tv025_transport THEN NEW ztitv025_transport( ) ).
  ENDMETHOD.


  METHOD get_root_child_association.
    rv_assoc_key = SWITCH #( iv_node_key WHEN zif_i_tv025_root_c=>sc_node-zi_tv025_flight    THEN zif_i_tv025_root_c=>sc_association-zi_tv025_root-_flight
                                         WHEN zif_i_tv025_root_c=>sc_node-zi_tv025_hotel     THEN zif_i_tv025_root_c=>sc_association-zi_tv025_root-_hotel
                                         WHEN zif_i_tv025_root_c=>sc_node-zi_tv025_transport THEN zif_i_tv025_root_c=>sc_association-zi_tv025_root-_transport ).
  ENDMETHOD.
ENDCLASS.
