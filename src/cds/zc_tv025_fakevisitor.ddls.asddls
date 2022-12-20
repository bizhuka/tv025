@AbapCatalog.sqlViewName: 'zvctv025_fvisit'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fake Visitor'
@VDM.viewType: #CONSUMPTION

@ObjectModel:{
    semanticKey: 'pernr',

    //Delegate the CRUD
    transactionalProcessingDelegated: true,
  
    //To define what all actions are enabled
    createEnabled: true,
//    deleteEnabled: true,
    updateEnabled: true
}
@Search.searchable: true

@ZABAP.virtualEntity: 'ZCL_V_TV025_GET_ALL'

define view ZC_TV025_FakeVisitor as select from zi_tv025_visitor as _main


association [0..1] to ZC_TV025_Country as _Country on _Country.land1 = _main.citizenship

{
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7, ranking:#HIGH }
      @ObjectModel:{ readOnly: true, text.element: ['ename'] }        
      @UI.lineItem: [{ position: 10, importance: #HIGH }] // , label: 'Visitor ID'
      @UI.fieldGroup: [{ qualifier: 'VisitorGroup', position: 05 }]
      key pernr,
      
      @UI.lineItem: [{ position: 20 }]      
      @UI.fieldGroup: [{ qualifier: 'VisitorGroup', position: 10 }]
      birth_date,
      
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }      
      @UI.fieldGroup: [{ qualifier: 'VisitorGroup', position: 20 }]
      ename,
      
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8  }
      @UI.lineItem: [{ position: 40 }]
      @UI.fieldGroup: [{ qualifier: 'VisitorGroup', position: 30 }]
      orgeh_text,      
      
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9  }
      @ObjectModel.text.element: ['CountryText']
      @Consumption.valueHelp: '_Country'
      @UI.lineItem: [{ position: 50 }]  
      @UI.fieldGroup: [{ qualifier: 'Passport', position: 10  }]  
      citizenship,
      
      @ObjectModel.readOnly: true
      _Country.CountryText,
      
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
      @UI.lineItem: [{ position: 60 }]  
      @UI.fieldGroup: [{ qualifier: 'Passport', position: 20  }]    
      passp_number,
      
      @UI.lineItem: [{ position: 70 }]      
      @UI.fieldGroup: [{ qualifier: 'Passport', position: 30  }]
      passp_expiry,
      
      _Country
}
