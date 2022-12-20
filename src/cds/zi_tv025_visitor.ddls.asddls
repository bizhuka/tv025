@AbapCatalog.sqlViewName: 'zvitv025_visitor'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Visitor'
@VDM.viewType: #TRANSACTIONAL


@ObjectModel: {
    writeActivePersistence: 'ZDTV025_VISITOR',
    transactionalProcessingEnabled: true,
    compositionRoot: true,
       
    createEnabled: true,
    updateEnabled: true,
//    deleteEnabled: true,
    
    semanticKey: ['pernr']
}

define view zi_tv025_visitor as select from zdtv025_visitor as _Visitor
                                              
{ 
     key pernr, 
         
         @ObjectModel:{ mandatory: true }
         birth_date,
         
         @ObjectModel:{ mandatory: true }
         ename,
         
         @ObjectModel:{ mandatory: true }
         orgeh_text,
         
         @ObjectModel:{ mandatory: true }
         citizenship,
         
         @ObjectModel:{ mandatory: true }
         passp_number,
         
         @ObjectModel:{ mandatory: true }
         passp_expiry
}
