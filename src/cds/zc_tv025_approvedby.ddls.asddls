@AbapCatalog.sqlViewName: 'zvctv025_apprby'
//@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approved By'
@VDM.viewType: #CONSUMPTION

define view ZC_TV025_ApprovedBy as select from dd07t as t {
    @ObjectModel.text.element: [ 'Text' ]
    @UI.textArrangement: #TEXT_ONLY  
    @EndUserText.label: 'Approved By'
    key domvalue_l as id,
    
    @EndUserText.label: 'Text'
    ddtext as text    
} where t.domname = 'ZDD_TV022_APPROVED_BY' and t.ddlanguage = $session.system_language and t.as4local = 'A' and t.as4vers = '0000'