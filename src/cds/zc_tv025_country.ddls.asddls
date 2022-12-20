@AbapCatalog.sqlViewName: 'zvctv025_country'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Country'
@VDM.viewType: #CONSUMPTION
@Search.searchable

define view ZC_TV025_Country as select from t005t {
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
    @ObjectModel.text.element: [ 'CountryText' ]  
    @EndUserText.label: 'Country'
    key land1,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
    landx as CountryText
}where spras = $session.system_language
