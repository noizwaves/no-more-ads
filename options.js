// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

'use strict';

chrome.runtime.onMessage.addListener(
  function(request, sender, sendResponse) {
    if (request.requestBlocked) {
      const div = document.createElement("div");
      div.innerText = "Blocked request to " + request.requestBlocked.url;
      div.className = "blocked-request";
      document.body.appendChild(div);
    }
  });