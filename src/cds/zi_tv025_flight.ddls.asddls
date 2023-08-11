@AbapCatalog.sqlViewName: 'zvitv025_flight'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight'
@VDM.viewType: #TRANSACTIONAL

@ObjectModel:{
        semanticKey: ['employee_number', 'trip_number', 's_index'],
        transactionalProcessingEnabled: true,
        writeActivePersistence: 'ZDTV025_FLIGHT',    // <--- Where to write
        
        //Enable the CRUD Activity
        createEnabled: true,
        deleteEnabled: true,
        updateEnabled: true
}

define view ZI_TV025_FLIGHT as select from zdtv025_flight as _Flight
  association [1..1] to ZI_TV025_ROOT as _root on _root.pernr        = _Flight.employee_number
                                              and _root.reinr        = _Flight.trip_number
                                              and _root.requestvrs   = _Flight.requestvrs
                                              and _root.plan_request = _Flight.plan_request

{    
    @UI: { lineItem: [  //Action Button
                       { type: #FOR_ACTION, position: 0, dataAction: 'BOPF:INVERSE_COPY',  label: 'Inverse copy' }] }
                       
    key employee_number,
    key trip_number,
    key s_index,
    key requestvrs,
    key plan_request,
    
    type,    
    agency,
    
    date_beg,    
    time_beg,
    
    date_end,    
    time_end,
    
    airport_beg,
    airport_end,
    
    price,    
    waers,
    
    comment1,
    approved_by,
    
    penalty,
    penalty_waers,
    ticket,
    transport,
    cancelled,
    penalty_box,
    
    @ObjectModel.association: {
          type: [ #TO_COMPOSITION_PARENT, #TO_COMPOSITION_ROOT ]
      }
    _root
}
