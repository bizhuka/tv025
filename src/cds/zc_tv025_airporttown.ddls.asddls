@AbapCatalog.sqlViewName: 'zvctv025_air_twn'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Airport Town'
@VDM.viewType: #CONSUMPTION
@Search.searchable

define view ZC_TV025_AirportTown as select distinct from zdtv025_airport {
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 1 }
    key country_id,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
    key town
}