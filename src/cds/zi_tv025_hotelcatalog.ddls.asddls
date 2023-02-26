@AbapCatalog.sqlViewName: 'zvitv025_hotelca'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hotel catalog'

@ObjectModel: {
    writeActivePersistence: 'ZDTV025_HOTEL_CA',
    transactionalProcessingEnabled: true,
    compositionRoot: true,
    
    createEnabled: true,
    updateEnabled: true,
//    deleteEnabled: true,
    
    semanticKey: ['hotel_id']
}

define view ZI_TV025_HotelCatalog as select from zdtv025_hotel_ca {
    key hotel_id,
    
    hotel_class,
    country_id,
    town_id,
    hotel_name,
    hotel_address,
    hotel_phone,
    hotel_comments
}
