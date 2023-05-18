@AbapCatalog.sqlViewName: 'zvctv025_f4_copy'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Search help for Copy From'
@VDM.viewType: #CONSUMPTION
@Search.searchable

@UI: {
    headerInfo: {
        typeName: 'Travel Request',
        typeNamePlural: 'Select Travel Requests'
    }
}

@ZABAP.virtualEntity: 'ZCL_V_TV025_REPORT'

define view ZC_TV025_F4_Copy_From as select from ftpt_req_head as root

  association [1..1] to ZC_TV025_Employee as _Employee on _Employee.pernr = root.pernr
  association [1..1] to ZC_TV025_VISITOR  as _Visitor  on _Visitor.pernr = root.pernr

  association [0..1] to ZC_TV025_Status as _Status on _Status.Status = root.zz_status
  association [0..1] to ZC_TV025_ActivityType as _ActivityType on _ActivityType.Activity = root.activity_type 
  association [0..1] to ZC_PY000_Country as _Country on _Country.land1 = root.country_end
  
  association [0..1] to ZC_PY000_UserInfo as _UserInfoCrt on _UserInfoCrt.uname = root.createdby
  association [0..1] to ZC_PY000_UserInfo as _UserInfoChg on _UserInfoChg.uname = root.uname
{

    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @UI.lineItem: [{ position: 20, importance: #HIGH, label: 'Employee / Visitor' }]
    @ObjectModel.text.element: ['ename']
    key pernr,  
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @ObjectModel.text.element: ['request_reason']
    @UI.lineItem: [{ position: 10, importance: #HIGH }]
    key reinr,
    
    // Additional search helps    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }    
    _Employee.ename as EmpName,    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    _Visitor.ename as VisName,
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    request_reason,
    
    @EndUserText.label: 'Full name'  
    coalesce (_Employee.ename, _Visitor.ename) as ename,
    
    date_beg,
    date_end,
    
    @UI.selectionField: [{ position: 200 }]
    @Consumption.valueHelp: '_ActivityType'
    @ObjectModel.text.element: ['activity_name']     
    @UI.lineItem: [{ position: 30 }]
    //@UI.hidden: true
    activity_type,   
    @EndUserText.label: 'Activity Type'   
    _ActivityType.activity_name,
    
    @UI.lineItem: [{ position: 40, label: 'Country' }]
    @ObjectModel.text.element: ['CountryText']
    @Consumption.valueHelp: '_Country'
    //@UI.hidden: true
    country_end,
    @EndUserText.label: 'Country'
    _Country.CountryText,    
    
    @EndUserText.label: 'City'
    location_end,
    
    @UI.lineItem: [{ position: 100, criticality: 'StatusCriticality', importance: #HIGH }]
    @UI.selectionField: [{ position: 100 }]
    @Consumption.valueHelp: '_Status' 
    @ObjectModel.text.element: ['StatusText']
    //@UI.hidden: true
    zz_status,
    @EndUserText.label: 'Status'
    _Status.StatusText,    

    @UI.selectionField: [{ position: 400 }]
    @Consumption.valueHelp: '_UserInfoCrt'
    @ObjectModel.text.element: ['CrtName']
    //@UI.hidden: true
    createdby as crunm,
    @EndUserText.label: 'Created By' 
    _UserInfoCrt.UserName as CrtName,
    
    @EndUserText.label: 'Created On'
    case when zz_crdat = '00000000' then dates else zz_crdat end as crdat,
    
    @UI.selectionField: [{ position: 500 }]
    @Consumption.valueHelp: '_UserInfoChg'
    @ObjectModel.text.element: ['ChgName']
    //@UI.hidden: true
    uname as chunm,
    @EndUserText.label: 'Changed By'
    _UserInfoChg.UserName as ChgName,
    
    dates as chdat,
    
    
//    // Nested SH
    _Status,
    _ActivityType,
    _Country,
    _UserInfoCrt,
    _UserInfoChg
} where requestvrs = '99' and plan_request = 'R' and zz_status <> ' '
