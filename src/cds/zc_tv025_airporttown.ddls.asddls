@AbapCatalog.sqlViewName: 'zvctv025_air_twn'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Airport Town'
@VDM.viewType: #CONSUMPTION
@Search.searchable

define view ZC_TV025_AirportTown as select distinct from zdtv025_airport
  association [0..1] to ZC_PY000_Country as _Country on _Country.land1 = country_id
{
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 1 }
    @Consumption.valueHelp: '_Country'
    key country_id,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 1 }
    key town,
    
        _Country
}
