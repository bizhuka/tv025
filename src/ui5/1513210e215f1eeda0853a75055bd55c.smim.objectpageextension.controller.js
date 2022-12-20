sap.ui.controller("ztv025.ext.controller.ObjectPageExtension", {
	_template: 'ztv025::sap.suite.ui.generic.template.',
	_details: 'ztv025::sap.suite.ui.generic.template.ObjectPage.view.Details::',
	_prefix: 'ztv025::sap.suite.ui.generic.template.ObjectPage.view.Details::ZC_TV025_ROOT--',
	_table: '::com.sap.vocabularies.UI.v1.LineItem::Table',

	onInit: function () {
		window._objectPage = this
		const _view = this.getView()
		const objectPage = _view.byId(this._prefix + "objectPage")
		if (objectPage)
			objectPage.setUseIconTabBar(true)

		this._doInit()
	},

	onAfterRendering: function () {
		this._doInit()
	},

	_doInit: function () {
		this._setIcons()
		this._prepare_attach();
		this._check_lock_before_press()
		this._screen_before_otput()
	},

	beforeSaveExtension: function () {
		debugger
	},

	onBeforeEditExtension: function () {
		debugger
	},

	afterOpen: function (oEvent) {
		this._doInit()

		if (!oEvent || !oEvent.path)
			return

		this._createMode = oEvent.path.indexOf("/ZC_TV025_ROOT(-)") !== -1
		this._visitor = oEvent.path.indexOf("pernr='9") !== -1

		if (!this.getView().byId(this._prefix + "TechInfo::Section"))
			return
		this.getView().byId(this._prefix + "VisitorIdFacet::FormGroup").setVisible(this._createMode)
		this.getView().byId(this._prefix + "TechInfo::Section").setVisible(!this._createMode)
		this.getView().byId(this._prefix + "DictInfo::Section").setVisible(!this._createMode)
		this.getView().byId(this._prefix + "action::bt_copy_from").setVisible(!this._createMode)

		this.getView().byId(this._prefix + "EmployeeInfo::Section").setVisible(!this._createMode && !this._visitor)
		this.getView().byId(this._prefix + "VisitorInfo::Section").setVisible(!this._createMode && this._visitor)
		this._setIcons()
	},

	_check_lock_before_press: function () {
		const modifyButtons = ['ZC_TV025_ROOT--edit',
			'ZC_TV025_FLIGHT--edit',
			'ZC_TV025_FLIGHT--delete',
			'ZC_TV025_ROOT--FlightInfo::addEntry',
			'ZC_TV025_ROOT--FlightInfo::deleteEntry',

			'ZC_TV025_HOTEL--edit',
			'ZC_TV025_HOTEL--delete',
			'ZC_TV025_ROOT--HotelInfo::addEntry',
			'ZC_TV025_ROOT--HotelInfo::deleteEntry',

			'ZC_TV025_Transport--edit',
			'ZC_TV025_Transport--delete',
			'ZC_TV025_ROOT--TransportInfo::addEntry',
			'ZC_TV025_ROOT--TransportInfo::deleteEntry',

			'ZC_TV025_ROOT--AttachmentInfo::uploadFile',
			'ZC_TV025_ROOT--AttachmentInfo::deleteEntry'
		]
		const _this = this
		const _view = _this.getView()
		const _byId = sap.ui.getCore().byId
		for (const id of modifyButtons) {
			const modifyButton = _byId(_this._details + id)
			if (!modifyButton || modifyButton._std_fm) continue

			modifyButton._std_fm = modifyButton.mEventRegistry.press[0]
			modifyButton.detachPress(modifyButton._std_fm.fFunction, modifyButton._std_fm.oListener)

			modifyButton.attachPress(function (oEvent) {
				const button = oEvent.getSource()
				if (button._go_on) {
					button._go_on = null
					return
				}

				// Fix called 2 times?
				if (window._prev_lock_press && window._prev_lock_press.button === button && (new Date().getTime() - window._prev_lock_press.time) < 1000) {
					oEvent.stopPropagation();
				}
				window._prev_lock_press = {
					button: button,
					time: new Date().getTime()
				}

				const buttonId = button.getId()
				const currentRoot = _view.getBindingContext().getObject()

				_view.getModel().callFunction("/ZC_TV025_ROOTLock", {
					method: "POST",
					urlParameters: {
						"pernr": currentRoot.pernr ? currentRoot.pernr : currentRoot.employee_number,
						"reinr": currentRoot.reinr ? currentRoot.reinr : currentRoot.trip_number,
						"requestvrs": "99",
						"plan_request": "R"
					},
					success: function (oData) {
						if (oData.error_message) {
							sap.m.MessageToast.show(oData.error_message, { duration: 3500 });
							$(".sapMMessageToast").css("background", "#cc1919");
							return
						}

						button._go_on = true
						_view.byId(buttonId).firePress()
					},
					error: function (oError) {
						console.log(oError)
					}
				});

				// oEvent.cancelBubble()
				// oEvent.preventDefault()
				// oEvent.stopImmediatePropagation(); just through an error
				oEvent.stopPropagation();
			});

			modifyButton.attachPress(modifyButton._std_fm.fFunction, modifyButton._std_fm.oListener)
		}
	},

	_screen_before_otput: function () {
		const _this = this
		const _byId = sap.ui.getCore().byId
		for (const id of [
			'ListReport.view.ListReport::ZC_TV025_ROOT--addEntry',
			'ObjectPage.view.Details::ZC_TV025_ROOT--edit',

			'ObjectPage.view.Details::ZC_TV025_FLIGHT--edit',
			'ObjectPage.view.Details::ZC_TV025_ROOT--FlightInfo::addEntry',

			'ObjectPage.view.Details::ZC_TV025_HOTEL--edit',
			'ObjectPage.view.Details::ZC_TV025_ROOT--HotelInfo::addEntry',

			'ObjectPage.view.Details::ZC_TV025_TRANSPORT--edit',
			'ObjectPage.view.Details::ZC_TV025_ROOT--TransportInfo::addEntry',
		]) {

			const editButton = _byId(_this._template + id)
			if (!editButton || editButton._pbo_set) continue
			editButton._pbo_set = true

			editButton.attachPress(function (oEvent) {
				const buttonInfo = oEvent.getSource().getId().split('::')[2].split('--')

				const entityName = buttonInfo[0]
				const pref2 = _this._template + 'ObjectPage.view.Details::' + entityName + '--com.sap.vocabularies.UI.v1.FieldGroup::'

				let field_grp_beg = 'Dates'
				let field_grp_end = 'Dates'
				switch (entityName) {
					case "ZC_TV025_FLIGHT":
						field_grp_beg = 'Departure'
						field_grp_end = 'Arrival'
						break
					case "ZC_TV025_ROOT":
						const editable = _this._createMode || _this._visitor || buttonInfo[1] === 'addEntry'
						for (let field of ['MainGroup::activity_type', 'MainGroup::country_end', 'MainGroup::location_end', 'MainGroup::request_reason', 'Dates::date_beg', 'Dates::date_end'])
							_byId(pref2 + field + '::Field').setEditable(editable)
						break
				}

				_byId(pref2 + field_grp_beg + '::date_beg::Field').setMandatory(true)
				_byId(pref2 + field_grp_end + '::date_end::Field').setMandatory(true)

				_this._toggle_by_checkbox(entityName)
			})
		}
	},

	_toggle_by_checkbox: function (entityName) {
		const toggleList = [
			{
				entity: 'ZC_TV025_FLIGHT',
				checkBox: 'Penalty::penalty_box',
				fields: [{ name: 'Penalty::penalty::Field', nullValue: "0" }, { name: 'Penalty::penalty::Field-sfEdit', nullValue: '' }]
			},
			{
				entity: 'ZC_TV025_HOTEL',
				checkBox: 'Penalty::penalty_check',
				fields: [{ name: 'Penalty::penalty::Field', nullValue: "0" }, { name: 'Penalty::penalty::Field-sfEdit', nullValue: '' }]
			},
			{
				entity: 'ZC_TV025_HOTEL',
				checkBox: 'Transport::assigned_car',
				fields: [{ name: 'Transport::type_car::Field', nullValue: '' }, { name: 'Transport::transport_airport::Field', nullValue: false },
				{ name: 'Transport::transport_hotel::Field', nullValue: false }, { name: 'Transport::transport_price::Field', nullValue: "0" },
				{ name: 'Transport::transport_price::Field-sfEdit', nullValue: '' }]
			}
		]

		const _this = this
		const _byId = sap.ui.getCore().byId
		for (let toggle of toggleList)
			if (toggle.entity === entityName) {
				function _set_field_enabled(item, isChecked) {
					for (let field of item.fields) {
						const input = _byId(_this._details + item.entity + '--com.sap.vocabularies.UI.v1.FieldGroup::' + field.name)
						if (!input)
							continue
						input.setEditable(isChecked)

						if (!isChecked)
							input.setValue(field.nullValue)
					}
				}
				const checkBox = _byId(_this._details + toggle.entity + '--com.sap.vocabularies.UI.v1.FieldGroup::' + toggle.checkBox + '::Field')
				_set_field_enabled(toggle, checkBox.getValue())

				if (!checkBox._toggle) {
					checkBox._toggle = toggle
					checkBox.attachChange(function (oEvent) {
						_set_field_enabled(oEvent.getSource()._toggle, oEvent.mParameters.newValue)
					})
				}
			}
	},

	_setIcons: function () {
		const _this = this
		const pref1 = '::Section-anchor'
		const allIcons = {}

		allIcons['RequestInfo' + pref1] = 'sap-icon://travel-request'
		allIcons['EmployeeInfo' + pref1] = 'sap-icon://employee'
		allIcons['VisitorInfo' + pref1] = 'sap-icon://visits'
		allIcons['FlightInfo' + pref1] = 'sap-icon://flight'
		allIcons['HotelInfo' + pref1] = 'sap-icon://customer-and-supplier'
		allIcons['TransportInfo' + pref1] = 'sap-icon://taxi'
		allIcons['AttachmentInfo' + pref1] = 'sap-icon://attachment'
		allIcons['TechInfo' + pref1] = 'sap-icon://information'
		allIcons['DictInfo' + pref1 + '-internalSplitBtn-textButton'] = 'sap-icon://course-book'
		for (const id in allIcons) {
			const button = _this.getView().byId(_this._prefix + 'objectPage-anchBar-' + _this._prefix + id)
			if (button)
				button.setIcon(sap.ui.core.IconPool.getIconURI(allIcons[id]))
		}
	},

	_prepare_attach: function () {
		const _this = this
		const uploadButtonId = _this._details + 'ZC_TV025_ROOT--AttachmentInfo::uploadFile'

		const toolbar = _this.getView().byId(this._prefix + 'AttachmentInfo::Table::Toolbar')
		if (!toolbar || _this.getView().byId(uploadButtonId))
			return

		const uploadButton = new sap.m.Button({
			id: uploadButtonId,
			tooltip: 'Upload new file',
			icon: "sap-icon://upload",

			press: function () {
				sap.ui.require(["ztv025/ext/controller/FileUploadDialog"], function (FileUploadDialog) {
					if (!_this.fileUploadDialog)
						_this.fileUploadDialog = new FileUploadDialog(_this)
					_this.fileUploadDialog.dialog.open();
				});
			},
		})
		toolbar.insertContent(uploadButton, 2);
	},

	_onCopyFromPress: function () {
		const _this = this
		sap.ui.require(["ztv025/ext/controller/CopyFromDialog"], function (CopyFromDialog) {
			if (!_this.copyFromDialog)
				_this.copyFromDialog = new CopyFromDialog()
			_this.copyFromDialog.initDialog(_this)
			_this.copyFromDialog.dialog.open();
		});
	}
});