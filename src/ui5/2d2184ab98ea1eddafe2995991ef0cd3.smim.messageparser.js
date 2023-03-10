sap.ui.define(["sap/ui/model/odata/ODataMessageParser"], function (ODataMessageParser) {
    "use strict";

    return ODataMessageParser.extend("ztv025.ext.controller.MessageParser", {
        parse: function (oResponse, oRequest, mGetEntities, mChangeEntities, bMessageScopeSupported) {
            var _this = this
            ODataMessageParser.prototype.parse.apply(_this, arguments)


            if (oResponse.statusCode < 400 || oResponse.statusCode >= 600)
                return

            const mRequestInfo = {
                request: oRequest,
                response: oResponse,
                url: oRequest.requestUri
            }
            const aMessages = this._parseBody(oResponse, mRequestInfo)

            const allMessages = []
            const allTypes = []
            for (let msg of aMessages) {
                allMessages.push(msg.message)
                allTypes.push(msg.type)
            }

            sap.m.MessageToast.show(allMessages.join('\n'), { duration: 3500 })
            if (allTypes.indexOf("Error") >= 0)
                $(".sapMMessageToast").css("background", "#cc1919")
        }

    });
})