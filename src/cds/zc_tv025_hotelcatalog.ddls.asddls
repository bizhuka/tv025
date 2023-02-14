@AbapCatalog.sqlViewName: 'zvctv025_hotelca'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hotel catalog'
@VDM.viewType: #CONSUMPTION
@Search.searchable

// BOPF sub
@ObjectModel:{
    semanticKey: ['hotel_id' ],
    
    //Delegate the CRUD
    transactionalProcessingDelegated: true,
  
    //To define what all actions are enabled
    createEnabled: true,
    updateEnabled: true
}
@ZABAP.virtualEntity: 'ZCL_V_TV025_GET_ALL'

define view ZC_TV025_HotelCatalog as select from ZI_TV025_HotelCatalog as _cat

association [0..1] to ZC_TV025_Country as _Country on _Country.land1 = _cat.country_id
association [0..1] to ZC_TV025_HotelTown as _Town on _Town.town_id = _cat.town_id

{   
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @UI.lineItem: [{ position: 10, importance: #HIGH }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 10 }]  
    key hotel_id,        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 1 }
        @UI.lineItem: [{ position: 30 }]  
        @UI.fieldGroup: [{ qualifier: 'Grp0', position: 20 }]
        @ObjectModel.text.element: ['CountryText']
        @Consumption.valueHelp: '_Country'
        country_id,
        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
        @ObjectModel:{ readOnly: true }
        _Country.CountryText,        

        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
        @UI.lineItem: [{ position: 40 }]  
        @UI.fieldGroup: [{ qualifier: 'Grp0', position: 40 }]
        @Consumption.valueHelp: '_Town'
        town_id,        
        
        @UI.lineItem: [{ position: 45 }]  
        @UI.fieldGroup: [{ qualifier: 'Grp0', position: 20 }]
        hotel_class,        
        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
        @UI.lineItem: [{ position: 50 }]  
        @UI.fieldGroup: [{ qualifier: 'Grp0', position: 50 }]
        hotel_name,        
        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
        @UI.lineItem: [{ position: 60 }]  
        @UI.fieldGroup: [{ qualifier: 'Grp0', position: 60 }]
        hotel_address,        
        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
        @UI.lineItem: [{ position: 70 }]  
        @UI.fieldGroup: [{ qualifier: 'Grp0', position: 70 }]
        hotel_phone,        
        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
        @UI.lineItem: [{ position: 80 }]  
        @UI.fieldGroup: [{ qualifier: 'Grp0', position: 80 }]
        @UI.multiLineText: true
        hotel_comments,
        
        _Country,
        _Town
}