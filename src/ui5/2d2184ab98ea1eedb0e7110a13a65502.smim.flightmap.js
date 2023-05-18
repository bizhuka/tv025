sap.ui.define([
    'sap/ui/base/Object',
    'ztv025/utils/ol',
    'sap/ui/core/HTML'
], function (Object, olLib, HTML) {
    "use strict";

    return Object.extend("ztv025.ext.controller.FlightMap", {
        owner: null,
        // data: {
        //     Spots: [],
        //     Routes: []
        // },

        constructor: function () {
            // this.oModel = new sap.ui.model.json.JSONModel()
            // this.oModel.setData(this.data)
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

                    // const oMap = sap.ui.xmlfragment("ztv025.ext.fragment.FlightMap", _this)
                    // oMap.setModel(_this.oModel, "Inputless")

                    const oMap = new HTML({
                        content: '<div id="id_map" class="content" style="width: 100%; height: 100%;"/>',

                        preferDOM: false,

                        afterRendering: function (oEvent) {
                            if (!oEvent.getParameters()["isPreservedDOM"]) {
                                var attribution = new ol.control.Attribution({
                                    collapsible: false
                                });

                                // Load fo map
                                $('head').append('<link rel="stylesheet" type="text/css" href="../css/ol.css">')

                                this._map = new ol.Map({
                                    controls: ol.control.defaults({ attribution: false }).extend([attribution]),
                                    layers: [
                                        new ol.layer.Tile({
                                            source: new ol.source.OSM({
                                                // url: 'https://tile.openstreetmap.be/osmbe/{z}/{x}/{y}.png', attributions: [ ol.source.OSM.ATTRIBUTION, 'Tiles courtesy of <a href="https://geo6.be/">GEO-6</a>' ], maxZoom: 18
                                            })
                                        })
                                    ],
                                    target: 'id_map',
                                    view: new ol.View({
                                        center: ol.proj.fromLonLat([4.35247, 50.84673]),
                                        maxZoom: 18,
                                        zoom: 3.7
                                    })
                                })

                                const styles = {
                                    route: new ol.style.Style({
                                        stroke: new ol.style.Stroke({
                                            width: 3,
                                            // color: [237, 212, 0, 0.8]
                                        })
                                    }),
                                    icon: new ol.style.Style({
                                        image: new ol.style.Icon({
                                            anchor: [0.5, 1],
                                            src: './img/marker.png'
                                        }),

                                        text: new ol.style.Text({
                                            font: '1.5rem Calibri,sans-serif',
                                            overflow: true,
                                            fill: new ol.style.Fill({
                                                color: '#000'
                                            }),
                                            stroke: new ol.style.Stroke({
                                                color: '#fff',
                                                width: 3
                                            })
                                        })
                                    })
                                };

                                this.custom_layer = new ol.layer.Vector({
                                    source: new ol.source.Vector({
                                        features: []
                                    }),
                                    style: function (feature) {
                                        const result = styles[feature.get('type')]

                                        const text = feature.get('text')
                                        if (text) {
                                            result.getText().setText(text)

                                            //if(feature.get('cancelled')) result.getText().getStroke().setColor('#f00')
                                        }

                                        const color = feature.get('color')
                                        if (color) result.getStroke().setColor(color)

                                        return result
                                    }
                                })
                                this._map.addLayer(this.custom_layer);
                                // var $DomRef = oEvent.getSource().$();
                                // $DomRef.on("click", function(oEvent) {  this.addColorBlockAtCursor($DomRef, oEvent, 64, 8);  }.bind(this));
                            }
                        }.bind(this)
                    })
                    mapSubSection.addMoreBlock(oMap)
                }
                this._readMap()
            }.bind(this))
        },

        _readMap: function () {
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
                    const source = this.custom_layer.getSource()
                    const features = source.getFeatures()

                    // _this.data.Spots = [] _this.data.Routes = []
                    features.forEach((feature) => {
                        source.removeFeature(feature);
                    })

                    let lastAirport = ''
                    let i = 1
                    for (let item of data.results) {
                        const beg = [Number(item.beg_longitude), Number(item.beg_latitude)]
                        const end = [Number(item.end_longitude), Number(item.end_latitude)]
                        const arr = [beg, end]
                        source.addFeature(new ol.Feature({
                            type: 'route',
                            geometry: new ol.geom.LineString(arr).transform('EPSG:4326', 'EPSG:3857'), // "EPSG:900913"
                            color: item.cancelled ? [255, 0, 0, 0.8] : [117, 148, 34, 0.8]
                        }))

                        // _this.data.Routes.push({
                        //     pos: `${Number(item.beg_longitude)};${Number(item.beg_latitude)};0; ${Number(item.end_longitude)};${Number(item.end_latitude)};0`,
                        //     color: item.cancelled ? "rgb(255,0,0)" : "rgb(117,148,34)"
                        // })

                        if (lastAirport !== item.airport_beg)
                            // _this.data.Spots.push({
                            //     pos: `${Number(item.beg_longitude)};${Number(item.beg_latitude)};0`,
                            //     type: "Success",
                            //     tooltip: item.AirportNameBeg + " - " + item.date_beg.toLocaleDateString(),
                            //     text: `${item.airport_beg} ${i++}`,
                            // })
                            source.addFeature(new ol.Feature({
                                geometry: new ol.geom.Point(ol.proj.fromLonLat(beg)),
                                type: 'icon',
                                text: `${item.AirportNameBeg} ${item.date_beg.toLocaleDateString()} №${i++}`,
                            }))


                        // _this.data.Spots.push({
                        //     pos: `${Number(item.end_longitude)};${Number(item.end_latitude)};0`,
                        //     type: item.cancelled ? "Error" : "Success",
                        //     tooltip: item.AirportNameEnd + " - " + item.date_end.toLocaleDateString(),
                        //     text: `${item.airport_end} ${i++}`,
                        // })
                        source.addFeature(new ol.Feature({
                            geometry: new ol.geom.Point(ol.proj.fromLonLat(end)),
                            type: 'icon',
                            cancelled: item.cancelled,
                            text: `${item.AirportNameEnd} ${item.date_end.toLocaleDateString()} №${i++}`
                        }))

                        lastAirport = item.airport_end
                    }

                    if (data.results.length > 0) {
                        let item = data.results[0]
                        //     sap.ui.getCore().byId('idVbmMap').setCenterPosition(`${Number(item.beg_longitude)};${Number(item.beg_latitude)}`)
                        this._map.getView().setCenter(ol.proj.fromLonLat([Number(item.beg_longitude), Number(item.beg_latitude)]))
                    }

                    // _this.oModel.updateBindings()
                    source.changed()
                }.bind(this)
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