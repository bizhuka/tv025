@AbapCatalog.sqlViewName: 'zvctv025_airport'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Airport'
@VDM.viewType: #CONSUMPTION
@ObjectModel.dataCategory: #TEXT
@Search.searchable

@ZABAP.virtualEntity: 'ZCL_V_TV025_GET_ALL'

@ObjectModel: {
    writeActivePersistence: 'ZDTV025_AIRPORT',
    transactionalProcessingEnabled: true,
    compositionRoot: true,
    
    createEnabled: true,
    updateEnabled: true,
//    deleteEnabled: true,
    
    semanticKey: ['airport_id']
}

define view ZC_TV025_Airport as select from zdtv025_airport as _Airport

association [0..1] to ZC_PY000_Country as _Country on _Country.land1 = _Airport.country_id
association [0..1] to ZC_TV025_AirportTown as _Town on _Town.town = _Airport.town


{
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @UI.lineItem: [{ position: 10 }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 10 }]   
    @ObjectModel.text.element: ['airport_name']
    key airport_id,   
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 1 }
    @UI.lineItem: [{ position: 20 }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 20 }]    
    @ObjectModel.text.element: ['CountryText']
    @Consumption.valueHelp: '_Country'
    country_id,    
    _Country.CountryText,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
    @UI.lineItem: [{ position: 30 }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 20 }]
    @Consumption.valueHelp: '_Town'
    town,
    
//    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }    
//    @UI.lineItem: [{ position: 40 }]  
//    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 40 }]
//    iata_code,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
    @UI.lineItem: [{ position: 50 }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 50 }]
    @Semantics.text: true
    airport_name,
    
//    @ObjectModel:{ readOnly: true }
//    @UI.hidden: true
//    concat_with_space(iata_code, airport_name, 1) as airport_with_code,

  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 60 }]
    @ObjectModel: { mandatory: true }
    latitude,    
   
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 70 }]
    @ObjectModel: { mandatory: true }
    longitude,
     
    _Country,
    _Town
}
