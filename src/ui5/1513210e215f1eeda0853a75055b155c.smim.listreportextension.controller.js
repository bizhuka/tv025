sap.ui.controller("ztv025.ext.controller.ListReportExtension", {
  _template: 'ztv025::sap.suite.ui.generic.template.',
  _prefix: 'ztv025::sap.suite.ui.generic.template.ListReport.view.ListReport::ZC_TV025_ROOT--',
  _prefix_obj: 'ztv025::sap.suite.ui.generic.template.ObjectPage.view.Details::ZC_TV025_ROOT--',


  onInit: function () {
    const _this = this
    window._listPage = _this

    _this.getView().byId(_this._prefix + 'responsiveTable').attachItemPress(function (oEvent) {
      const currContext = oEvent.getParameters().listItem.getBindingContext()
      _this.setTabs(currContext.getObject().pernr[0] === '9')

      debugger
      if (window._objectPage)
        window._objectPage.check_ui_state(currContext)
    })
  },

  // onChildOpenedExtension: function (oEvent) {
  //   if (window._objectPage) window._objectPage.afterOpen(oEvent)
  // },

  onAfterRendering: function (oEvent) {
    this._setMessageParser()
    this._initCreateDialog()
    this._initReportMenu()
    this._initMassEdit()
    this._initGroupByEmployee()

    this.setTabs(
      window.location.href.indexOf("pernr='9") !== -1,
      window.location.href.indexOf("/ZC_TV025_ROOT(-)") !== -1 || window.location.href.indexOf("/ZC_TV025_ROOT('id-") !== -1)
  },

  setTabs: function (isVisitor = false, createMode = false) {
    this._createMode = createMode
    this._visitor = isVisitor

    const ids = {}
    ids[this._prefix_obj + 'com.sap.vocabularies.UI.v1.FieldGroup::CostGroup::FormGroup'] = {
      visible: !createMode && !isVisitor
    }
    ids[this._prefix_obj + 'objectPage-anchBar-' + this._prefix_obj + 'EmployeeInfo::Section-anchor'] = {
      text: isVisitor ? 'Visitor info' : 'Employee info'
    }
    // ids[this._prefix_obj + "objectPage-anchBar-" + this._prefix_obj + "TechInfo::Section-anchor"] = { visible: !createMode }
    // ids[this._prefix_obj + "objectPage-anchBar-" + this._prefix_obj + "DictInfo::Section-anchor"] = { visible: !createMode }
    // ids[this._prefix_obj + "VisitorIdFacet::FormGroup"] = { visible: createMode }
    // ids[this._prefix_obj + "action::bt_copy_from"] = { visible:  !createMode }

    const _byId = sap.ui.getCore().byId
    for (id in ids) {
      const field = _byId(id)
      if (!field) continue

      if (ids[id].visible !== undefined) field.setVisible(ids[id].visible)
      if (ids[id].text !== undefined) field.setText(ids[id].text)
    }

    // const firsstButton = _byId(this._prefix_obj + "objectPage-anchBar-" + this._prefix_obj + "RequestInfo::Section-anchor")
    // if (firsstButton) {
    //   _byId(this._prefix_obj + 'objectPage-anchBar').setSelectedButton(firsstButton)
    //   firsstButton.firePress()
    // }

    if (window._objectPage)
      window._objectPage.setIcons()
  },

  _initGroupByEmployee: function () {
    const _this = this
    const _byId = sap.ui.getCore().byId
    const switchId = this._prefix + 'Employee-Grp'
    if (_byId(switchId))
      return

    _byId(this._prefix + 'listReportFilter-btnGo').attachPress(function () {
      _byId(switchId).setState(false)
    })

    const switchField = new sap.m.Switch({
      id: switchId,
      tooltip: 'Group by Employee / Visitor',

      change: function () {
        aSorters = [new sap.ui.model.Sorter('chdat', true), new sap.ui.model.Sorter('chtime', true)]
        if (switchField.getState())
          aSorters.unshift(new sap.ui.model.Sorter('pernr', false, true))
        _byId(_this._prefix + 'responsiveTable').getBinding('items').sort(aSorters)
      }
    })
    _byId(this._prefix + 'template::ListReport::TableToolbar').addContent(switchField)
  },

  _initMassEdit: function () {
    var oEntitySet = this.getView().getModel().getMetaModel().getODataEntitySet("ZC_TV025_ROOT");
    oEntitySet["Org.OData.Capabilities.V1.UpdateRestrictions"] = {
      Updatable: {
        Bool: true
      }
    }
  },

  _setMessageParser: function () {
    const _view = this.getView()
    const model = _view.getModel()
    sap.ui.require(["ztv025/ext/controller/MessageParser"], function (MessageParser) {
      const messageParser = new MessageParser(model.sServiceUrl, model.oMetadata, !!model.bPersistTechnicalMessages)
      model.setMessageParser(messageParser)
    })
  },

  _initCreateDialog: function () {
    const _this = this
    const _view = _this.getView()

    _view.byId(_this._prefix + 'addEntry').attachPress(function () {
      const createDialog = _view.byId(_this._prefix + 'CreateWithDialog')
      if (createDialog && !createDialog.mEventRegistry.afterOpen) createDialog.attachAfterOpen(function () {
        createDialog.setContentWidth('25em')
        const _byId = sap.ui.getCore().byId
        _byId('__form0').setTitle('Create new visitor request')
        _byId('__field5').setMandatory(true)
        _byId('__field6').setMandatory(true)
      })
    })
  },

  _initReportMenu: function () {
    const _this = this
    const _view = _this.getView()

    const menuId = _this._prefix + 'report-xlsx'
    if (_view.byId(menuId))
      return

    const params = {
      id: menuId,
      text: "Report",
      icon: "sap-icon://excel-attachment",

      press: function () {
        const table = _view.byId(_this._prefix + 'responsiveTable')
        const sUrl =
          document.location.origin +
          "/sap/opu/odata/sap/ZC_TV025_ROOT_CDS/ZC_TV025_F4_Copy_From(pernr='00000000',reinr='0000000000')/$value?" +
          table.getBinding("items").sFilterParams
        window.open(sUrl)
      }
    }

    const baseMenu = _view.byId(this._prefix + 'listReport-btnExcelExport')
    if (baseMenu)
      baseMenu.getMenu().addItem(new sap.m.MenuItem(params))
    else  // For sapui5 1.71
      _view.byId(_this._prefix + 'template::ListReport::TableToolbar').addContent(new sap.m.Button(params))
  },

  // beforeMultiEditSaveExtension: function (aContextsToBeUpdated) {
  //   debugger
  // },

  // beforeSaveExtension: function () {
  //   debugger
  // },

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

      filterData.crunm = {
        "ranges": [{
          "exclude": false,
          "operation": "EQ",
          "keyField": "crunm",
          "value1": currentUser.name
        }]
      }
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

      _view.getModel().read("/ZC_TV025_UserInfo('" + currentUser.name + "')", {
        success: function (userInfo) {
          const userInfoText = userInfo.UserName  //+ " (" + currentUser.name + ")"
          const token = _view.byId(_this._prefix + 'listReportFilter-filterItemControl_BASIC-crunm').getTokens()[0]
          token.setText(userInfoText)
          token.setTooltip(userInfoText)
        }
      })
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
  }
});