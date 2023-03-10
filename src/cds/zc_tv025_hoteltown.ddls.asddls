@AbapCatalog.sqlViewName: 'zvctv025_htl_twn'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'All towns'
@VDM.viewType: #CONSUMPTION
@Search.searchable

define view ZC_TV025_HotelTown as select distinct from zdtv025_hotel_ca
  association [0..1] to ZC_TV025_Country as _Country on _Country.land1 = country_id
{
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 1 }
    @Consumption.valueHelp: '_Country'
    key country_id,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
    key town_id,
    
        _Country
}
