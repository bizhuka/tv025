@AbapCatalog.sqlViewName: 'zvitv025_transp'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport'
@VDM.viewType: #TRANSACTIONAL

@ObjectModel:{
        semanticKey: ['employee_number', 'trip_number', 's_index'],
        transactionalProcessingEnabled: true,
        writeActivePersistence: 'ZDTV025_TRANSP',    // <--- Where to write
        
        //Enable the CRUD Activity
        createEnabled: true,
        deleteEnabled: true,
        updateEnabled: true
}

define view ZI_TV025_Transport as select from zdtv025_transp as _Transport
  association [1..1] to ZI_TV025_ROOT as _root on _root.pernr        = _Transport.employee_number
                                              and _root.reinr        = _Transport.trip_number
                                              and _root.requestvrs   = _Transport.requestvrs
                                              and _root.plan_request = _Transport.plan_request
{
    key employee_number,
    key trip_number,
    key s_index,
    key requestvrs,
    key plan_request,
    
    date_beg,
    time_beg,
    date_end,
    time_end,
    check_point,
    arrival,
    comment1,
    not_required,
    vip,
    
    @ObjectModel.association: {
          type: [ #TO_COMPOSITION_PARENT, #TO_COMPOSITION_ROOT ]
      }
    _root
}
