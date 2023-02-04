@AbapCatalog.sqlViewName: 'zvctv025_checkp'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pickup \ Destinations points'
@VDM.viewType: #CONSUMPTION
@Search.searchable

@ZABAP.virtualEntity: 'ZCL_V_TV025_GET_ALL'

@ObjectModel: {
    writeActivePersistence: 'ZDTV025_CHECKP',
    transactionalProcessingEnabled: true,
    compositionRoot: true,
    
    createEnabled: true,
    updateEnabled: true,
//    deleteEnabled: true,
    
    semanticKey: ['id']
}

define view ZC_TV025_CheckPoint as select from zdtv025_checkp

{
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @UI.lineItem: [{ position: 10, importance: #HIGH }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 10 }] 
    
    @ObjectModel.text.element: [ 'ChkPointText' ]
    @EndUserText.label: 'Check point'
    key id,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @UI.lineItem: [{ position: 20 }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 20 }]
        codegruppe,
        
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @UI.lineItem: [{ position: 30 }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 30 }]
        code,        
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
    @UI.lineItem: [{ position: 40 }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 40 }]
        kurztext
}
