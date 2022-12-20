sap.ui.define([
    'sap/ui/base/Object'
], function (Object) {
    "use strict";

    return Object.extend("ztv025.ext.controller.CopyFromDialog", {
        owner: null,
        dialog: null,
        currentRoot: null,
        templateRoot: null,

        initDialog: function (owner) {
            const _this = this

            _this.owner = owner
            const source = owner.getView().getBindingContext().getObject()
            _this.currentRoot = {
                pernr: source.pernr,
                reinr: source.reinr
            }

            if (!this.dialog) {
                _this.dialog = sap.ui.xmlfragment("copyFrom", "ztv025.ext.fragment.CopyFromDialog", _this);
                _this.owner.getView().addDependent(_this.dialog);
            }
            console.log(this.currentRoot)
        },

        _onInitialise: function (field) {
            switch (field) {
                case 'pernr':
                    sap.ui.getCore().byId("copyFrom--pernr").setValue('00000000')
                    sap.ui.getCore().byId("copyFrom--pernr-text").setText('')
                case 'reinr':
                    sap.ui.getCore().byId("copyFrom--reinr").setValue('0000000000')
                    sap.ui.getCore().byId("copyFrom--reinr-input").setValue('')
                    break
            }
        },

        _onTripSelected: function (oEvent) {
            const _this = this
            const _view = _this.owner.getView()
            // Template Ids
            const l_pernr = _view.getBindingContext().getObject().pernr
            const l_reinr = _view.getBindingContext().getObject().reinr

            _this.templateRoot = null
            _view.getModel().read("/ZC_TV025_ROOT(pernr='" + l_pernr + "',reinr='" + l_reinr + "',requestvrs='99',plan_request='R')", {
                urlParameters: {
                    "$expand": "to_Flight,to_Hotel,to_Transport",
                    "$select": "pernr,reinr,to_Flight,to_Hotel,to_Transport",
                },
                success: function (root) {
                    _this.templateRoot = root
                    _this._setCheckBox("cb_flight", "Flight: 0 items", root.to_Flight.results.length)
                    _this._setCheckBox("cb_hotel", "Hotel: 0 items", root.to_Hotel.results.length)
                    _this._setCheckBox("cb_transport", "Transport: 0 items", root.to_Transport.results.length)
                },
                error: function (oError) {
                    console.log(oError)
                }
            });
        },

        _setCheckBox(id, text, length) {
            const checkBox = sap.ui.getCore().byId("copyFrom--" + id)
            checkBox.setText(text.replace("0", length))
            checkBox.setSelected(!!length)
            checkBox.setEnabled(!!length)
        },

        _OnOkPress: function () {
            const cb_flight = sap.ui.getCore().byId("copyFrom--cb_flight")
            const cb_hotel = sap.ui.getCore().byId("copyFrom--cb_hotel")
            const cb_transport = sap.ui.getCore().byId("copyFrom--cb_transport")
            const cb_keep_previous = sap.ui.getCore().byId("copyFrom--cb_keep_previous")

            if (!this.templateRoot || (
                (!cb_flight.getSelected() || this.templateRoot.to_Flight.results.length === 0) &&
                (!cb_hotel.getSelected() || this.templateRoot.to_Hotel.results.length === 0) &&
                (!cb_transport.getSelected() || this.templateRoot.to_Transport.results.length === 0))) {
                sap.m.MessageToast.show("Select template with table parts", {
                    duration: 3500
                })
                $(".sapMMessageToast").css("background", "#cc1919")
                return
            }

            const _this = this
            const _view = _this.owner.getView()
            _view.getModel().callFunction("/ZC_TV025_ROOTCopy_from", {
                method: "POST",
                urlParameters: {
                    "pernr": _this.currentRoot.pernr,
                    "reinr": _this.currentRoot.reinr,
                    "requestvrs": "99",
                    "plan_request": "R",

                    "SrcPernr": _this.templateRoot.pernr,
                    "SrcReinr": _this.templateRoot.reinr,

                    "KeepPrevious": cb_keep_previous.getSelected() ? "true" : "false",
                    "CopyFlight": cb_flight.getSelected() ? "true" : "false",
                    "CopyHotel": cb_hotel.getSelected() ? "true" : "false",
                    "CopyTransport": cb_transport.getSelected() ? "true" : "false",
                },
                success: function (oData, oResponse) {
                    const allOk = oResponse.statusText = "OK" && oData.pernr && oData.pernr === _this.currentRoot.pernr
                    if (allOk) {
                        _this._refreshGrid('FlightInfo')
                        _this._refreshGrid('HotelInfo')
                        _this._refreshGrid('TransportInfo')
                    }

                    sap.m.MessageToast.show(allOk ? "Rows successfully copied" : "Error occurred during coping", {
                        duration: 3500
                    })
                    if (!allOk)
                        $(".sapMMessageToast").css("background", "#cc1919")

                },
                error: function (oError) {
                    console.log(oError)
                }
            });


            this._clearAll()
        },

        _refreshGrid: function (name) {
            const smartTable = this.owner.getView().byId(this.owner._prefix + name + '::Table')
            if (smartTable)
                smartTable.rebindTable();
        },

        _OnCancelPress: function () {
            this._clearAll()
        },

        _clearAll: function () {
            const _this = this
            const _view = _this.owner.getView()

            // Set data back
            const sPath = _view.getBindingContext().getPath()
            _view.getModel().setProperty(sPath + "/pernr", this.currentRoot.pernr)
            _view.getModel().setProperty(sPath + "/reinr", this.currentRoot.reinr)

            this.dialog.close()
            this.dialog.destroy()
            this.dialog = null
        }

    });
}
);