sap.ui.define([
    'sap/ui/base/Object'
], function (Object) {
    "use strict";

    return Object.extend("ztv025.ext.controller.FileUploadDialog", {
        owner: null,
        dialog: null,

        constructor: function (owner) {
            this.owner = owner

            this.dialog = sap.ui.xmlfragment("ztv025.ext.fragment.FileUploadDialog", this);
            owner.getView().addDependent(this.dialog);
        },

        handleCancelPress: function (oEvent) {
            this.dialog.close();
            //this.dialog.destroy();
            //this.dialog = null;
        },

        handleUploadComplete: function (oEvent) {
            //var oResourceBundle = this.getView().getModel("i18n").getResourceBundle();
            var oResponse = oEvent.getParameters("response");
            const xmlDoc = new DOMParser().parseFromString(oResponse.responseRaw, "text/xml");

            var isOk = true
            try {
                var sMsg = xmlDoc.getElementsByTagName('d:message')[0].childNodes[0].nodeValue
            } catch (error) {
                sMsg = xmlDoc.getElementsByTagName('message')[0].childNodes[0].nodeValue
                isOk = false
            }
            
            const smartTable = this.owner.getView().byId(this.owner._prefix + 'AttachmentInfo::Table')
            smartTable.rebindTable();

            // this.dialog.destroy();
            // this.dialog = null;

            sap.m.MessageToast.show(sMsg, {
                duration: 3500
            });
            if (!isOk)
                $(".sapMMessageToast").css("background", "#cc1919");
        },

        handleUploadPress: function (oEvent) {
            //perform upload
            //var oModel = this.getView().getModel();
            //var oResourceBundle = this.getView().getModel("i18n").getResourceBundle();
            var oFileUploader = sap.ui.getCore().byId("fupImport");
            var sMsg = "";

            //check file has been entered
            var sFile = oFileUploader.getValue();
            if (!sFile) {
                sMsg = "Please select a file first";
                sap.m.MessageToast.show(sMsg);
                return;
            }

            this._addTokenToUploader(oEvent.getSource().getBindingContext().getObject());
            oFileUploader.upload();
            this.dialog.close();
        },

        _addTokenToUploader: function (bindingObj) {
            //Add header parameters to file uploader.
            var oDataModel = this.owner.getView().getModel();
            var sTokenForUpload = oDataModel.getSecurityToken();
            var oFileUploader = sap.ui.getCore().byId("fupImport");
            var oHeaderParameter = new sap.ui.unified.FileUploaderParameter({
                name: "X-CSRF-Token",
                value: sTokenForUpload
            });

            var oHeaderSlug = new sap.ui.unified.FileUploaderParameter({
                name: "SLUG",
                value: bindingObj.pernr + "|" + bindingObj.reinr + "|" +
                    encodeURIComponent(oFileUploader.getValue())
            });

            //Header parameter need to be removed then added.
            oFileUploader.removeAllHeaderParameters();
            oFileUploader.addHeaderParameter(oHeaderParameter);

            oFileUploader.addHeaderParameter(oHeaderSlug);
            //set upload url
            var sUrl = oDataModel.sServiceUrl + "/ZC_TV025_Attach";
            oFileUploader.setUploadUrl(sUrl);
        }
    });
}
);