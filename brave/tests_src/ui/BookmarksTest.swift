/* This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import XCTest

class BookmarksTest: XCTestCase {

    private func addGoogleAsFirstBookmark() {
        let app = XCUIApplication()
        UITestUtils.loadSite(app, "www.google.com")

        let bookmarksAndHistoryPanelButton = app.buttons["Bookmarks and History Panel"]
        bookmarksAndHistoryPanelButton.tap()

        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.buttons["Show Bookmarks"].tap()

        let bmCount = app.tables.element.cells.count
        elementsQuery.buttons["Add Bookmark"].tap()
        XCTAssert(app.tables.element.cells.count > bmCount)
    }

    func testAddDeleteBookmark() {
        UITestUtils.restart(["BRAVE-DELETE-BOOKMARKS"])
        let app = XCUIApplication()

        addGoogleAsFirstBookmark()

        let bookmarksAndHistoryPanelButton = app.buttons["Bookmarks and History Panel"]
        let elementsQuery = app.scrollViews.otherElements

        // close panel
        //app.otherElements["webViewContainer"].tap()
        app.coordinateWithNormalizedOffset(CGVector(dx: UIScreen.mainScreen().bounds.width, dy:  UIScreen.mainScreen().bounds.height)).tap()

        // switch sites
        UITestUtils.loadSite(app, "www.example.com")

        bookmarksAndHistoryPanelButton.tap()

        // load google from bookmarks
        let googleStaticText = app.scrollViews.otherElements.tables["SiteTable"].staticTexts["Google"]
        googleStaticText.tap()

        UITestUtils.waitForGooglePageLoad(self)
        
        // delete the bookmark
        bookmarksAndHistoryPanelButton.tap()
        let toolbarsQuery = elementsQuery.toolbars
        toolbarsQuery.buttons["Edit"].tap()
        let bmCount = app.tables.element.cells.count
        app.scrollViews.otherElements.tables["SiteTable"].buttons["Delete Google"].tap()
        app.scrollViews.otherElements.tables["SiteTable"].buttons["Delete"].tap()
        XCTAssert(app.tables.element.cells.count < bmCount)
        toolbarsQuery.buttons["Done"].tap()
        elementsQuery.navigationBars["Bookmarks"].staticTexts["Bookmarks"].tap()
        elementsQuery.tables["SiteTable"].tap()

        // close the panel
        app.coordinateWithNormalizedOffset(CGVector(dx: UIScreen.mainScreen().bounds.width, dy:  UIScreen.mainScreen().bounds.height)).tap()
    }


    func testFolderNav() {
        UITestUtils.restart(["BRAVE-DELETE-BOOKMARKS"])
        let app = XCUIApplication()

        addGoogleAsFirstBookmark()

        let toolbarsQuery = app.scrollViews.otherElements.toolbars
        toolbarsQuery.buttons["Edit"].tap()
        toolbarsQuery.buttons["New Folder"].tap()

        let collectionViewsQuery = app.alerts["New Folder"].collectionViews
        collectionViewsQuery.textFields["<folder name>"].typeText("Foo")
        app.buttons["OK"].tap()
        app.scrollViews.otherElements.tables["SiteTable"].staticTexts["Google"].tap()


        app.scrollViews.otherElements.tables.staticTexts["Root Folder"].tap()
        app.pickerWheels.elementBoundByIndex(0).adjustToPickerWheelValue("Foo")
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.navigationBars["Bookmarks"].buttons["Bookmarks"].tap()

        XCTAssert(app.scrollViews.otherElements.tables["SiteTable"].cells.count == 1)

        toolbarsQuery.buttons["Done"].tap()

        app.scrollViews.otherElements.tables["SiteTable"].staticTexts["Foo"].tap()
        toolbarsQuery.buttons["Edit"].tap()
        app.scrollViews.otherElements.tables["SiteTable"].staticTexts["Google"].tap()

        // close the panel (bug #448)
        app.coordinateWithNormalizedOffset(CGVector(dx: UIScreen.mainScreen().bounds.width, dy:  UIScreen.mainScreen().bounds.height)).tap()
    }
}
