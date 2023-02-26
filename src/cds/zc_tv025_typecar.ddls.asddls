@AbapCatalog.sqlViewName: 'zvctv025_typecar'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Type car'

define view ZC_TV025_TypeCar as select from dd07t as t {
    @ObjectModel.text.element: [ 'Text' ]
    @UI.textArrangement: #TEXT_ONLY  
    @EndUserText.label: 'Car type'
    key domvalue_l as id,
    
    @EndUserText.label: 'Text'
    ddtext as text    
} where t.domname = 'ZTV_022_TYPE_CAR' and t.ddlanguage = $session.system_language and t.as4local = 'A' and t.as4vers = '0000'
