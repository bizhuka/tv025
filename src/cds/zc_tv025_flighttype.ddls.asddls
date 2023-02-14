@AbapCatalog.sqlViewName: 'zvctv025_fltt'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Type'
@VDM.viewType: #CONSUMPTION

define view ZC_TV025_FlightType as select from dd07t as t {
    @ObjectModel.text.element: [ 'FlightType' ]
  
    @EndUserText.label: 'Flight Type'
    key domvalue_l as Id,
    ddtext as FlightType    
}where t.domname = 'ZTV_022_FLIGHT_TYPE' and t.ddlanguage = $session.system_language and t.as4local = 'A' and t.as4vers = '0000'