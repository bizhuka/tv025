@AbapCatalog.sqlViewName: 'zvctv025_flight'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight consuption'
@VDM.viewType: #CONSUMPTION

// BOPF sub
@ObjectModel:{
    semanticKey: ['employee_number', 'trip_number', 's_index' ],
    
    //Delegate the CRUD
    transactionalProcessingDelegated: true,
  
    //To define what all actions are enabled
    createEnabled: true,
    deleteEnabled: true,
    updateEnabled: true
}


define view ZC_TV025_FLIGHT as select from ZI_TV025_FLIGHT as _Flight

association [0..1] to ZC_TV025_FlightType as _FlightType on _FlightType.Id = _Flight.type
association [0..1] to ZC_TV025_Agency as _Agency on _Agency.agency_id = _Flight.agency

association [0..1] to ZC_TV025_Airport as _AirportBeg on _AirportBeg.airport_id = _Flight.airport_beg
association [0..1] to ZC_TV025_Airport as _AirportEnd on _AirportEnd.airport_id = _Flight.airport_end

association [0..1] to ZC_PY000_Currency as _Currency    on _Currency.waers = _Flight.waers
association [0..1] to ZC_PY000_Currency as _CurrencyPen on _CurrencyPen.waers = _Flight.penalty_waers

association [0..1] to ZC_TV025_ApprovedBy as _ApprovedBy on _ApprovedBy.id = _Flight.approved_by

{    
    key employee_number,
    key trip_number,
    key s_index,
    
    @UI.lineItem: [{ position: 10, label: 'Start Date' }]
    @UI.fieldGroup: [{ qualifier: 'Departure', position: 20 }]    
    date_beg,    
//    @UI.fieldGroup: [{ qualifier: 'Departure', position: 30 }]
    @UI.hidden 
    time_beg,
    
    
/////////////////////////////////////////////////////////////////////////////////
    @UI.lineItem: [{ position: 20, label: 'From' }]
    @UI.fieldGroup: [{ qualifier: 'Departure', position: 10 }]
    @EndUserText.label: 'Departure'   
    @ObjectModel.text.element: ['AirportNameBeg']  
    @Consumption.valueHelp: '_AirportBeg'
    airport_beg,      
    @ObjectModel:{ readOnly: true }
    @UI.hidden 
    _AirportBeg.airport_name as AirportNameBeg,
    
    @ObjectModel:{ readOnly: true }
    @UI.hidden 
    _AirportBeg.latitude as beg_latitude,
    
    @ObjectModel:{ readOnly: true }
    @UI.hidden 
    _AirportBeg.longitude as beg_longitude,
    
/////////////////////////////////////////////////////////////////////////////////
    @UI.lineItem: [{ position: 30, label: 'To' }]
    @UI.fieldGroup: [{ qualifier: 'Arrival', position: 10 }]
    @EndUserText.label: 'Arrival'    
    @ObjectModel.text.element: ['AirportNameEnd']
    @Consumption.valueHelp: '_AirportEnd'
    airport_end,  
    @ObjectModel:{ readOnly: true }
    @UI.hidden 
    _AirportEnd.airport_name as AirportNameEnd,
    
    @ObjectModel:{ readOnly: true }
    @UI.hidden 
    _AirportEnd.latitude as end_latitude,
    
    @ObjectModel:{ readOnly: true }
    @UI.hidden 
    _AirportEnd.longitude as end_longitude,
/////////////////////////////////////////////////////////////////////////////////
    @UI.lineItem: [{ position: 40, label: 'End Date' }]
    @UI.fieldGroup: [{ qualifier: 'Arrival', position: 20 }]
    date_end,    
//    @UI.fieldGroup: [{ qualifier: 'Arrival', position: 30 }]
    @UI.hidden 
    time_end,
    
    @UI.lineItem: [{ position: 50 }]
    @UI.fieldGroup: [{ qualifier: 'Ticket', position: 10 }]
    ticket,   
    
    @UI.lineItem: [{ position: 60 }]
    @UI.fieldGroup: [{ qualifier: 'FlightGroup', position: 20 }]    
    @ObjectModel.text.element: ['agency_name']
    @Consumption.valueHelp: '_Agency'
    @EndUserText.label: 'Agency'
    agency,
    @ObjectModel:{ readOnly: true }
    @UI.hidden 
    _Agency.agency_name,
    
    @UI.lineItem: [{ position: 70, label: 'Ticket class', importance: #HIGH }]
    @UI.fieldGroup: [{ qualifier: 'FlightGroup', label: 'Ticket class', position: 10 }]    
    @ObjectModel.text.element: ['FlightType']
    @Consumption.valueHelp: '_FlightType'
    type,
    
    @UI.lineItem: [{ position: 80, label: 'Price'  }]
    @UI.fieldGroup: [{ qualifier: 'Ticket', position: 30 }]
    @Semantics.amount.currencyCode: 'waers'
    price,    
    @Semantics.currencyCode 
    @Consumption.valueHelp: '_Currency'   
    waers,
    
    @ObjectModel:{ readOnly: true }
    _FlightType.FlightType,
    
    @UI.fieldGroup: [{ qualifier: 'Other' }]
    @UI: {lineItem: [{ position: 100} ] }
    cancelled,     
    
    
    @UI.fieldGroup: [{ qualifier: 'Other' }]
    @UI: {lineItem: [{ position: 90} ] }
    @UI.multiLineText: true
    comment1,
    
    @UI.fieldGroup: [{ qualifier: 'Penalty', position: 10 }]
    penalty_box,
    @UI.fieldGroup: [{ qualifier: 'Penalty', position: 20 }]
    @Semantics.amount.currencyCode: 'penalty_waers'
    penalty,
    @Semantics.currencyCode
    @Consumption.valueHelp: '_CurrencyPen'
    penalty_waers,    

    @UI.fieldGroup: [{ qualifier: 'Ticket', position: 20 }]
    transport,
    
    //@UI.lineItem: [{ position: 100 }]
    @UI.fieldGroup: [{ qualifier: 'Ticket', position: 50 }]
    @ObjectModel.text.element: [ 'ApprovedByText' ]
    @Consumption.valueHelp: '_ApprovedBy'
    approved_by,
    @ObjectModel.readOnly: true
    _ApprovedBy.text as ApprovedByText,
    
    _FlightType,    
    _AirportBeg,
    _AirportEnd,
    _Currency,
    _CurrencyPen,
    _ApprovedBy,
    _Agency
}
