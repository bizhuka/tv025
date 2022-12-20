@AbapCatalog.sqlViewName: 'zvctv025_transp'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Transport'
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

define view ZC_TV025_Transport as select from ZI_TV025_Transport as _Transport

association [0..1] to ZC_TV025_CheckPoint as _CheckPoint on _CheckPoint.id = _Transport.check_point
association [0..1] to ZC_TV025_CheckPoint as _Arrrival   on _Arrrival.id   = _Transport.arrival


{
    key employee_number,
    key trip_number,
    key s_index,

    @UI.identification: [{ position: 10 }]    
    @UI.lineItem: [{ position: 50 }]
    @ObjectModel.text.element: ['ChkText']
    @Consumption.valueHelp: '_CheckPoint'
    check_point,    
    @ObjectModel:{ readOnly: true }
    _CheckPoint.kurztext as ChkText,
    
    @UI.identification: [{ position: 20 }]
    @UI.lineItem: [{ position: 60 }]
    @ObjectModel.text.element: ['ArrText']
    @Consumption.valueHelp: '_Arrrival'
    @EndUserText.label: 'Arrrival' 
    arrival,    
    @ObjectModel:{ readOnly: true }
    _Arrrival.kurztext as ArrText,
    
///////////////////////////////////////////////////////////////////////    
    
    @UI.lineItem: [{ position: 10 }]
    @UI.fieldGroup: [{ qualifier: 'Dates', position: 10 }]
    date_beg,    
    @UI.lineItem: [{ position: 20 }]
    @UI.fieldGroup: [{ qualifier: 'Dates', position: 20 }]
    time_beg,
    
    @UI.lineItem: [{ position: 30 }]
    @UI.fieldGroup: [{ qualifier: 'Dates', position: 30 }]
    date_end,    
    @UI.lineItem: [{ position: 40 }]
    @UI.fieldGroup: [{ qualifier: 'Dates', position: 40 }]
    time_end,
    

///////////////////////////////////////////////////////////////////////
    @UI.fieldGroup: [{ qualifier: 'Other' }]
    @UI: {lineItem: [{ position: 70} ] }
    @UI.multiLineText: true
    comment1,
    
    @UI.lineItem: [{ position: 80 }]
    @UI.fieldGroup: [{ qualifier: 'Status', position: 10 }]    
    not_required,
    @UI.fieldGroup: [{ qualifier: 'Status', position: 20 }]
    @UI.lineItem: [{ position: 90 }]    
    vip,
    
    
    _CheckPoint,
    _Arrrival
}
