@AbapCatalog.sqlViewName: 'zvitv025_hotel'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hotel'
@VDM.viewType: #TRANSACTIONAL


@ObjectModel:{
    semanticKey: ['employee_number', 'trip_number', 's_index'],
    transactionalProcessingEnabled: true,
    writeActivePersistence: 'ZDTV025_HOTEL',    // <--- Where to write
    
    //Enable the CRUD Activity
    createEnabled: true,
    deleteEnabled: true,
    updateEnabled: true
}

define view ZI_TV025_HOTEL as select from zdtv025_hotel as _Hotel
  association [1..1] to ZI_TV025_ROOT as _root on _root.pernr        = _Hotel.employee_number
                                              and _root.reinr        = _Hotel.trip_number
                                              and _root.requestvrs   = _Hotel.requestvrs
                                              and _root.plan_request = _Hotel.plan_request
{    
    key employee_number,
    key trip_number,
    key s_index,
    key requestvrs,
    key plan_request,
    
    agency,
    early_check_in,
    later_check_out,
    date_beg,
    date_end,
    
    hotel_end,
    
    assigned_car,
    type_car,
    transport_price,
    transport_waers,
    transport_airport,
    transport_hotel,
    comment1,
    

    price,
    waers,
    
    penalty,
    penalty_waers,
    booked_nights,
    basis,
    penalty_check,
    
    @ObjectModel.association: {
          type: [ #TO_COMPOSITION_PARENT, #TO_COMPOSITION_ROOT ]
      }
    _root
}
