function interceptData() {
    var xhrOverrideScript = document.createElement('script');
    xhrOverrideScript.type = 'text/javascript';
    xhrOverrideScript.innerHTML = `
    (function() {
      console.log("Loading request intercepter...");
      var XHR = XMLHttpRequest.prototype;
      var send = XHR.send;
      var open = XHR.open;

      XHR.open = function(method, url) {
          this.url = url; // the request url
          return open.apply(this, arguments);
      }

      XHR.send = function() {
          this.addEventListener('load', function() {
              console.log("Request intercepted for: " + this.url);
              if (this.url.includes('tpc.googlesyndication.com')) {
                  console.log("Intercepted a request!");
                  var dataDOMElement = document.createElement('div');
                  dataDOMElement.id = '__interceptedData';
                  dataDOMElement.innerText = this.response;
                  dataDOMElement.style.height = 0;
                  dataDOMElement.style.overflow = 'hidden';
                  document.body.appendChild(dataDOMElement);
              }
          });
          return send.apply(this, arguments);
      };
    })();
    `
    document.head.prepend(xhrOverrideScript);
}

function checkForDOM() {
    if (document.body && document.head) {
        interceptData();
    } else {
        setTimeout(checkForDOM, 0);
    }
}

setTimeout(checkForDOM, 0);