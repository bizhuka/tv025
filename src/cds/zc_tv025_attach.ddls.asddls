@AbapCatalog.sqlViewName: 'zvctv025_attach'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Attachments'
@VDM.viewType: #CONSUMPTION


@ObjectModel:{
//    semanticKey: ['pernr', 'reinr', 'file_name'],
//    transactionalProcessingEnabled: true,
//    writeActivePersistence: 'ZDTV025_ATTACH_D',    // <--- Where to write
//    compositionRoot: true,
    
    //Enable the CRUD Activity
//    createEnabled: true,
//    updateEnabled: true,
    deleteEnabled: true
}


@UI.headerInfo: {
  typeName: 'Attachment',
  typeNamePlural: 'Attachments',
  title: {
    value: 'file_name',
    type: #STANDARD
  }
}

@ZABAP.virtualEntity: 'ZCL_V_TV025_ATTACH'

define view ZC_TV025_Attach as select from zdtv025_attach_d {
    key pernr,
    key reinr,
    key doc_id,    
    
    @UI.lineItem: [{ position: 20, type: #WITH_URL, url: 'doc_url' }]
    @EndUserText.label: 'File name'
    file_name,
    
    @UI.lineItem: [{ position: 10 }]
    @EndUserText.label: '№'
    s_index,
    
    // Url to file
    doc_url,
    
    //icon as Icon,
    
    @UI.lineItem: [{ position: 30 }]
    created_at_date,
    
    @UI.lineItem: [{ position: 40 }]
    created_at_time,
    
    @UI.lineItem: [{ position: 50, importance: #LOW }]
    created_by,
    
    @UI.lineItem: [{ position: 60, importance: #LOW }]
    created_by_txt,
    
    @UI.lineItem: [{ position: 70, importance: #HIGH }]
    @EndUserText.label: 'File size'
    file_size,
    
    class,
    objid,
    
    // For ok message
    message
}
