@AbapCatalog.sqlViewName: 'zvctv025_basis'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basis'
@VDM.viewType: #CONSUMPTION
@Search.searchable

@ZABAP.virtualEntity: 'ZCL_V_TV025_GET_ALL'

@ObjectModel: {
    writeActivePersistence: 'ZDTV025_BASIS',
    transactionalProcessingEnabled: true,
    compositionRoot: true,
    
    createEnabled: true,
    updateEnabled: true,
//    deleteEnabled: true,
    
    semanticKey: ['basis_id']
}

define view ZC_TV025_Basis as select from zdtv025_basis {  
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @UI.lineItem: [{ position: 10, importance: #HIGH }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 10 }] 
    @ObjectModel.text.element: ['hotel_basis_txt']  
    key basis_id,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @UI.lineItem: [{ position: 20 }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 20 }]
        hotel_basis,
        
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
    @UI.lineItem: [{ position: 30 }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 30 }]
        hotel_basis_txt
}
