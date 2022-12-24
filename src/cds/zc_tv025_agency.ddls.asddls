@AbapCatalog.sqlViewName: 'zvctv025_agency'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agency'
@VDM.viewType: #CONSUMPTION
@Search.searchable

@ZABAP.virtualEntity: 'ZCL_V_TV025_GET_ALL'

@ObjectModel: {
    writeActivePersistence: 'ZDTV025_AGENCY',
    transactionalProcessingEnabled: true,
    compositionRoot: true,
    
    createEnabled: true,
    updateEnabled: true,
//    deleteEnabled: true,
    
    semanticKey: ['agency_id']
}

define view ZC_TV025_Agency as select from zdtv025_agency as _Agency  
{
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @UI.lineItem: [{ position: 10, importance: #HIGH }]
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 10 }]
    @ObjectModel.text.element: ['agency_name']
    key agency_id,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
    @UI.lineItem: [{ position: 20 }]
    @UI.fieldGroup: [{ qualifier: 'Grp0', position: 20 }]
    agency_name
}
