@AbapCatalog.sqlViewName: 'zvctv025_apprby'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approved By'
@VDM.viewType: #CONSUMPTION
@Search.searchable

@ZABAP.virtualEntity: 'ZCL_V_TV025_GET_ALL'

@ObjectModel: {
    writeActivePersistence: 'ZDTV025_APPR_BY',
    transactionalProcessingEnabled: true,
    compositionRoot: true,
    
    createEnabled: true,
    updateEnabled: true,
//    deleteEnabled: true,
    
    semanticKey: ['appr_by']
}

define view ZC_TV025_ApprovedBy as select from zdtv025_appr_by {
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
    @UI.lineItem: [{ position: 10, importance: #HIGH }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 10 }] 
    
    @ObjectModel.text.element: [ 'appr_by_txt' ]
//    @UI.textArrangement: #TEXT_ONLY  
//    @EndUserText.label: 'Approved By'
    key appr_by,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
    @UI.lineItem: [{ position: 20 }]  
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 20 }]
    @EndUserText.label: 'Text'
    appr_by_txt   
}
