'use strict';

var app = Elm.Main.init({
    node: document.getElementById('app')
});

chrome.runtime.onMessage.addListener(
    function(request, sender, sendResponse) {
      if (request.requestBlocked) {
        app.ports.requestBlocked.send(request.requestBlocked.url);
      }
    });