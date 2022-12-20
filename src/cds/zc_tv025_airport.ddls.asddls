@AbapCatalog.sqlViewName: 'zvctv025_airport'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Airport'
@VDM.viewType: #CONSUMPTION
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

association [0..1] to ZC_TV025_Country as _Country on _Country.land1 = _Airport.country_id

{
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @UI.lineItem: [{ position: 10, importance: #HIGH }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 10 }]   
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
    town,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }    
    @UI.lineItem: [{ position: 40 }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 40 }]
    iata_code,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
    @UI.lineItem: [{ position: 50 }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 50 }]
    airport_name,
    
    _Country
}
