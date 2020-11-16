//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import XCTest

class Emarsys_SampleUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInlineInappClose() {
        
        let app = XCUIApplication()
        app.launch()
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["chevron.left.slash.chevron.right"].tap()
        app.webViews.webViews.webViews.staticTexts["×"].tap()
        
    }

}
