'use strict';

chrome.storage.local.get(['blockedRequests'], function (result) {
    const blockedRequests = result.blockedRequests || [];

    const blockedUrls = blockedRequests.map(function (message) {
        return message.url;
    });

    const app = Elm.Main.init({
        node: document.getElementById('app'),
        flags: blockedUrls
    });

    chrome.runtime.onMessage.addListener(function (request) {
        if (request.requestBlocked) {
            app.ports.requestBlocked.send(request.requestBlocked.url);
        }
    });
});

