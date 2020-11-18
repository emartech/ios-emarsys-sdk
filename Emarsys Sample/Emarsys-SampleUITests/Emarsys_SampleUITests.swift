//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import XCTest

class Emarsys_SampleUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInlineInapp_close() {
        let app = XCUIApplication()
        app.launch()
        
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["chevron.left.slash.chevron.right"].tap()
        
        let closeButton = app.webViews.staticTexts["×"]
        
        XCTAssertTrue(closeButton.isHittable)
        
        _ = closeButton.waitForExistence(timeout: 5)
        closeButton.tap()

        XCTAssertFalse(closeButton.isHittable)
    }
    
    func testInlineInapp_appEvent() {
        let app = XCUIApplication()
        app.launch()
        
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["chevron.left.slash.chevron.right"].tap()
        
        let viewidTextField = app.textFields["viewId"]
        viewidTextField.doubleTap()
        viewidTextField.setText(text: "ia", application: app)
        
        let webView = app.webViews
        let thisIsAButton = webView.staticTexts["This is a button!"]
        thisIsAButton.tap()
        
        let alert = app.alerts["DeepLink"]
        _ = alert.waitForExistence(timeout: 5)
        let alertButton = alert.buttons["Cancel"]
        alertButton.tap()
    }
    
    func testInlineInapp_customEvent() {
        #if !targetEnvironment(simulator)
            let app = XCUIApplication()
            app.launch()
            
            let tabBar = app.tabBars["Tab Bar"]
            tabBar.buttons["chevron.left.slash.chevron.right"].tap()
            
            let viewidTextField = app.textFields["viewId"]
            viewidTextField.doubleTap()
            viewidTextField.setText(text: "iace", application: app)
            
            let webView = app.webViews
            let thisIsAButton = webView.staticTexts["click here"]
            thisIsAButton.tap()
            
        #endif
    }
    
    func testPush() {
        #if !targetEnvironment(simulator)
            let app = XCUIApplication()
            app.launch()
            let springBoardApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            let webView = app.webViews
            let iamCloseButton = webView.staticTexts["×"]
            if iamCloseButton.exists {
                iamCloseButton.tap()
            }
            
            let contactFieldValue = app.textFields.element(matching: .textField, identifier: "customFieldValue").firstMatch
            contactFieldValue.tap()
            
            let contactFieldValueText = contactFieldValue.value as? String
            if(contactFieldValueText == nil || contactFieldValueText == "") {
                contactFieldValue.typeText("test@test.com")
            }
            app.buttons["Login"].tap()
            
            sleep(1)
            
            app.buttons["Set"].tap()
            
            let tabBar = app.tabBars["Tab Bar"]
            let mobileEngageButton = tabBar.buttons["phone.fill"]
            let textField = app.textFields.element(matching: .textField, identifier: "CustomEventName")
            let payloadTextField = app.textViews["CustomeEventAttributes"]
            
            let trackButton = app.buttons.element(matching: .button, identifier: "TrackCustomEvent")
            mobileEngageButton.tap()
            textField.tap()
            textField.typeText("emarsys-sdk-push-e2e-test")
            
            let payload = """
            {"eventName":"iOS - rich push","timestamp":"12345"}
            """

            payloadTextField.doubleTap()
            payloadTextField.setText(text: payload, application: app)

            trackButton.tap()
            sleep(1)
            
            springBoardApp.activate()
            let start = springBoardApp.coordinate(
                withNormalizedOffset: CGVector(dx: 0.7, dy: 0.0))
            let finish = springBoardApp.coordinate(
                withNormalizedOffset: CGVector(dx: 0.7, dy: 3.0))
            start.press(forDuration: 0.2, thenDragTo: finish)
            
            sleep(1)
            
    //        var firstNotificationCell = springBoardApp.scrollViews.cells.element(boundBy: 0)
            var firstNotificationCell = springBoardApp.scrollViews["EMARSYS-SAMPLE, now, iOS - rich push, 12345, Attachment"]
    //        firstNotificationCell.tap()
            firstNotificationCell.press(forDuration: 0.5)
            
            let pushButtons = springBoardApp.buttons
            pushButtons["CUSTOM_EVENT"].tap()
            
            sleep(1)
        
            springBoardApp.activate()
            start.press(forDuration: 0.2, thenDragTo: finish)
            
            let triggeredPush = springBoardApp.scrollViews["EMARSYS-SAMPLE, now, customEvent, 12345, Attachment"]

            XCTAssertTrue(triggeredPush.exists)
        #endif
    }
}



extension XCTestCase {
    
    func allowPushNotificationsIfNeeded() {
        addUIInterruptionMonitor(withDescription: "“RemoteNotification” Would Like to Send You Notifications") { (alerts) -> Bool in
            if(alerts.buttons["Allow"].exists){
                alerts.buttons["Allow"].tap();
            }
            return true;
        }
        XCUIApplication().tap()
    }
    
    func waiterResultWithExpectation(_ element: XCUIElement) -> XCTWaiter.Result {
        let myPredicate = NSPredicate(format: "exists == true")
        let myExpectation = XCTNSPredicateExpectation(predicate: myPredicate,
                                                      object: element)
        let result = XCTWaiter().wait(for: [myExpectation], timeout: 6)
        return result
    }
}

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        
        self.typeText(deleteString)
        self.typeText(text)
    }
    
    func setText(text: String, application: XCUIApplication) {
        UIPasteboard.general.string = text
        doubleTap()
        application.menuItems["Paste"].tap()
    }
}
