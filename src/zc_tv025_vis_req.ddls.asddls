@AbapCatalog.sqlViewName: 'zvctv025_vis_req'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Visitor request'

define view ZC_TV025_Vis_Req as select from ftpt_req_head {
key pernr,
key reinr,
    activity_type,
    date_beg,
    date_end,
    country_end,
    location_end,
    request_reason
} where pernr like '9%'
