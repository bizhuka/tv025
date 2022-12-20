sap.ui.controller("ztv025.ext.controller.ListReportExtension", {

  _prefix: 'ztv025::sap.suite.ui.generic.template.ListReport.view.ListReport::ZC_TV025_ROOT--',


  onInit: function () {
    // window._List = this     
  },

  onInitSmartFilterBarExtension: function (oEvent) {
    const _this = this
    const _view = _this.getView()
    const _filterBar = oEvent.getSource() // _view.byId(this._prefix + 'listReportFilter') -> .attachInitialise()

    const userInfoModel = new sap.ui.model.json.JSONModel("/services/userapi/currentUser")
    userInfoModel.attachRequestCompleted(function () {
      const urlUserName = _this.getParameterByName('uname')
      const currentUser = userInfoModel.getData()
      currentUser.name = urlUserName ? urlUserName : currentUser.name.toUpperCase()

      const filterData = _filterBar.getFilterData()

      // Change created & changed filter
      const userFields = ['crunm'] // , 'chunm'
      userFields.forEach(userField => {
        filterData[userField] = {
          "ranges": [{
            "exclude": false,
            "operation": "EQ",
            "keyField": userField,
            "value1": currentUser.name
          }]
        }
      })

      filterData.chdat = {
        "ranges": [{
          "exclude": false,
          "operation": "BT",
          "keyField": "chdat",
          "value1": new Date(new Date().getFullYear(), 0, 1),
          "value2": new Date()
        }]
      }
      _filterBar.setFilterData(filterData)

      _filterBar.fireSearch()

      // Main title
      _view.byId(_this._prefix + 'template::PageVariant-text').setText('Travel request:')
    });
  },

  getParameterByName: function (name, url = window.location.href) {
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
      results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
  },

  onBeforeRebindTableExtension: function (oEvent) {
    var oBindingParams = oEvent.getParameter("bindingParams");
    oBindingParams.parameters = oBindingParams.parameters || {};

    var oSmartTable = oEvent.getSource();
    var oSmartFilterBar = this.byId(oSmartTable.getSmartFilterId());

    if (!oSmartFilterBar instanceof sap.ui.comp.smartfilterbar.SmartFilterBar)
      return

    var oCustomControl = oSmartFilterBar.getControlByKey("visitorFilter");
    if (!oCustomControl instanceof sap.m.Switch)
      return

    if (oCustomControl.getState())
      oBindingParams.filters.push(new sap.ui.model.Filter("pernr", "BT", "90000000", "99999999"))
  },


  beforeSaveExtension: function () {
    debugger
  },

  onBeforeEditExtension: function () {
    debugger
  },

  onChildOpenedExtension: function (oEvent) {
    if (window._objectPage)
      window._objectPage.afterOpen(oEvent)
  },
});