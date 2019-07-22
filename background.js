const blacklist = [
    // Ads
    "://ade.googlesyndication.com/",
    "://tpc.googlesyndication.com/",
    "://quickresource.eyereturn.com/",
    "://static.criteo.net/",
    "://pix.va.us.criteo.net/img/img",
    "://stackadapt_public.s3.amazonaws.com/",
    "://cdn.stackadapt.com/",
    "://widgets.outbrain.com/",
    "://images.outbrainimg.com/",
    "://libs.outbrain.com/",

    // Tracking
    "://sb.scorecardresearch.com/",
    "://asset.pagefair.com/",
    "://pixel.wp.com/",
    "://www.google-analytics.com/collect",
    "://www.google.ca/ads/ga-audiences",
    "://jadserve.postrelease.com",
    "://pixel.quantserve.com/",
    "://ad.doubleclick.net",
    "://www.facebook.com/tr/",
    "://securepubads.g.doubleclick.net/",
    "://www.google.com/ads/measurement/l",
    "://pagead2.googlesyndication.com/",
    "://bid.g.doubleclick.net/xbbe/pixel",
    "://cat.va.us.criteo.com/delivery/lg.php",
    "://cm.adgrx.com/",
    "://match.prod.bidr.io/",
    "://csm2waycm-atl.netmng.com",
    "://bcp.crwdcntrl.net/",
    "://dpm.demdex.net/",
    "://srv.stackadapt.com/",
    "://evm2.stackadapt.com/",
    "://aax-us-east.amazon-adsystem.com/",
    "://dsum-sec.casalemedia.com/",
    "://log.outbrainimg.com/",
    "://odb.outbrain.com/",
    "://mcdp-sadc1.outbrain.com",
    "://amplify-imp.outbrain.com",
    "://sync.outbrain.com/"
];

chrome.webRequest.onBeforeRequest.addListener(
    function (details) {
        var cancel = false;
        blacklist.forEach(function (entry) {
            cancel = cancel || details.url.indexOf(entry) != -1;
        });
        if (cancel) {
            const message = {url: details.url, date: (new Date()).getTime()};
            chrome.runtime.sendMessage({requestBlocked: message});

            chrome.storage.local.get(['blockedRequests'], function(result) {
                const blockedRequests = result.blockedRequests || [];
                blockedRequests.push(message);
                chrome.storage.local.set({blockedRequests});
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