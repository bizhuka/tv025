@AbapCatalog.sqlViewName: 'zvctv025_history'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'History'


define view ZC_TV025_History as select from zdtv025_history
  association [0..1] to ZC_PY000_UserInfo as _UserInfo on _UserInfo.uname = $projection.uname
  association [0..1] to ZC_TV025_Status as _Status on _Status.Status = $projection.status
  
{

    key pernr,
    key reinr,
    
    @UI.lineItem: [{ position: 30 }]    
    @EndUserText.label: 'Date and time'
    key time_stamp,
    
        @UI.lineItem: [{ position: 40 }]
        @ObjectModel.text.element: [ 'UserName' ]
        uname,
        _UserInfo.UserName,
        
        @UI.lineItem: [{ position: 50 }]
        @ObjectModel.text.element: [ 'StatusText' ]
        status,
        _Status.StatusText
}
