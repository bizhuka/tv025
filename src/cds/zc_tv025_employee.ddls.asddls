@AbapCatalog.sqlViewName: 'zvctv025_empl'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee'
@VDM.viewType: #CONSUMPTION


define view ZC_TV025_Employee as select from ZI_TV025_PERSON as Employee

join pa0002  as p2 on p2.pernr = Employee.pernr
                  and p2.sprps = ' '
                  and p2.begda <= Employee.datum
                  and p2.endda >= Employee.datum   

join t542t   as Contract on Contract.ansvh = Employee.ansvh 
                        and Contract.molga = 'KZ'
                        and Contract.spras = $session.system_language

// Inner join has valid org structure                      
join hrp1000 as Orgunit on Orgunit.objid =  Employee.orgeh
                       and Orgunit.plvar = '01'
                       and Orgunit.otype = 'O' 
                       and Orgunit.begda <= Employee.datum
                       and Orgunit.endda >= Employee.datum
                       
left outer join pa0290 as Passport on Passport.pernr = Employee.pernr
                  and Passport.sprps = ' '
                  and Passport.subty = 'KZFP'
                  and Passport.begda <= Employee.datum
                  and Passport.endda >= Employee.datum 
                  
left outer join ZC_PY000_Country as _Country on _Country.land1 = p2.gblnd
 
{
  @UI.identification: [{ position: 10 }] 
  key Employee.pernr,
  
  @UI.identification: [{ position: 20 }]
  Employee.ename,
  
  @ObjectModel:{ readOnly: true }
  @UI.fieldGroup: [{ qualifier: 'PersonGroup', position: 20 }]
  @EndUserText.label: 'Date of Birth'
  cast( p2.gbdat as abap.dats) as birth_date,
  
  @ObjectModel:{ readOnly: true }
  @UI.fieldGroup: [{ qualifier: 'PersonGroup', position: 30 }]
  @EndUserText.label: 'Organization text'
  cast( Contract.atx as abap.char(25)) as orgeh_text,  
      
  // Passport info  
  @ObjectModel.text.element: ['CountryText']
  p2.gblnd as citizenship,
  _Country.CountryText,    
  
  @EndUserText.label: 'Number' 
  cast(concat(concat(Passport.seria, Passport.seri0), Passport.nomer) as abap.char(25)) as passp_number,
  Passport.daten as passp_expiry,
  
  Employee.begda,
  Employee.endda,
  Employee.sprps,
  Employee.orgeh,
  Employee.ansvh,
  Employee.datum
  
} where Employee.begda <= Employee.datum
    and Employee.endda >= Employee.datum
    and Employee.sprps = ' '
