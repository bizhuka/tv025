@AbapCatalog.sqlViewName: 'zvitv025_person'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Person'

define view ZI_TV025_PERSON as select from pa0001 as Person {

  key Person.pernr,  
  Person.ename,
  Person.begda,
  Person.endda,
  Person.sprps,
  Person.orgeh,
  Person.ansvh,
  cast (substring( cast( tstmp_current_utctimestamp() as abap.char(17) ), 1, 8 ) as abap.dats) as datum    
}