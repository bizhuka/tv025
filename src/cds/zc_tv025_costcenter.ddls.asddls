@AbapCatalog.sqlViewName: 'zvctv025_cost_c'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Center'


define view ZC_TV025_CostCenter as select from ftpt_req_account as a
    left outer join prps as wbs on wbs.pspnr = a.posnr
    left outer join cskt as cost on cost.spras = $session.system_language and cost.kokrs = a.kokrs and cost.kostl = a.kostl and cost.datbi = '99991231' //>= _Employee.datum

{

    key a.pernr,
    key a.reinr,
    key a.requestvrs,
    key a.plan_request,
    
    a.kostl,
    cost.ltext,
    wbs.posid,
    wbs.post1
} where a.account = '01'