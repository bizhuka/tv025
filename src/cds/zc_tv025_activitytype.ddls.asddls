@AbapCatalog.sqlViewName: 'zvctv025_acttype'
//@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Activity Type'
@VDM.viewType: #CONSUMPTION
//@ObjectModel.usageType.sizeCategory: #XS
//@ObjectModel.resultSet.sizeCategory: #XS 


define view ZC_TV025_ActivityType as select from ta20r1 {
//    @UI.textArrangement: #TEXT_ONLY
    @ObjectModel.text.element: [ 'activity_name' ]
    key acticity as Activity,
    name as activity_name
}where spras = $session.system_language