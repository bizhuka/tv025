*&---------------------------------------------------------------------*
* Boy Scout Rule: "Always leave the camp better than you found it."
* Even when it seems easier to burn down an entire camp...
*&---------------------------------------------------------------------*
REPORT zr_tv025_travel_admin MESSAGE-ID ztv_022.

INCLUDE zi_tv025_travel_data.
INCLUDE zi_tv025_travel_pref.
INCLUDE zi_tv025_travel_tree.
INCLUDE zi_tv025_travel_dict.
INCLUDE zi_tv025_travel_ui_container.
INCLUDE zi_tv025_travel_tab.
INCLUDE zi_tv025_travel_1_editor.  " screen - 100 (Main) & 101, 109
INCLUDE zi_tv025_travel_2_flight.  " screen - 102, 200
INCLUDE zi_tv025_travel_3_hotel.   " screen - 103, 300
INCLUDE zi_tv025_travel_4_transp.  " screen - 104, 400
INCLUDE zi_tv025_travel_5_attach.  " screen - 105
INCLUDE zi_tv025_travel_empl_request.
INCLUDE zi_tv025_travel_visi_request.

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

INITIALIZATION.
  go_dict   = NEW #( ).
  go_model  = zcl_tv025_model=>get_instance( ).
  go_editor = CAST #( lcl_tab=>get( lcl_tab=>ms_tab-editor ) ).


START-OF-SELECTION.
  go_editor->start_of_selection( ).
