@AbapCatalog.sqlViewName: 'zvctv025_hotel'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hotel'
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
@ZABAP.virtualEntity: 'ZCL_I_ROOT_CHILD_CHECK'

define view ZC_TV025_HOTEL as select from ZI_TV025_HOTEL as _Hotel
association [0..1] to ZC_TV025_Agency       as _Agency       on _Agency.agency_id      = _Hotel.agency
association [0..1] to ZC_TV025_Basis        as _Basis        on _Basis.basis_id        = _Hotel.basis

association [0..1] to ZC_TV025_HotelCatalog as _HotelCatalog on _HotelCatalog.hotel_id = _Hotel.hotel_end
association [0..1] to ZC_TV025_TypeCar      as _TypeCar      on _TypeCar.id            = _Hotel.type_car

association [0..1] to ZC_PY000_Currency as _Currency      on _Currency.waers      = _Hotel.waers
association [0..1] to ZC_PY000_Currency as _CurrencyPen   on _CurrencyPen.waers   = _Hotel.penalty_waers
association [0..1] to ZC_PY000_Currency as _CurrencyTrans on _CurrencyTrans.waers = _Hotel.transport_waers

{
    key employee_number,
    key trip_number,
    key s_index,
    
    @UI.identification: [{ position: 10 }]
    @UI.lineItem: [{ position: 10, importance: #HIGH }]
//    @ObjectModel.text.element: ['hotel_name']
    @Consumption.valueHelp: '_HotelCatalog'
    hotel_end, 
    @ObjectModel:{ readOnly: true }
    _HotelCatalog.hotel_name,
    
    @UI.identification: [{ position: 20 }]
    @UI.lineItem: [{ position: 50 }]
    @Semantics.amount.currencyCode: 'waers'
    price,    
    @Semantics.currencyCode 
    @Consumption.valueHelp: '_Currency'
    waers,

    
///////////////////////////////////////////////////////////////////////
    @UI.fieldGroup: [{ qualifier: 'Dates', position: 10 }]
    @UI.lineItem: [{ position: 30 }]
    date_beg,
    
    @UI.fieldGroup: [{ qualifier: 'Dates', position: 20 }]
    @UI.lineItem: [{ position: 40 }]
    date_end,
    
    @UI.fieldGroup: [{ qualifier: 'Dates', position: 30 }]
    booked_nights,
        
    @UI.fieldGroup: [{ qualifier: 'Dates', position: 40 }]
    early_check_in,
    
    @UI.fieldGroup: [{ qualifier: 'Dates', position: 50 }]
    later_check_out,    
    
    
///////////////////////////////////////////////////////////////////////    
    @UI.fieldGroup: [{ qualifier: 'Transport', position: 10 }]
    assigned_car,
    
    @UI.fieldGroup: [{ qualifier: 'Transport', position: 20 }]
    @ObjectModel.text.element: ['TypeCarText'] 
    @UI.textArrangement: #TEXT_ONLY
    @Consumption.valueHelp: '_TypeCar'  
    type_car,    
    @ObjectModel.readOnly: true
    _TypeCar.text as TypeCarText,

    @UI.fieldGroup: [{ qualifier: 'Transport', position: 30 }]
    transport_airport,
    
    @UI.fieldGroup: [{ qualifier: 'Transport', position: 40 }]
    transport_hotel,
        
    @UI.fieldGroup: [{ qualifier: 'Transport', position: 50 }]
    @Semantics.amount.currencyCode: 'transport_waers'
    transport_price,
    
    @Semantics.currencyCode
    @Consumption.valueHelp: '_CurrencyTrans'
    transport_waers,


///////////////////////////////////////////////////////////////////////
    
    @UI.fieldGroup: [{ qualifier: 'HotelGroup', position: 10 }]
    @UI.lineItem: [{ position: 20, importance: #HIGH }]
    @ObjectModel.text.element: ['agency_name']
    @Consumption.valueHelp: '_Agency'
    @EndUserText.label: 'Agency'
    agency,
    @ObjectModel:{ readOnly: true }
    _Agency.agency_name,
        
    @UI.fieldGroup: [{ qualifier: 'HotelGroup', position: 20 }]
//    @ObjectModel.text.element: ['hotel_basis_txt']
    @Consumption.valueHelp: '_Basis'
    @EndUserText.label: 'Basis'
    basis,
    @ObjectModel:{ readOnly: true }
    _Basis.hotel_basis_txt,

///////////////////////////////////////////////////////////////////////    
    @UI.fieldGroup: [{ qualifier: 'Penalty', position: 10 }]
    penalty_check,
        
    @UI.fieldGroup: [{ qualifier: 'Penalty', position: 20 }]
    @Semantics.amount.currencyCode: 'penalty_waers'
    penalty,    
    @Semantics.currencyCode
    @Consumption.valueHelp: '_CurrencyPen'
    penalty_waers,
    
    
///////////////////////////////////////////////////////////////////////
    @UI.fieldGroup: [{ qualifier: 'Other' }]
    @UI: {lineItem: [{ position: 90} ] }
    @UI.multiLineText: true
    comment1,
    
    
///////////////////////////////////////////////////////////////////////
    _Agency,
    _Basis,
    _HotelCatalog,
    _TypeCar,
    _Currency,
    _CurrencyPen,
    _CurrencyTrans    
}
