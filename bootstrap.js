'use strict';

chrome.storage.local.get(['blockedRequests'], function (result) {
    const blockedRequests = result.blockedRequests || [];

    const app = Elm.Main.init({
        node: document.getElementById('app'),
        flags: {
            blockedRequests: blockedRequests,
            currently: (new Date()).getTime()
        }
    });

    chrome.runtime.onMessage.addListener(function (request) {
        if (request.requestBlocked) {
            app.ports.requestBlocked.send(request.requestBlocked);
        }
    });
});