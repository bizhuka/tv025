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

association [0..1] to ZC_TV025_Currency as _Currency    on _Currency.waers = _Flight.waers
association [0..1] to ZC_TV025_Currency as _CurrencyPen on _CurrencyPen.waers = _Flight.penalty_waers

association [0..1] to ZC_TV025_ApprovedBy as _ApprovedBy on _ApprovedBy.id = _Flight.approved_by


{
    key employee_number,
    key trip_number,
    key s_index,
    
    @UI.identification: [{ position: 10 }]
    @UI.lineItem: [{ position: 10, importance: #HIGH }]
    @ObjectModel.text.element: ['FlightType']
    @Consumption.valueHelp: '_FlightType'
    type,
    
    @ObjectModel:{ readOnly: true }
    _FlightType.FlightType,
    
    @UI.identification: [{ position: 5 }]
    cancelled,
    
    @UI.fieldGroup: [{ qualifier: 'FlightGroup' }]
    @UI.lineItem: [{ position: 20 }]
    @ObjectModel.text.element: ['agency_name']
//    @Consumption.valueHelp: '_Agency'
    @EndUserText.label: 'Agency'
    agency,
    @ObjectModel:{ readOnly: true }
    _Agency.agency_name,
    
    
    @UI.fieldGroup: [{ qualifier: 'Departure', position: 10 }]
    @EndUserText.label: 'Departure'
    @UI.lineItem: [{ position: 70, label: 'Departure' }]
    @ObjectModel.text.element: ['AirportNameBeg']
    @Consumption.valueHelp: '_AirportBeg'
    airport_beg,
    @ObjectModel:{ readOnly: true }
    _AirportBeg.airport_name as AirportNameBeg,    
    
    @UI.fieldGroup: [{ qualifier: 'Departure', position: 20 }]
    @UI.lineItem: [{ position: 30 }]
    date_beg,
    
    @UI.fieldGroup: [{ qualifier: 'Departure', position: 30 }]
    @UI.lineItem: [{ position: 40 }]
    time_beg,
    
    @UI.fieldGroup: [{ qualifier: 'Arrival', position: 10 }]
    @EndUserText.label: 'Arrival'
    @UI.lineItem: [{ position: 80, label: 'Arrival' }]
    @ObjectModel.text.element: ['AirportNameEnd']
    @Consumption.valueHelp: '_AirportEnd'
    airport_end,
    @ObjectModel:{ readOnly: true }
    _AirportEnd.airport_name as AirportNameEnd,

    @UI.fieldGroup: [{ qualifier: 'Arrival', position: 20 }]
    @UI.lineItem: [{ position: 50 }]
    date_end,
    
    @UI.fieldGroup: [{ qualifier: 'Arrival', position: 30 }]
    @UI.lineItem: [{ position: 60 }]
    time_end,
    
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
    
    @UI.fieldGroup: [{ qualifier: 'Ticket', position: 10 }]
    ticket,    
    @UI.fieldGroup: [{ qualifier: 'Ticket', position: 20 }]
    transport,   


    @UI.fieldGroup: [{ qualifier: 'Ticket', position: 30 }]
    @Semantics.amount.currencyCode: 'waers'
    price,    
    @Semantics.currencyCode 
    @Consumption.valueHelp: '_Currency'   
    waers, 
    
    @UI.lineItem: [{ position: 100 }]
    @UI.fieldGroup: [{ qualifier: 'Ticket', position: 50 }]
    @ObjectModel.text.element: [ 'ApprovedByText' ]
    @Consumption.valueHelp: '_ApprovedBy'
    approved_by,
    @ObjectModel.readOnly: true
    _ApprovedBy.text as ApprovedByText,
    
    _FlightType,
    _Agency,
    _AirportBeg,
    _AirportEnd,
    _Currency,
    _CurrencyPen,
    _ApprovedBy
}
