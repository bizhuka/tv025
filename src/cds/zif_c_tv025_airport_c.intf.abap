interface ZIF_C_TV025_AIRPORT_C
  public .


  interfaces /BOBF/IF_LIB_CONSTANTS .

  constants:
    BEGIN OF SC_ACTION,
      BEGIN OF ZC_TV025_AIRPORT,
 CREATE_ZC_TV025_AIRPORT        TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165581454',
 DELETE_ZC_TV025_AIRPORT        TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165589454',
 LOCK_ZC_TV025_AIRPORT          TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165575454',
 SAVE_ZC_TV025_AIRPORT          TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165591454',
 UNLOCK_ZC_TV025_AIRPORT        TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165579454',
 UPDATE_ZC_TV025_AIRPORT        TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165585454',
 VALIDATE_ZC_TV025_AIRPORT      TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DD716558D454',
      END OF ZC_TV025_AIRPORT,
    END OF SC_ACTION .
  constants:
    BEGIN OF SC_ACTION_ATTRIBUTE,
        BEGIN OF ZC_TV025_AIRPORT,
        BEGIN OF LOCK_ZC_TV025_AIRPORT,
 GENERIC                        TYPE STRING VALUE 'GENERIC',
 EDIT_MODE                      TYPE STRING VALUE 'EDIT_MODE',
 ALL_NONE                       TYPE STRING VALUE 'ALL_NONE',
 SCOPE                          TYPE STRING VALUE 'SCOPE',
 FORCE_INVALIDATION             TYPE STRING VALUE 'FORCE_INVALIDATION',
 LOCK_PARAMETER_BUFFER          TYPE STRING VALUE 'LOCK_PARAMETER_BUFFER',
        END OF LOCK_ZC_TV025_AIRPORT,
        BEGIN OF UNLOCK_ZC_TV025_AIRPORT,
 GENERIC                        TYPE STRING VALUE 'GENERIC',
 EDIT_MODE                      TYPE STRING VALUE 'EDIT_MODE',
 ALL_NONE                       TYPE STRING VALUE 'ALL_NONE',
 SCOPE                          TYPE STRING VALUE 'SCOPE',
 FORCE_INVALIDATION             TYPE STRING VALUE 'FORCE_INVALIDATION',
 LOCK_PARAMETER_BUFFER          TYPE STRING VALUE 'LOCK_PARAMETER_BUFFER',
        END OF UNLOCK_ZC_TV025_AIRPORT,
      END OF ZC_TV025_AIRPORT,
    END OF SC_ACTION_ATTRIBUTE .
  constants:
    BEGIN OF SC_ALTERNATIVE_KEY,
      BEGIN OF ZC_TV025_AIRPORT,
 DB_KEY                         TYPE /BOBF/OBM_ALTKEY_KEY VALUE '65D968DD9C7E1EDD9EB9DD716559F454',
      END OF ZC_TV025_AIRPORT,
    END OF SC_ALTERNATIVE_KEY .
  constants:
    BEGIN OF SC_ASSOCIATION,
      BEGIN OF ZC_TV025_AIRPORT,
 LOCK                           TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165573454',
 MESSAGE                        TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DD716556F454',
 PROPERTY                       TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DD716557F454',
      END OF ZC_TV025_AIRPORT,
      BEGIN OF ZC_TV025_AIRPORT_LOCK,
 TO_PARENT                      TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165597454',
      END OF ZC_TV025_AIRPORT_LOCK,
      BEGIN OF ZC_TV025_AIRPORT_MESSAGE,
 TO_PARENT                      TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165595454',
      END OF ZC_TV025_AIRPORT_MESSAGE,
      BEGIN OF ZC_TV025_AIRPORT_PROPERTY,
 TO_PARENT                      TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165599454',
      END OF ZC_TV025_AIRPORT_PROPERTY,
    END OF SC_ASSOCIATION .
  constants:
    BEGIN OF SC_ASSOCIATION_ATTRIBUTE,
      BEGIN OF ZC_TV025_AIRPORT,
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
      END OF ZC_TV025_AIRPORT,
    END OF SC_ASSOCIATION_ATTRIBUTE .
  constants:
    SC_BO_KEY  TYPE /BOBF/OBM_BO_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165565454' .
  constants:
    SC_BO_NAME TYPE /BOBF/OBM_NAME VALUE 'ZC_TV025_AIRPORT' .
  constants:
    SC_MODEL_VERSION TYPE /BOBF/CONF_VERSION VALUE '00000' .
  constants:
    BEGIN OF SC_NODE,
 ZC_TV025_AIRPORT               TYPE /BOBF/OBM_NODE_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165569454',
 ZC_TV025_AIRPORT_LOCK          TYPE /BOBF/OBM_NODE_KEY VALUE '65D968DD9C7E1EDD9EB9DD7165571454',
 ZC_TV025_AIRPORT_MESSAGE       TYPE /BOBF/OBM_NODE_KEY VALUE '65D968DD9C7E1EDD9EB9DD716556D454',
 ZC_TV025_AIRPORT_PROPERTY      TYPE /BOBF/OBM_NODE_KEY VALUE '65D968DD9C7E1EDD9EB9DD716557D454',
    END OF SC_NODE .
  constants:
    BEGIN OF SC_NODE_ATTRIBUTE,
      BEGIN OF ZC_TV025_AIRPORT,
  NODE_DATA                      TYPE STRING VALUE 'NODE_DATA',
  AIRPORT_ID                     TYPE STRING VALUE 'AIRPORT_ID',
  TOWN                           TYPE STRING VALUE 'TOWN',
  COUNTRY_ID                     TYPE STRING VALUE 'COUNTRY_ID',
  AIRPORT_NAME                   TYPE STRING VALUE 'AIRPORT_NAME',
  LATITUDE                       TYPE STRING VALUE 'LATITUDE',
  LONGITUDE                      TYPE STRING VALUE 'LONGITUDE',
      END OF ZC_TV025_AIRPORT,
    END OF SC_NODE_ATTRIBUTE .
  constants:
    BEGIN OF SC_NODE_CATEGORY,
      BEGIN OF ZC_TV025_AIRPORT,
 ROOT                           TYPE /BOBF/OBM_NODE_CAT_KEY VALUE '65D968DD9C7E1EDD9EB9DD716556B454',
      END OF ZC_TV025_AIRPORT,
    END OF SC_NODE_CATEGORY .
endinterface.
