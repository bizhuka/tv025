interface ZIF_I_TV025_HOTELCATALOG_C
  public .


  interfaces /BOBF/IF_LIB_CONSTANTS .

  constants:
    BEGIN OF SC_ACTION,
      BEGIN OF ZI_TV025_HOTELCATALOG,
 CREATE_ZI_TV025_HOTELCATALOG   TYPE /BOBF/ACT_KEY VALUE 'B7EC402429AA1EEE898AAFEF924915A3',
 DELETE_ZI_TV025_HOTELCATALOG   TYPE /BOBF/ACT_KEY VALUE 'B7EC402429AA1EEE898AAFEF924995A3',
 LOCK_ZI_TV025_HOTELCATALOG     TYPE /BOBF/ACT_KEY VALUE 'B7EC402429AA1EEE898AAFEF924855A3',
 SAVE_ZI_TV025_HOTELCATALOG     TYPE /BOBF/ACT_KEY VALUE 'B7EC402429AA1EEE898AAFEF924A15A3',
 UNLOCK_ZI_TV025_HOTELCATALOG   TYPE /BOBF/ACT_KEY VALUE 'B7EC402429AA1EEE898AAFEF924895A3',
 UPDATE_ZI_TV025_HOTELCATALOG   TYPE /BOBF/ACT_KEY VALUE 'B7EC402429AA1EEE898AAFEF924955A3',
 VALIDATE_ZI_TV025_HOTELCATALOG TYPE /BOBF/ACT_KEY VALUE 'B7EC402429AA1EEE898AAFEF9249D5A3',
      END OF ZI_TV025_HOTELCATALOG,
    END OF SC_ACTION .
  constants:
    BEGIN OF SC_ACTION_ATTRIBUTE,
        BEGIN OF ZI_TV025_HOTELCATALOG,
        BEGIN OF LOCK_ZI_TV025_HOTELCATALOG,
 GENERIC                        TYPE STRING VALUE 'GENERIC',
 EDIT_MODE                      TYPE STRING VALUE 'EDIT_MODE',
 ALL_NONE                       TYPE STRING VALUE 'ALL_NONE',
 SCOPE                          TYPE STRING VALUE 'SCOPE',
 FORCE_INVALIDATION             TYPE STRING VALUE 'FORCE_INVALIDATION',
 LOCK_PARAMETER_BUFFER          TYPE STRING VALUE 'LOCK_PARAMETER_BUFFER',
        END OF LOCK_ZI_TV025_HOTELCATALOG,
        BEGIN OF UNLOCK_ZI_TV025_HOTELCATALOG,
 GENERIC                        TYPE STRING VALUE 'GENERIC',
 EDIT_MODE                      TYPE STRING VALUE 'EDIT_MODE',
 ALL_NONE                       TYPE STRING VALUE 'ALL_NONE',
 SCOPE                          TYPE STRING VALUE 'SCOPE',
 FORCE_INVALIDATION             TYPE STRING VALUE 'FORCE_INVALIDATION',
 LOCK_PARAMETER_BUFFER          TYPE STRING VALUE 'LOCK_PARAMETER_BUFFER',
        END OF UNLOCK_ZI_TV025_HOTELCATALOG,
      END OF ZI_TV025_HOTELCATALOG,
    END OF SC_ACTION_ATTRIBUTE .
  constants:
    BEGIN OF SC_ALTERNATIVE_KEY,
      BEGIN OF ZI_TV025_HOTELCATALOG,
 DB_KEY                         TYPE /BOBF/OBM_ALTKEY_KEY VALUE 'B7EC402429AA1EEE898AB00DDFC655A4',
      END OF ZI_TV025_HOTELCATALOG,
    END OF SC_ALTERNATIVE_KEY .
  constants:
    BEGIN OF SC_ASSOCIATION,
      BEGIN OF ZI_TV025_HOTELCATALOG,
 LOCK                           TYPE /BOBF/OBM_ASSOC_KEY VALUE 'B7EC402429AA1EEE898AAFEF924835A3',
 MESSAGE                        TYPE /BOBF/OBM_ASSOC_KEY VALUE 'B7EC402429AA1EEE898AAFEF9247F5A3',
 PROPERTY                       TYPE /BOBF/OBM_ASSOC_KEY VALUE 'B7EC402429AA1EEE898AAFEF9248F5A3',
      END OF ZI_TV025_HOTELCATALOG,
      BEGIN OF ZI_TV025_HOTELCATALOG_LOCK,
 TO_PARENT                      TYPE /BOBF/OBM_ASSOC_KEY VALUE 'B7EC402429AA1EEE898AAFEF924A75A3',
      END OF ZI_TV025_HOTELCATALOG_LOCK,
      BEGIN OF ZI_TV025_HOTELCATALOG_MESSAGE,
 TO_PARENT                      TYPE /BOBF/OBM_ASSOC_KEY VALUE 'B7EC402429AA1EEE898AAFEF924A55A3',
      END OF ZI_TV025_HOTELCATALOG_MESSAGE,
      BEGIN OF ZI_TV025_HOTELCATALOG_PROPERTY,
 TO_PARENT                      TYPE /BOBF/OBM_ASSOC_KEY VALUE 'B7EC402429AA1EEE898AAFEF924A95A3',
      END OF ZI_TV025_HOTELCATALOG_PROPERTY,
    END OF SC_ASSOCIATION .
  constants:
    BEGIN OF SC_ASSOCIATION_ATTRIBUTE,
      BEGIN OF ZI_TV025_HOTELCATALOG,
        BEGIN OF PROPERTY,
 ALL_NODE_PROPERTY              TYPE STRING VALUE 'ALL_NODE_PROPERTY',
 ALL_NODE_ATTRIBUTE_PROPERTY    TYPE STRING VALUE 'ALL_NODE_ATTRIBUTE_PROPERTY',
 ALL_ASSOCIATION_PROPERTY       TYPE STRING VALUE 'ALL_ASSOCIATION_PROPERTY',
 ALL_ASSOCIATION_ATTRIBUTE_PROP TYPE STRING VALUE 'ALL_ASSOCIATION_ATTRIBUTE_PROP',
 ALL_ACTION_PROPERTY            TYPE STRING VALUE 'ALL_ACTION_PROPERTY',
 ALL_ACTION_ATTRIBUTE_PROPERTY  TYPE STRING VALUE 'ALL_ACTION_ATTRIBUTE_PROPERTY',
 ALL_QUERY_PROPERTY             TYPE STRING VALUE 'ALL_QUERY_PROPERTY',
 ALL_QUERY_ATTRIBUTE_PROPERTY   TYPE STRING VALUE 'ALL_QUERY_ATTRIBUTE_PROPERTY',
 ALL_SUBTREE_PROPERTY           TYPE STRING VALUE 'ALL_SUBTREE_PROPERTY',
        END OF PROPERTY,
      END OF ZI_TV025_HOTELCATALOG,
    END OF SC_ASSOCIATION_ATTRIBUTE .
  constants:
    SC_BO_KEY  TYPE /BOBF/OBM_BO_KEY VALUE 'B7EC402429AA1EEE898AAFEF924755A3' .
  constants:
    SC_BO_NAME TYPE /BOBF/OBM_NAME VALUE 'ZI_TV025_HOTELCATALOG' .
  constants:
    SC_MODEL_VERSION TYPE /BOBF/CONF_VERSION VALUE '00000' .
  constants:
    BEGIN OF SC_NODE,
 ZI_TV025_HOTELCATALOG          TYPE /BOBF/OBM_NODE_KEY VALUE 'B7EC402429AA1EEE898AAFEF924795A3',
 ZI_TV025_HOTELCATALOG_LOCK     TYPE /BOBF/OBM_NODE_KEY VALUE 'B7EC402429AA1EEE898AAFEF924815A3',
 ZI_TV025_HOTELCATALOG_MESSAGE  TYPE /BOBF/OBM_NODE_KEY VALUE 'B7EC402429AA1EEE898AAFEF9247D5A3',
 ZI_TV025_HOTELCATALOG_PROPERTY TYPE /BOBF/OBM_NODE_KEY VALUE 'B7EC402429AA1EEE898AAFEF9248D5A3',
    END OF SC_NODE .
  constants:
    BEGIN OF SC_NODE_ATTRIBUTE,
      BEGIN OF ZI_TV025_HOTELCATALOG,
  NODE_DATA                      TYPE STRING VALUE 'NODE_DATA',
  HOTEL_ID                       TYPE STRING VALUE 'HOTEL_ID',
  HOTEL_CLASS                    TYPE STRING VALUE 'HOTEL_CLASS',
  COUNTRY_ID                     TYPE STRING VALUE 'COUNTRY_ID',
  TOWN_ID                        TYPE STRING VALUE 'TOWN_ID',
  HOTEL_NAME                     TYPE STRING VALUE 'HOTEL_NAME',
  HOTEL_ADDRESS                  TYPE STRING VALUE 'HOTEL_ADDRESS',
  HOTEL_PHONE                    TYPE STRING VALUE 'HOTEL_PHONE',
  HOTEL_COMMENTS                 TYPE STRING VALUE 'HOTEL_COMMENTS',
      END OF ZI_TV025_HOTELCATALOG,
    END OF SC_NODE_ATTRIBUTE .
  constants:
    BEGIN OF SC_NODE_CATEGORY,
      BEGIN OF ZI_TV025_HOTELCATALOG,
 ROOT                           TYPE /BOBF/OBM_NODE_CAT_KEY VALUE 'B7EC402429AA1EEE898AAFEF9247B5A3',
      END OF ZI_TV025_HOTELCATALOG,
    END OF SC_NODE_CATEGORY .
endinterface.
