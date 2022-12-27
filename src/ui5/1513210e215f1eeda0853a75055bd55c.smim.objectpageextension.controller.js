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
	},

	onAfterRendering: function () {
		this.check_ui_state()
	},

	check_ui_state: function (currContext) {
		if (currContext)
			this._currContext = currContext

		this.setIcons()
		this._prepare_attach()
		this._check_lock_before_press()

		this._check_lock_before_press()
		this._toggle_by_checkbox()
	},

	_check_lock_before_press: function () {
		const editButtons = ['ZC_TV025_ROOT--edit',
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
		const _byId = sap.ui.getCore().byId
		for (const id of editButtons) {
			const editButton = _byId(this._details + id)
			if (!editButton || editButton._std_fm) continue

			editButton._std_fm = editButton.mEventRegistry.press[0]
			editButton.detachPress(editButton._std_fm.fFunction, editButton._std_fm.oListener)

			// Set before standard handler
			editButton.attachPress(this._check_lock_handler, this)
			editButton.attachPress(editButton._std_fm.fFunction, editButton._std_fm.oListener)
		}
	},

	_check_lock_handler: function (oEvent) {
		const _this = this
		if (_this._currContext && (_this._currContext.getObject().zz_status === 'A' || _this._currContext.getObject().zz_status === 'C')) {
			sap.m.MessageToast.show('Only requests with "Open" status can be editable', { duration: 3500 });
			$(".sapMMessageToast").css("background", "#cc1919");
			throw 'Cancel edit event' // oEvent.cancelBubble() preventDefault()
		}

		const button = oEvent.getSource()
		if (button._go_on) {
			button._go_on = null
			return
		}

		// Fix called 2 times?
		if (window._prev_lock_press && window._prev_lock_press.button === button && (new Date().getTime() - window._prev_lock_press.time) < 1000) {
			throw 'Cancel edit event'
		}
		window._prev_lock_press = {
			button: button,
			time: new Date().getTime()
		}

		const _view = _this.getView()
		const currentRoot = _view.getBindingContext().getObject()
		const lockInfo = {
			pernr: currentRoot.pernr ? currentRoot.pernr : currentRoot.employee_number,
			reinr: currentRoot.reinr ? currentRoot.reinr : currentRoot.trip_number,

			success: function () {
				const editButton = _view.byId(button.getId())
				_this._set_mandatory_editable(editButton)
				editButton._go_on = true
				editButton.firePress()
			},

			error: function (message) {
				sap.m.MessageToast.show(message, { duration: 3500 });
				$(".sapMMessageToast").css("background", "#cc1919");
				console.error(message)
			}
		}

		if (window.location.hostname === 'localhost')
			_this.lock_by_bopf_test_only(lockInfo)
		else
			_this.lock_by_bsp_productive(lockInfo)

		throw 'Cancel edit event'
	},

	lock_by_bopf_test_only: function (lockInfo) {
		this.getView().getModel().callFunction("/ZC_TV025_ROOTLock", {
			method: "POST",
			urlParameters: {
				"pernr": lockInfo.pernr,
				"reinr": lockInfo.reinr,
				"requestvrs": "99",
				"plan_request": "R"
			},
			success: function (result) {
				if (result.error_message) {					
					lockInfo.error(result.error_message)
					return
				}
				lockInfo.success()
			},
			error: function (message) {
				lockInfo.error(message)
			}
		})
	},

	lock_by_bsp_productive: function (lockInfo) {
		$.ajax({
			type: 'GET',
			url: window.location.origin + '/sap/bc/bsp/sap/ztv025/lock.json?pernr=' + lockInfo.pernr + '&reinr=' + lockInfo.reinr,
			dataType: 'json',
			success: function (result) {
				if (result.message === 'OK') {
					lockInfo.success()
					return
				}
				lockInfo.error(result.message)
			},
			error: function (message) {
				lockInfo.error(message)
			}
		})
	},

	_set_mandatory_editable: function (editButton) {
		const _this = this
		const _byId = sap.ui.getCore().byId
		const buttonInfo = editButton.getId().split('::')[2].split('--')

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
				const visitor = window.location.href.indexOf("pernr='9") !== -1
				const editable = visitor // _this._createMode || 
				for (let field of ['MainGroup::activity_type', 'MainGroup::country_end', 'MainGroup::location_end', 'MainGroup::request_reason', 'Dates::date_beg', 'Dates::date_end'])
					_byId(pref2 + field + '::Field').setEditable(editable)
				break
		}

		_byId(pref2 + field_grp_beg + '::date_beg::Field').setMandatory(true)
		_byId(pref2 + field_grp_end + '::date_end::Field').setMandatory(true)
	},

	_toggle_by_checkbox: function () {
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
		for (let toggle of toggleList) {
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
			if (!checkBox) continue

			let isChecked = checkBox.getValue()
			if (isChecked === null) isChecked = false

			_set_field_enabled(toggle, isChecked)

			if (!checkBox._toggle) {
				checkBox._toggle = toggle
				checkBox.attachChange(function (oEvent) {
					_set_field_enabled(oEvent.getSource()._toggle, oEvent.mParameters.newValue)
				})
			}

		}
	},

	setIcons: function () {
		const _this = this
		const pref1 = '::Section-anchor'
		const allIcons = {}

		allIcons['RequestInfo' + pref1] = 'sap-icon://travel-request'
		allIcons['EmployeeInfo' + pref1] = 'sap-icon://employee' // 'sap-icon://visits'
		allIcons['FlightInfo' + pref1] = 'sap-icon://flight'
		allIcons['HotelInfo' + pref1] = 'sap-icon://customer-and-supplier'
		allIcons['TransportInfo' + pref1] = 'sap-icon://taxi'
		allIcons['AttachmentInfo' + pref1] = 'sap-icon://attachment'
		allIcons['TechInfo' + pref1] = 'sap-icon://message-information'
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