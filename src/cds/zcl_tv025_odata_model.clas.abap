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

    io_model->get_entity_type( 'ZC_TV025_AttachType' )->set_is_media( abap_true ).
    io_model->get_entity_type( 'ZC_TV025_AttachType' )->get_property( 'pernr' )->set_as_content_type( ).

*    io_model->get_entity_type( 'ZC_TV025_ROOTType' )->set_updatable( abap_true ).

    io_model->get_entity_type( 'ZC_TV025_F4_Copy_FromType' )->set_is_media( abap_true ).
    io_model->get_entity_type( 'ZC_TV025_F4_Copy_FromType' )->get_property( 'pernr' )->set_as_content_type( ).

**********************************************************************
    DATA(lc_fixed_values) = /iwbep/if_mgw_odata_property=>gcs_value_list_type_property-fixed_values.

    io_model->get_entity_type( 'ZC_TV025_StatusType' )->get_property( 'Status' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_TV025_ROOTType' )->get_property( 'zz_status' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_TV025_F4_Copy_FromType' )->get_property( 'zz_status' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'ZC_TV025_ActivityTypeType' )->get_property( 'Activity' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_TV025_ROOTType' )->get_property( 'activity_type' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_TV025_F4_Copy_FromType' )->get_property( 'activity_type' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'ZC_TV025_AgencyType' )->get_property( 'agency_id' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_TV025_FLIGHTType' )->get_property( 'agency' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_TV025_HOTELType' )->get_property( 'agency' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'ZC_TV025_FlightTypeType' )->get_property( 'Id' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_TV025_FLIGHTType' )->get_property( 'type' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'ZC_TV025_ApprovedByType' )->get_property( 'id' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_TV025_FLIGHTType' )->get_property( 'approved_by' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'ZC_TV025_TypeCarType' )->get_property( 'id' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_TV025_HOTELType' )->get_property( 'type_car' )->set_value_list( lc_fixed_values ).

    io_model->get_entity_type( 'ZC_TV025_BasisType' )->get_property( 'basis_id' )->set_value_list( lc_fixed_values ).
    io_model->get_entity_type( 'ZC_TV025_HOTELType' )->get_property( 'basis' )->set_value_list( lc_fixed_values ).
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
