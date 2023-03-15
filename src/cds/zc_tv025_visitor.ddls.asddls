@AbapCatalog.sqlViewName: 'zvctv025_visitor'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Visitor'
@VDM.viewType: #CONSUMPTION

@Search.searchable: true 
define view ZC_TV025_VISITOR as select from zi_tv025_visitor as _main

association [0..1] to ZC_PY000_Country as _Country on _Country.land1 = _main.citizenship
 
{      
      @ObjectModel:{ mandatory: true, readOnly: true, text.element: ['ename'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7, ranking:#HIGH }  
      @UI.fieldGroup: [{ qualifier: 'VisitorGroup', position: 05 }]
      key pernr,
      
      @UI.fieldGroup: [{ qualifier: 'VisitorGroup', position: 10 }]       
      birth_date,
      
      @UI.fieldGroup: [{ qualifier: 'VisitorGroup', position: 20 }]
      ename,

      @UI.fieldGroup: [{ qualifier: 'VisitorGroup', position: 25, label: 'Badge Number' }]
      badge,
            
      @UI.fieldGroup: [{ qualifier: 'VisitorGroup', position: 30 }]
      orgeh_text,
      
      @UI.fieldGroup: [{ qualifier: 'Passport', position: 10  }]
      @ObjectModel.text.element: ['CountryText']
      @Consumption.valueHelp: '_Country'
      citizenship,
      _Country.CountryText,
      
      @UI.fieldGroup: [{ qualifier: 'Passport', position: 20  }]
      passp_number,
      
      @UI.fieldGroup: [{ qualifier: 'Passport', position: 30  }]
      passp_expiry,
      
      _Country
}
