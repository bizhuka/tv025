*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS: lcl_editor DEFINITION DEFERRED,
       lcl_dict   DEFINITION DEFERRED.

DATA:
  go_model  TYPE REF TO zcl_tv025_model,
  go_editor TYPE REF TO lcl_editor,
  go_dict   TYPE REF TO lcl_dict.

TABLES:
  zss_tv025_head,
  zss_tv025_head_ui,

  zdtv025_flight,
  zdtv025_flight_ui,

  zdtv025_hotel,
  zdtv025_hotel_ui,

  zdtv025_transp,
  zdtv025_transp_ui.

TYPES:
  ts_db_key  TYPE zcl_tv025_model=>ts_db_key,
  tt_db_key  TYPE STANDARD TABLE OF ts_db_key WITH DEFAULT KEY,
  ts_command TYPE zcl_tv025_model=>ts_command.


INTERFACE lif_request.
  METHODS:
    get_db_key RETURNING VALUE(rs_db_key) TYPE ts_db_key,

    after_created IMPORTING is_db_key TYPE ts_db_key.
ENDINTERFACE.

CONSTANTS:
  BEGIN OF mc_pai_cmd,
    tab_request_info     TYPE syucomm VALUE 'TABS_0110',
    tab_pers_info        TYPE syucomm VALUE 'TABS_0111',
    tab_tech_info        TYPE syucomm VALUE 'TABS_0112',

    tab_flight           TYPE syucomm VALUE 'TABS_0102',
    tab_hotel            TYPE syucomm VALUE 'TABS_0103',
    tab_transport        TYPE syucomm VALUE 'TABS_0104',
    tab_attachments      TYPE syucomm VALUE 'TABS_0105',


    open_request         TYPE syucomm VALUE 'OPEN_REQUEST',
    new_employee_request TYPE syucomm VALUE 'LCL_EMPLOYEE_REQUEST',
    new_visitor_request  TYPE syucomm VALUE 'LCL_VISITOR_REQUEST',
    save                 TYPE syucomm VALUE 'SAVE',
    back                 TYPE syucomm VALUE 'CRET',
    copy                 TYPE syucomm VALUE 'COPY',
    add_tab              TYPE syucomm VALUE 'ADD_TAB',
    show_user_prefs      TYPE syucomm VALUE 'SHOW_USER_PREFS',

    report               TYPE syucomm VALUE 'REPORT',
    dict                 TYPE syucomm VALUE 'DICTIONARY',
    on_f4                TYPE syucomm VALUE 'ON_F4',

    alv_insert           TYPE syucomm VALUE 'ALV_INSERT',
    alv_delete           TYPE syucomm VALUE 'ALV_DELETE',

*    alv_change       TYPE syucomm VALUE 'ALV_CHANGE',
*    alv_display      TYPE syucomm VALUE 'ALV_DISPLAY',
    " both above operations
    alv_edit             TYPE syucomm VALUE 'ALV_EDIT',
  END OF mc_pai_cmd,

  BEGIN OF mc_event,
    open TYPE string VALUE 'OPEN',
    "close       TYPE string VALUE 'CLOSE',
    "before_save TYPE string VALUE 'BEFORE_SAVE',
    "after_save  TYPE string VALUE 'AFTER_SAVE',
  END OF mc_event.

CONTROLS:
  tabs TYPE TABSTRIP.

DATA:
  BEGIN OF g_tabs,
    subscreen   TYPE sydynnr,
    prog        TYPE syrepid VALUE 'ZR_TV025_TRAVEL_ADMIN',
    pressed_tab TYPE syucomm VALUE mc_pai_cmd-tab_request_info,
  END OF g_tabs.
