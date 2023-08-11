interface ZIF_C_TV025_AGENCY_C
  public .


  interfaces /BOBF/IF_LIB_CONSTANTS .

  constants:
    BEGIN OF SC_ACTION,
      BEGIN OF ZC_TV025_AGENCY,
 CREATE_ZC_TV025_AGENCY         TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B73471',
 DELETE_ZC_TV025_AGENCY         TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B7B471',
 LOCK_ZC_TV025_AGENCY           TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B67471',
 SAVE_ZC_TV025_AGENCY           TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B83471',
 UNLOCK_ZC_TV025_AGENCY         TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B6B471',
 UPDATE_ZC_TV025_AGENCY         TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B77471',
 VALIDATE_ZC_TV025_AGENCY       TYPE /BOBF/ACT_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B7F471',
      END OF ZC_TV025_AGENCY,
    END OF SC_ACTION .
  constants:
    BEGIN OF SC_ACTION_ATTRIBUTE,
        BEGIN OF ZC_TV025_AGENCY,
        BEGIN OF LOCK_ZC_TV025_AGENCY,
 GENERIC                        TYPE STRING VALUE 'GENERIC',
 EDIT_MODE                      TYPE STRING VALUE 'EDIT_MODE',
 ALL_NONE                       TYPE STRING VALUE 'ALL_NONE',
 SCOPE                          TYPE STRING VALUE 'SCOPE',
 FORCE_INVALIDATION             TYPE STRING VALUE 'FORCE_INVALIDATION',
 LOCK_PARAMETER_BUFFER          TYPE STRING VALUE 'LOCK_PARAMETER_BUFFER',
        END OF LOCK_ZC_TV025_AGENCY,
        BEGIN OF UNLOCK_ZC_TV025_AGENCY,
 GENERIC                        TYPE STRING VALUE 'GENERIC',
 EDIT_MODE                      TYPE STRING VALUE 'EDIT_MODE',
 ALL_NONE                       TYPE STRING VALUE 'ALL_NONE',
 SCOPE                          TYPE STRING VALUE 'SCOPE',
 FORCE_INVALIDATION             TYPE STRING VALUE 'FORCE_INVALIDATION',
 LOCK_PARAMETER_BUFFER          TYPE STRING VALUE 'LOCK_PARAMETER_BUFFER',
        END OF UNLOCK_ZC_TV025_AGENCY,
      END OF ZC_TV025_AGENCY,
    END OF SC_ACTION_ATTRIBUTE .
  constants:
    BEGIN OF SC_ALTERNATIVE_KEY,
      BEGIN OF ZC_TV025_AGENCY,
 DB_KEY                         TYPE /BOBF/OBM_ALTKEY_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B91471',
      END OF ZC_TV025_AGENCY,
    END OF SC_ALTERNATIVE_KEY .
  constants:
    BEGIN OF SC_ASSOCIATION,
      BEGIN OF ZC_TV025_AGENCY,
 LOCK                           TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B65471',
 MESSAGE                        TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B61471',
 PROPERTY                       TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B71471',
      END OF ZC_TV025_AGENCY,
      BEGIN OF ZC_TV025_AGENCY_LOCK,
 TO_PARENT                      TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B89471',
      END OF ZC_TV025_AGENCY_LOCK,
      BEGIN OF ZC_TV025_AGENCY_MESSAGE,
 TO_PARENT                      TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B87471',
      END OF ZC_TV025_AGENCY_MESSAGE,
      BEGIN OF ZC_TV025_AGENCY_PROPERTY,
 TO_PARENT                      TYPE /BOBF/OBM_ASSOC_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B8B471',
      END OF ZC_TV025_AGENCY_PROPERTY,
    END OF SC_ASSOCIATION .
  constants:
    BEGIN OF SC_ASSOCIATION_ATTRIBUTE,
      BEGIN OF ZC_TV025_AGENCY,
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
      END OF ZC_TV025_AGENCY,
    END OF SC_ASSOCIATION_ATTRIBUTE .
  constants:
    SC_BO_KEY  TYPE /BOBF/OBM_BO_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B57471' .
  constants:
    SC_BO_NAME TYPE /BOBF/OBM_NAME VALUE 'ZC_TV025_AGENCY' .
  constants:
    BEGIN OF SC_DETERMINATION,
      BEGIN OF ZC_TV025_AGENCY,
 AGENCY_SAVE                    TYPE /BOBF/DET_KEY VALUE 'B7EC402429AA1EDE86FAE171E7C814F4',
      END OF ZC_TV025_AGENCY,
    END OF SC_DETERMINATION .
  constants:
    SC_MODEL_VERSION TYPE /BOBF/CONF_VERSION VALUE '00000' .
  constants:
    BEGIN OF SC_NODE,
 ZC_TV025_AGENCY                TYPE /BOBF/OBM_NODE_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B5B471',
 ZC_TV025_AGENCY_LOCK           TYPE /BOBF/OBM_NODE_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B63471',
 ZC_TV025_AGENCY_MESSAGE        TYPE /BOBF/OBM_NODE_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B5F471',
 ZC_TV025_AGENCY_PROPERTY       TYPE /BOBF/OBM_NODE_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B6F471',
    END OF SC_NODE .
  constants:
    BEGIN OF SC_NODE_ATTRIBUTE,
      BEGIN OF ZC_TV025_AGENCY,
  NODE_DATA                      TYPE STRING VALUE 'NODE_DATA',
  AGENCY_ID                      TYPE STRING VALUE 'AGENCY_ID',
  AGENCY_NAME                    TYPE STRING VALUE 'AGENCY_NAME',
      END OF ZC_TV025_AGENCY,
    END OF SC_NODE_ATTRIBUTE .
  constants:
    BEGIN OF SC_NODE_CATEGORY,
      BEGIN OF ZC_TV025_AGENCY,
 ROOT                           TYPE /BOBF/OBM_NODE_CAT_KEY VALUE '65D968DD9C7E1EDD9EB9DECA01B5D471',
      END OF ZC_TV025_AGENCY,
    END OF SC_NODE_CATEGORY .
endinterface.
