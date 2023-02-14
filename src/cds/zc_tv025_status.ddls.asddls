@AbapCatalog.sqlViewName: 'zvctv025_status'
//@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status'
@VDM.viewType: #CONSUMPTION
//@ObjectModel.usageType.sizeCategory: #XS
//@ObjectModel.resultSet.sizeCategory: #XS 



//@Search.searchable
define view ZC_TV025_Status as select from dd07t as t {
//    @UI.textArrangement: #TEXT_ONLY
    @ObjectModel.text.element: [ 'StatusText' ]
  
    @EndUserText.label: 'Status ID'
    key domvalue_l as Status,
    
    ddtext as StatusText    
}where t.domname = 'ZTV_022_STATUS' and t.ddlanguage = $session.system_language and t.as4local = 'A' and t.as4vers = '0000'