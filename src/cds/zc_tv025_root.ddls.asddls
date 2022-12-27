@AbapCatalog.sqlViewName: 'zvctv025_root'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request ROOT'
@VDM.viewType: #CONSUMPTION
@Search.searchable

@ObjectModel: {
    transactionalProcessingDelegated: true,
    
    compositionRoot: true,
    createEnabled: true,
    updateEnabled: true,
    semanticKey: ['pernr', 'reinr']
//    deleteEnabled: true,
//    draftEnabled: true
}


@UI: {
    headerInfo: {
        typeName: 'Travel Request',
        typeNamePlural: 'Travel Requests',
        title: {
            type: #STANDARD, value: 'text_info'
        },
        description: {
            value: 'id_info'
        }
    }
}   
 
@OData.publish: true
@ZABAP.virtualEntity: 'ZCL_V_TV025_ROOT'

define view ZC_TV025_ROOT as select from ZI_TV025_ROOT as root
  association [1..1] to ZC_TV025_Employee as _Employee on _Employee.pernr = root.pernr
  association [1..1] to ZC_TV025_VISITOR  as _Visitor  on _Visitor.pernr = root.pernr

  association [0..*] to ZC_TV025_FLIGHT as _Flight on _Flight.employee_number = root.pernr
                                                  and _Flight.trip_number     = root.reinr
  association [0..*] to ZC_TV025_HOTEL as _Hotel on _Hotel.employee_number    = root.pernr
                                                and _Hotel.trip_number        = root.reinr
  association [0..*] to ZC_TV025_Transport as _Transport on _Transport.employee_number    = root.pernr
                                                        and _Transport.trip_number        = root.reinr
  association [0..*] to ZC_TV025_Attach as _Attach on _Attach.pernr           = root.pernr
                                                  and _Attach.reinr           = root.reinr                                                  
  association [0..*] to ZC_TV025_F4_Copy_From as _CopyFrom on _CopyFrom.pernr = root.pernr
                                                          and _CopyFrom.reinr = root.reinr
                                                  
  association [0..1] to ZC_TV025_Status as _Status on _Status.Status = root.zz_status
  association [0..1] to ZC_TV025_ActivityType as _ActivityType on _ActivityType.Activity = root.activity_type 
  association [0..1] to ZC_TV025_Country as _Country on _Country.land1 = root.country_end
  
  association [0..1] to ZC_TV025_UserInfo as _UserInfoCrt on _UserInfoCrt.uname = root.createdby
  association [0..1] to ZC_TV025_UserInfo as _UserInfoChg on _UserInfoChg.uname = root.uname
  
  // Employee Cost Info
  association [0..1] to ZC_TV025_CostCenter as CostCenter on CostCenter.pernr      = root.pernr      and CostCenter.reinr        = root.reinr
                                                         and CostCenter.requestvrs = root.requestvrs and CostCenter.plan_request = root.plan_request
                                                         
  association [0..*] to ZC_TV025_FakeVisitor  as _FakeVisitor      on _FakeVisitor.pernr         = root.fake_visitor
  association [0..*] to ZC_TV025_Agency       as _FakeAgency       on _FakeAgency.agency_id      = root.fake_agency
  association [0..*] to ZC_TV025_HotelCatalog as _FakeHotelCatalog on _FakeHotelCatalog.hotel_id = root.fake_hotel_id
  association [0..*] to ZC_TV025_Basis        as _FakeBasis        on _FakeBasis.basis_id        = root.fake_basis_id
  association [0..*] to ZC_TV025_Airport      as _FakeAirport      on _FakeAirport.airport_id    = root.fake_airport_id
  association [0..*] to ZC_TV025_CheckPoint   as _FakeCheckPoint   on _FakeCheckPoint.id         = root.fake_ch_id
      
                                                     
{    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
    @UI.lineItem: [{ position: 10, importance: #HIGH, label: 'Employee / Visitor' }]
    @ObjectModel.text.element: ['ename']
    
    @Consumption.valueHelp: '_Visitor'
    @UI.fieldGroup: [{ qualifier: 'VisitorGroup', position: 1 }]
    @EndUserText.label: 'Visitor ID'    
    key pernr,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @ObjectModel.text.element: ['request_reason']
    @UI.lineItem: [{ position: 20, importance: #HIGH }]
//    @UI.fieldGroup: [{ qualifier: 'MainGroup', position: 1 }]
//    @Consumption.valueHelp: '_CopyFrom'
    key reinr,
    
    key requestvrs,
    key plan_request,
        
    // Additional search helps
    @ObjectModel:{ readOnly: true }
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }    
    _Employee.ename as EmpName,
    @ObjectModel:{ readOnly: true }
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    _Visitor.ename as VisName,
    
///////////////////////////////////////////////////////////////   
    
    @ObjectModel:{ readOnly: true }
    coalesce (_Employee.ename, _Visitor.ename) as ename,
    
    @ObjectModel:{ readOnly: true }
    concat( concat( ltrim(pernr, '0'), '-'), ltrim(reinr, '0') ) as id_info,
    
    @ObjectModel:{ readOnly: true }
    concat( concat( coalesce (_Employee.ename, _Visitor.ename), '-'), request_reason ) as text_info,
    
///////////////////////////////////////////////////////////////
    @UI.lineItem: [{ position: 30 }]
    @UI.selectionField: [{ position: 200 }]
//    @Consumption.valueHelp: '_ActivityType' //@Consumption.valueHelpDefinition: [{ entity : {name: '_ActivityType', element: 'Activity'  } }]   
    @ObjectModel.text.element: ['activity_name']
    @UI.fieldGroup: [{ qualifier: 'MainGroup', position: 20 }] 
    @UI.textArrangement: #TEXT_ONLY    
    root.activity_type,
        
    @ObjectModel:{ readOnly: true }
    _ActivityType.activity_name,

///////////////////////////////////////////////////////////////    
    @UI.dataPoint: { qualifier: 'StatusData', title: 'Status', criticality: 'StatusCriticality' }
    @UI.lineItem: [{ position: 100, criticality: 'StatusCriticality', importance: #HIGH }]
    @UI.selectionField: [{ position: 100 }]
//    @Consumption.valueHelp: '_Status' 
    @ObjectModel.text.element: ['StatusText']
    @UI.fieldGroup: [{ qualifier: 'State', position: 10 }] 
    root.zz_status,
    
    @ObjectModel:{ readOnly: true }
    _Status.StatusText,
    
    @ObjectModel:{ readOnly: true }
    case zz_status
      when 'O'  then 2    -- 'open'       | 2: yellow colour
      when 'A'  then 3    -- 'accepted'   | 3: green colour
      when 'C'  then 1    -- 'canceled'   | 1: red colour
                else 0    -- 'nothing'    | 0: unknown
    end as StatusCriticality,
    
///////////////////////////////////////////////////////////////
    @UI.lineItem: [{ position: 40 }]
    @UI.fieldGroup: [{ qualifier: 'Dates', position: 40 }]
    @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
//    @ObjectModel: { mandatory: true }
    date_beg,
    
    @UI.lineItem: [{ position: 50 }]
    @UI.fieldGroup: [{ qualifier: 'Dates', position: 50 }]
    @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
//    @ObjectModel: { mandatory: true }
    date_end,
    
    @UI.lineItem: [{ position: 60, label: 'Country' }]
    @UI.fieldGroup: [{ qualifier: 'MainGroup', label: 'Country', position: 60 }]
    @ObjectModel.text.element: ['CountryText']
//    @Consumption.valueHelp: '_Country'
    country_end,
    
    @ObjectModel:{ readOnly: true }
    _Country.CountryText,
    
    @UI.lineItem: [{ position: 70 }]
    @UI.fieldGroup: [{ qualifier: 'MainGroup', position: 70 }]        
    location_end,
    
    @UI.lineItem: [{ position: 80 }]
    @UI.fieldGroup: [{ qualifier: 'MainGroup', position: 80 }]
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    request_reason,
  
///////////////////////////////////////////////////////////////
     

    @ObjectModel:{ readOnly: true }
    @UI.fieldGroup: [{ qualifier: 'PersonGroup', position: 10  }]
    @EndUserText.label: 'Date of Birth'
    coalesce( _Employee.birth_date, _Visitor.birth_date) as birth_date,
    
    @ObjectModel:{ readOnly: true }
    @UI.fieldGroup: [{ qualifier: 'PersonGroup', position: 20  }]
    @EndUserText.label: 'Organization text'
    coalesce( _Employee.orgeh_text, _Visitor.orgeh_text) as orgeh_text,
    
    @ObjectModel:{ readOnly: true }
    @UI.fieldGroup: [{ qualifier: 'Passport', position: 10  }]
    @ObjectModel.text.element: ['CtzCountryText']
    @EndUserText.label: 'Citizenship'
    coalesce( _Employee.citizenship, _Visitor.citizenship ) as citizenship,
    
    @ObjectModel:{ readOnly: true }
    coalesce( _Employee.CountryText, _Visitor.CountryText ) as CtzCountryText,
  
    @ObjectModel:{ readOnly: true }
    @UI.fieldGroup: [{ qualifier: 'Passport', position: 20  }]
    @EndUserText.label: 'Number'
    coalesce( _Employee.passp_number, _Visitor.passp_number ) as passp_number,
      
    @ObjectModel:{ readOnly: true }
    @UI.fieldGroup: [{ qualifier: 'Passport', position: 30  }]
    @EndUserText.label: 'Expiration Date'
    coalesce( _Employee.passp_expiry, _Visitor.passp_expiry ) as passp_expiry,
  
///////////////////////////////////////////////////////////////  
    // Employee cost center info from ftpt_req_account
    @ObjectModel:{ readOnly: true }
    @UI.fieldGroup: [{ qualifier: 'CostGroup', position: 70 }]    
    CostCenter.kostl,    
    @ObjectModel:{ readOnly: true }
    @UI.fieldGroup: [{ qualifier: 'CostGroup', position: 71 }]
    @EndUserText.label: 'Cost Center Text'
    CostCenter.ltext,
    
    @ObjectModel:{ readOnly: true }   
    @UI.fieldGroup: [{ qualifier: 'CostGroup', position: 80 }] 
    CostCenter.posid,
    @ObjectModel:{ readOnly: true }
    @UI.fieldGroup: [{ qualifier: 'CostGroup', position: 81 }]
    @EndUserText.label: 'WBS Element Text'
    CostCenter.post1, 
 
    
///////////////////////////////////////////////////////////////
    
    // Creating info partly from ZZ* fields    
    @ObjectModel:{ readOnly: true }    
    @EndUserText.label: 'Created By'
    @UI.fieldGroup: [{ qualifier: 'TechCreated', position: 10 }]        
    concat_with_space(root.createdby, coalesce( _UserInfoCrt.UserName, ' ' ), 3) as crunm_full,
    
    @UI.selectionField: [{ position: 400 }]
    @Consumption.valueHelp: '_UserInfoCrt'
    root.createdby as crunm,
    
    @ObjectModel:{ readOnly: true }    
    @EndUserText.label: 'Created On'
    @UI.fieldGroup: [{ qualifier: 'TechCreated', position: 20 }]
    @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
    case when zz_crdat = '00000000' then dates else zz_crdat end as crdat,
    @ObjectModel:{ readOnly: true }    
    @EndUserText.label: 'Created at'
    @UI.fieldGroup: [{ qualifier: 'TechCreated', position: 25 }]
    case when zz_crtime = '000000' then times else zz_crtime end as crtime,    
///////////////////////////////////////////////////////////////
    // Changing info from std fields
    @ObjectModel:{ readOnly: true }    
    @EndUserText.label: 'Changed By'
    @UI.fieldGroup: [{ qualifier: 'TechChanged', position: 10 }]
    concat_with_space(uname, coalesce( _UserInfoChg.UserName, ' ' ), 3) as chunm_full,
    
    @UI.selectionField: [{ position: 300 }]
    @Consumption.valueHelp: '_UserInfoChg'
    root.uname as chunm,
    
    @ObjectModel:{ readOnly: true }
    @UI.fieldGroup: [{ qualifier: 'TechChanged', position: 20 }]
    @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
    @UI.selectionField: [{ position: 250 }]
    dates     as chdat,    
    @ObjectModel:{ readOnly: true }
    @UI.fieldGroup: [{ qualifier: 'TechChanged', position: 25 }]
    times     as chtime,
    
    @ObjectModel:{ readOnly: true }
    cast( ' ' as abap.char( 255 ) ) as photo_path,

    @ObjectModel:{ readOnly: true }
    cast( ' ' as abap.char( 255 ) ) as error_message,    
    
///////////////////////////////////////////////////////////////
//    /* Locks */    
//    zz_etag,
//    zz_etag_usr,
//    
           
///////////////////////////////////////////////////////////////
    /* Associations */
    _Employee,
    _Visitor,
     
    _Flight,
    _Hotel,
    _Transport,
    _Attach,
    _CopyFrom,
    
    _Status,
    _ActivityType,
    _Country,
    _UserInfoCrt,
    _UserInfoChg,
    
    /* For SH editing */
    fake_visitor,
    _FakeVisitor,
    
    fake_agency, 
    _FakeAgency,
    
    fake_hotel_id,
    _FakeHotelCatalog,
    
    fake_basis_id,
    _FakeBasis,
    
    fake_airport_id,
    _FakeAirport,
    
    fake_ch_id,
    _FakeCheckPoint
}
