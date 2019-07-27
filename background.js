/* Functions */

const loadBlocklist = function (url, domains) {
    fetch(url)
        .then((response) => response.text())
        .then((body) => {
            const lines = body.split("\n");
            lines.forEach(line => {
                if (line.startsWith("0.0.0.0 ")) {
                    const domain = line.substr("0.0.0.0 ".length);
                    if (domain !== "0.0.0.0") {
                        domains.push(domain.trim());
                    }
                }
            });
        });
}

const isBlocked = function (details) {
    let cancel = false;
    domains.forEach(function (domain) {
        const entry = "://" + domain;
        cancel = cancel || details.url.indexOf(entry) != -1;
    });
    return cancel
};

const addToStore = function (message, blockedRequests) {
    blockedRequests.push(message);
    chrome.storage.local.set({blockedRequests});
};

const clearStore = function (blockedRequests) {
    blockedRequests.splice(0, blockedRequests.length);
    chrome.storage.local.set({blockedRequests});
};


/* State */

const domains = [];

const blockedRequests = [];


/* Main */

loadBlocklist(chrome.runtime.getURL("blocklists/hosts"), domains);

chrome.runtime.onInstalled.addListener(() => clearStore(blockedRequests));

chrome.webRequest.onBeforeRequest.addListener(
    function (details) {
        const cancel = isBlocked(details);
        if (cancel) {
            chrome.tabs.get(details.tabId, function(tab) {
                const host = new URL(details.url).host;

                const pageUrl = tab.url;
                const pageHost = new URL(pageUrl).host;
                const pageTitle = tab.title;

                const message = {
                    url: details.url,
                    host: host,
                    date: Math.floor(details.timeStamp),
                    pageHost: pageHost,
                    pageUrl: pageUrl,
                    pageTitle: pageTitle,
                };

                chrome.runtime.sendMessage({requestBlocked: message});

                addToStore(message, blockedRequests);
            });
        }
        return {cancel: cancel};
    },
    {urls: ["<all_urls>"]},
    ["blocking"]
);

chrome.browserAction.onClicked.addListener((function () {
    chrome.tabs.create({url: chrome.extension.getURL('dashboard.html')}, function () {
        console.log('Opened Dashboard');
    });
}));

console.log("Loaded background.js");