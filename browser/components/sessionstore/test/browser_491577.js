/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

function test() {
  /** Test for Bug 491577 **/

  // test setup
  waitForExplicitFinish();

  const REMEMBER = Date.now(), FORGET = Math.random();
  let test_state = {
    windows: [ { tabs: [{ entries: [{ url: "http://example.com/" }] }], selected: 1 } ],
    _closedWindows : [
      // _closedWindows[0]
      {
        tabs: [
          { entries: [{ url: "http://example.com/", title: "title" }] },
          { entries: [{ url: "http://mozilla.org/", title: "title" }] }
        ],
        selected: 2,
        title: FORGET,
        _closedTabs: []
      },
      // _closedWindows[1]
      {
        tabs: [
         { entries: [{ url: "http://mozilla.org/", title: "title" }] },
         { entries: [{ url: "http://example.com/", title: "title" }] },
         { entries: [{ url: "http://mozilla.org/", title: "title" }] },
        ],
        selected: 3,
        title: REMEMBER,
        _closedTabs: []
      },
      // _closedWindows[2]
      {
        tabs: [
          { entries: [{ url: "http://example.com/", title: "title" }] }
        ],
        selected: 1,
        title: FORGET,
        _closedTabs: [
          {
            state: {
              entries: [
                { url: "http://mozilla.org/", title: "title" },
                { url: "http://mozilla.org/again", title: "title" }
              ]
            },
            pos: 1,
            title: "title"
          },
          {
            state: {
              entries: [
                { url: "http://example.com", title: "title" }
              ]
            },
            title: "title"
          }
        ]
      }
    ]
  };
  let remember_count = 1;

  function countByTitle(aClosedWindowList, aTitle)
    aClosedWindowList.filter(function(aData) aData.title == aTitle).length;

  function testForError(aFunction) {
    try {
      aFunction();
      return false;
    }
    catch (ex) {
      return ex.name == "NS_ERROR_ILLEGAL_VALUE";
    }
  }

  gPrefService.setIntPref("browser.sessionstore.max_windows_undo",
                          test_state._closedWindows.length);
  ss.setBrowserState(JSON.stringify(test_state), true);

  let closedWindows = JSON.parse(ss.getClosedWindowData());
  is(closedWindows.length, test_state._closedWindows.length,
     "Closed window list has the expected length");
  is(countByTitle(closedWindows, FORGET),
     test_state._closedWindows.length - remember_count,
     "The correct amount of windows are to be forgotten");
  is(countByTitle(closedWindows, REMEMBER), remember_count,
     "Everything is set up.");

  // all of the following calls with illegal arguments should throw NS_ERROR_ILLEGAL_VALUE
  ok(testForError(function() ss.forgetClosedWindow(-1)),
     "Invalid window for forgetClosedWindow throws");
  ok(testForError(function() ss.forgetClosedWindow(test_state._closedWindows.length + 1)),
     "Invalid window for forgetClosedWindow throws");

  // Remove third window, then first window
  ss.forgetClosedWindow(2);
  ss.forgetClosedWindow(null);

  closedWindows = JSON.parse(ss.getClosedWindowData());
  is(closedWindows.length, remember_count,
     "The correct amount of windows were removed");
  is(countByTitle(closedWindows, FORGET), 0,
     "All windows specifically forgotten were indeed removed");
  is(countByTitle(closedWindows, REMEMBER), remember_count,
     "... and windows not specifically forgetten weren't.");

  // clean up
  gPrefService.clearUserPref("browser.sessionstore.max_windows_undo");
  finish();
}
