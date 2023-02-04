@AbapCatalog.sqlViewName: 'zvitv025_root'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request ROOT'
@VDM.viewType: #TRANSACTIONAL

@ObjectModel: {
    transactionalProcessingEnabled: true,
    writeActivePersistence: 'FTPT_REQ_HEAD',
    compositionRoot: true,
    createEnabled: true,
    updateEnabled: true,
//    deleteEnabled: true,
    
    semanticKey: [ 'pernr', 'reinr'],
    // draftEnabled: true, writeDraftPersistence: ''
    // modelCategory: #BUSINESS_OBJECT,
    
    entityChangeStateId: 'ZZ_ETAG',
    
    lifecycle.enqueue: {
      expiryBehavior: #RELATIVE_TO_LAST_CHANGE,
      expiryInterval: 'PT1M'
    },
    lifecycle.processing: {
      expiryBehavior: #RELATIVE_TO_LAST_CHANGE,
      expiryInterval: 'PT1M'
    }
}


define view ZI_TV025_ROOT as select from ftpt_req_head as root

  association [0..*] to ZI_TV025_FLIGHT as _Flight on _Flight.employee_number = root.pernr
                                                  and _Flight.trip_number     = root.reinr
                                                  and _Flight.requestvrs      = root.requestvrs
                                                  and _Flight.plan_request    = root.plan_request
                                                  
  association [0..*] to ZI_TV025_HOTEL as _Hotel on _Hotel.employee_number = root.pernr
                                                and _Hotel.trip_number     = root.reinr
                                                and _Hotel.requestvrs      = root.requestvrs
                                                and _Hotel.plan_request    = root.plan_request
                                                
  association [0..*] to ZI_TV025_Transport as _Transport on _Transport.employee_number = root.pernr
                                                        and _Transport.trip_number     = root.reinr
                                                        and _Transport.requestvrs      = root.requestvrs
                                                        and _Transport.plan_request    = root.plan_request
 {
    @ObjectModel.mandatory: true
    key root.pernr,
    key root.reinr,
    key root.requestvrs,
    key root.plan_request,
    
    @ObjectModel: { mandatory: false }
    root.date_beg,
    @ObjectModel: { mandatory: false }
    root.date_end,
    
    @ObjectModel: { mandatory: true }
    root.activity_type,
    @ObjectModel: { mandatory: true }
    root.location_end,
    @ObjectModel: { mandatory: true }
    root.country_end,    
    @ObjectModel: { mandatory: true }
    root.request_reason,    
    
    zz_status,
        
    // Creating info partly from ZZ* fields
    root.createdby, 
    root.zz_crdat,
    root.zz_crtime, 
    
    // Changing info from std fields
    uname,
    dates,
    times,
    
//    //@ObjectModel.readOnly: 'EXTERNAL_CALCULATION'
//    zz_etag,
//    zz_etag_usr,
    
    @ObjectModel: { mandatory: true }
    currency,
    
    // TODO fix update bug    
    @ObjectModel: { readOnly: true }
    time_beg,
    @ObjectModel: { readOnly: true }
    time_end,
    @ObjectModel: { readOnly: true }
    estimated_cost,
    @ObjectModel: { readOnly: true }
    status,
    @ObjectModel: { readOnly: true }
    repid,
    @ObjectModel: { readOnly: true }
    depar,
    @ObjectModel: { readOnly: true }
    approvedby,
    @ObjectModel: { readOnly: true }
    delivery_date,
    @ObjectModel: { readOnly: true }
    delivery_loc,
    @ObjectModel: { readOnly: true }
    delivery_area,
    @ObjectModel: { readOnly: true }
    delivery_empl,
    @ObjectModel: { readOnly: true }
    arrival_work,
    @ObjectModel: { readOnly: true }
    return_work,
    @ObjectModel: { readOnly: true }
    t_actype,
    @ObjectModel: { readOnly: true }
    perm_trip_appr,
    @ObjectModel: { readOnly: true }
    tt_statu,
    @ObjectModel: { readOnly: true }
    tt_comsp,
    @ObjectModel: { readOnly: true }
    gwe,
    @ObjectModel: { readOnly: true }
    edi,
    @ObjectModel: { readOnly: true }
    carry_oth,
    @ObjectModel: { readOnly: true }
    carried_by_oth,
    @ObjectModel: { readOnly: true }
    datecow,
    @ObjectModel: { readOnly: true }
    timecow,
    @ObjectModel: { readOnly: true }
    dateeow,
    @ObjectModel: { readOnly: true }
    timeeow,
    @ObjectModel: { readOnly: true }
    incr_max_tripseg_reimb,
    @ObjectModel: { readOnly: true }
    addr_depar,
    @ObjectModel: { readOnly: true }
    addr_arrvl,
    
    '########' as fake_visitor,
    '###'      as fake_agency,      
    '#####'    as fake_hotel_id,
    '###'      as fake_basis_id,
    '#####'    as fake_airport_id,
    '####'     as fake_ch_id,
    
    @ObjectModel.association: {
      type: [ #TO_COMPOSITION_CHILD ]
    }    
    _Flight,
    
    @ObjectModel.association: {
      type: [ #TO_COMPOSITION_CHILD ]
    }    
    _Hotel,
    
    @ObjectModel.association: {
      type: [ #TO_COMPOSITION_CHILD ]
    } 
    _Transport
} where root.requestvrs = '99' and root.plan_request = 'R'
