sap.ui.define([
    'sap/ui/base/Object'
], function (Object) {
    "use strict";

    return Object.extend("ztv025.ext.controller.FlightMap", {
        owner: null,
        data: {
            Spots: [],
            Routes: []
        },

        constructor: function () {
            this.oModel = new sap.ui.model.json.JSONModel()
            this.oModel.setData(this.data)
        },

        init: function (owner) {
            const _this = this
            _this.owner = owner

            const id = owner._prefix + "FlightInfoMap::SubSection"
            const mapSubSection = owner.getView().byId(id)
            if (!mapSubSection)
                return

            if (_this.hideButton && mapSubSection.__inited)
                _this.hideButton.firePress()

            // Add label 1 time
            if (mapSubSection.getMoreBlocks().length > 0)
                return
            mapSubSection.addMoreBlock(new sap.m.Label({ width: "100%" }))

            _this.hideButton = owner.getView().byId(id + "--seeLess")
            _this.hideButton.setText("Hide map")

            const seeMore = owner.getView().byId(id + "--seeMore")
            seeMore.setText('Show map')

            seeMore.attachPress(function () {
                // Replace label with map
                if (!mapSubSection.__inited) {
                    mapSubSection.__inited = true
                    mapSubSection.removeAllMoreBlocks()

                    const oMap = sap.ui.xmlfragment("ztv025.ext.fragment.FlightMap", _this)
                    oMap.setModel(_this.oModel, "Inputless")
                    mapSubSection.addMoreBlock(oMap)
                }
                _this._readMap()
            })
        },

        _readMap: function () {
            const _this = this

            let l_pernr, l_reinr
            if (this.owner._currContext) {
                const obj = this.owner._currContext.getObject()
                l_pernr = obj.pernr
                l_reinr = obj.reinr
            } else {
                l_pernr = this._getFromUrl("pernr='", 8)
                l_reinr = this._getFromUrl("reinr='", 10)
            }

            this.owner.getView().getModel().read("/ZC_TV025_ROOT(pernr='" + l_pernr + "',reinr='" + l_reinr + "',requestvrs='99',plan_request='R')/to_Flight", {
                urlParameters: {
                    "$select": "airport_beg,AirportNameBeg,airport_end,AirportNameEnd,beg_latitude,beg_longitude,end_latitude,end_longitude,cancelled,date_beg,date_end",
                },
                success: function (data) {
                    _this.data.Spots = []
                    _this.data.Routes = []
                    let lastAirport = ''
                    let i = 1
                    for (let item of data.results) {
                        _this.data.Routes.push({
                            pos: `${Number(item.beg_longitude)};${Number(item.beg_latitude)};0; ${Number(item.end_longitude)};${Number(item.end_latitude)};0`,
                            color: item.cancelled ? "rgb(255,0,0)" : "rgb(117,148,34)"
                        })

                        if (lastAirport !== item.airport_beg)
                            _this.data.Spots.push({
                                pos: `${Number(item.beg_longitude)};${Number(item.beg_latitude)};0`,
                                type: "Success",
                                tooltip: item.AirportNameBeg + " - " + item.date_beg.toLocaleDateString(),
                                text: `${item.airport_beg} ${i++}`,
                            })

                        _this.data.Spots.push({
                            pos: `${Number(item.end_longitude)};${Number(item.end_latitude)};0`,
                            type: item.cancelled ? "Error" : "Success",
                            tooltip: item.AirportNameEnd + " - " + item.date_end.toLocaleDateString(),
                            text: `${item.airport_end} ${i++}`,
                        })
                        lastAirport = item.airport_end
                    }

                    if (data.results.length > 0) {
                        let item = data.results[0]
                        sap.ui.getCore().byId('idVbmMap').setCenterPosition(`${Number(item.beg_longitude)};${Number(item.beg_latitude)}`)
                    }
                    _this.oModel.updateBindings()
                }
            });

        },

        _getFromUrl: function (name, count) {
            const ind = window.location.href.indexOf(name)
            if (ind === -1)
                return null
            return window.location.href.substr(ind + name.length, count)
        }
    })
}
);