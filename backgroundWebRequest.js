const blacklist = [
    "://ade.googlesyndication.com/",
    "://tpc.googlesyndication.com/",
    "://quickresource.eyereturn.com/",
    "://static.criteo.net/",
];

chrome.webRequest.onBeforeRequest.addListener(
    function (details) {
        // console.log(">> Request details for " + details.url, details);
        var cancel = false;
        blacklist.forEach(function (entry) {
            cancel = cancel || details.url.indexOf(entry) != -1;
        });
        if (cancel) {
            console.log(">> Blocking Request " + details.url, details);
        }
        return { cancel: cancel };
    },
    { urls: ["<all_urls>"] },
    ["blocking"]
);

console.log("Loaded backgroundWebRequest.js");