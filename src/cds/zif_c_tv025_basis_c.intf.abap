interface ZIF_C_TV025_BASIS_C
  public .


  interfaces /BOBF/IF_LIB_CONSTANTS .

  constants:
    BEGIN OF SC_ACTION,
      BEGIN OF ZC_TV025_BASIS,
 CREATE_ZC_TV025_BASIS          TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC44745F',
 DELETE_ZC_TV025_BASIS          TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC44F45F',
 LOCK_ZC_TV025_BASIS            TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC43B45F',
 SAVE_ZC_TV025_BASIS            TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC45745F',
 UNLOCK_ZC_TV025_BASIS          TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC43F45F',
 UPDATE_ZC_TV025_BASIS          TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC44B45F',
 VALIDATE_ZC_TV025_BASIS        TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC45345F',
      END OF ZC_TV025_BASIS,
    END OF SC_ACTION .
  constants:
    BEGIN OF SC_ACTION_ATTRIBUTE,
        BEGIN OF ZC_TV025_BASIS,
        BEGIN OF LOCK_ZC_TV025_BASIS,
 GENERIC                        TYPE STRING VALUE 'GENERIC',
 EDIT_MODE                      TYPE STRING VALUE 'EDIT_MODE',
 ALL_NONE                       TYPE STRING VALUE 'ALL_NONE',
 SCOPE                          TYPE STRING VALUE 'SCOPE',
 FORCE_INVALIDATION             TYPE STRING VALUE 'FORCE_INVALIDATION',
 LOCK_PARAMETER_BUFFER          TYPE STRING VALUE 'LOCK_PARAMETER_BUFFER',
        END OF LOCK_ZC_TV025_BASIS,
        BEGIN OF UNLOCK_ZC_TV025_BASIS,
 GENERIC                        TYPE STRING VALUE 'GENERIC',
 EDIT_MODE                      TYPE STRING VALUE 'EDIT_MODE',
 ALL_NONE                       TYPE STRING VALUE 'ALL_NONE',
 SCOPE                          TYPE STRING VALUE 'SCOPE',
 FORCE_INVALIDATION             TYPE STRING VALUE 'FORCE_INVALIDATION',
 LOCK_PARAMETER_BUFFER          TYPE STRING VALUE 'LOCK_PARAMETER_BUFFER',
        END OF UNLOCK_ZC_TV025_BASIS,
      END OF ZC_TV025_BASIS,
    END OF SC_ACTION_ATTRIBUTE .
  constants:
    BEGIN OF SC_ALTERNATIVE_KEY,
      BEGIN OF ZC_TV025_BASIS,
 DB_KEY                         TYPE /BOBF/OBM_ALTKEY_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC46545F',
      END OF ZC_TV025_BASIS,
    END OF SC_ALTERNATIVE_KEY .
  constants:
    BEGIN OF SC_ASSOCIATION,
      BEGIN OF ZC_TV025_BASIS,
 LOCK                           TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC43945F',
 MESSAGE                        TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC43545F',
 PROPERTY                       TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC44545F',
      END OF ZC_TV025_BASIS,
      BEGIN OF ZC_TV025_BASIS_LOCK,
 TO_PARENT                      TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC45D45F',
      END OF ZC_TV025_BASIS_LOCK,
      BEGIN OF ZC_TV025_BASIS_MESSAGE,
 TO_PARENT                      TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC45B45F',
      END OF ZC_TV025_BASIS_MESSAGE,
      BEGIN OF ZC_TV025_BASIS_PROPERTY,
 TO_PARENT                      TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC45F45F',
      END OF ZC_TV025_BASIS_PROPERTY,
    END OF SC_ASSOCIATION .
  constants:
    BEGIN OF SC_ASSOCIATION_ATTRIBUTE,
      BEGIN OF ZC_TV025_BASIS,
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
      END OF ZC_TV025_BASIS,
    END OF SC_ASSOCIATION_ATTRIBUTE .
  constants:
    SC_BO_KEY  TYPE /BOBF/OBM_BO_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC42B45F' .
  constants:
    SC_BO_NAME TYPE /BOBF/OBM_NAME VALUE 'ZC_TV025_BASIS' .
  constants:
    SC_MODEL_VERSION TYPE /BOBF/CONF_VERSION VALUE '00000' .
  constants:
    BEGIN OF SC_NODE,
 ZC_TV025_BASIS                 TYPE /BOBF/OBM_NODE_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC42F45F',
 ZC_TV025_BASIS_LOCK            TYPE /BOBF/OBM_NODE_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC43745F',
 ZC_TV025_BASIS_MESSAGE         TYPE /BOBF/OBM_NODE_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC43345F',
 ZC_TV025_BASIS_PROPERTY        TYPE /BOBF/OBM_NODE_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC44345F',
    END OF SC_NODE .
  constants:
    BEGIN OF SC_NODE_ATTRIBUTE,
      BEGIN OF ZC_TV025_BASIS,
  NODE_DATA                      TYPE STRING VALUE 'NODE_DATA',
  BASIS_ID                       TYPE STRING VALUE 'BASIS_ID',
  HOTEL_BASIS                    TYPE STRING VALUE 'HOTEL_BASIS',
  HOTEL_BASIS_TXT                TYPE STRING VALUE 'HOTEL_BASIS_TXT',
      END OF ZC_TV025_BASIS,
    END OF SC_NODE_ATTRIBUTE .
  constants:
    BEGIN OF SC_NODE_CATEGORY,
      BEGIN OF ZC_TV025_BASIS,
 ROOT                           TYPE /BOBF/OBM_NODE_CAT_KEY VALUE '65D968DD9C7E1EDD9EB9DDF3EC43145F',
      END OF ZC_TV025_BASIS,
    END OF SC_NODE_CATEGORY .
endinterface.