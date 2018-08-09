//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

import XCTest
import Foundation

class MobileEngageSampleAppUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app.launchEnvironment = ["applicationCode": "EMSEC-B103E",
                                 "applicationPassword": "RM1ZSuX8mgRBhQIgOsf6m8bn/bMQLAIb"]
        app.activate()
    }

    func testAnonymAppLogin() {
        eventuallyAssertSuccess(with: "Anonymus login: 💚 OK") {
            app.buttons["anonymousLogin"].tap()
        }
    }

    func testLogin() {
        login(contactFieldId: "123456789", contactFieldValue: "contactFieldValue")
    }

    func testTrackCustomEvent() {
        trackCustomEvent(customEventName: "customEventName")
    }

    func testIAM() {
        login(contactFieldId: "3", contactFieldValue: "test@test.com")


        let closeButton = app.buttons["Close"]
        let closeButtonPredicate = NSPredicate(format: "exists == true")
        let closeExpectation = expectation(for: closeButtonPredicate, evaluatedWith: closeButton, handler: nil)

        trackCustomEvent(customEventName: "Test")

        wait(for: [closeExpectation], timeout: 60)
        XCUIApplication().terminate()
    }

    func testTrackMessageOpen() {
        let sidTextField = app.textFields["sid"]

        clearText(on: sidTextField)
        
        sidTextField.tap()
        sidTextField.typeText("dd8_zXfDdndBNEQi")

        eventuallyAssertSuccess(with: "Message open: 💚 OK") {
            app.buttons["trackMessageOpen"].tap()
        }
    }

    func testAppLogout() {
        eventuallyAssertSuccess(with: "App logout: 💚 OK") {
            app.buttons["logout"].tap()
        }
    }

    func eventuallyAssertSuccess(with successMessage: String, action: () -> ()) {
        let tvInfo = app.textViews[successMessage]
        let predicate = NSPredicate(format: "exists == true")
        let responseExpectation = expectation(for: predicate, evaluatedWith: tvInfo, handler: nil)

        action()

        wait(for: [responseExpectation], timeout: 30)
        XCTAssert(tvInfo.exists)
    }

    func login(contactFieldId: String, contactFieldValue: String) {
        let tfContactFieldId = app.textFields["contactFieldId"]
        let tfContactFieldValue = app.textFields["contactFieldValue"]

        clearText(on: tfContactFieldId)
        clearText(on: tfContactFieldValue)

        tfContactFieldId.tap()
        tfContactFieldId.typeText(contactFieldId)

        tfContactFieldValue.tap()
        tfContactFieldValue.typeText(contactFieldValue)

        eventuallyAssertSuccess(with: "Login: 💚 OK") {
            app.buttons["login"].tap()
        }
    }

    func trackCustomEvent(customEventName: String) {
        let tfCustomEventName = app.textFields["customEventName"]

        clearText(on: tfCustomEventName)

        tfCustomEventName.tap()
        tfCustomEventName.typeText(customEventName)

        eventuallyAssertSuccess(with: "Track custom event: 💚 OK") {
            app.buttons["trackCustomEvent"].tap()
        }
    }

    func clearText(on element: XCUIElement) {
        guard let stringValue = element.value as? String else {
            return
        }
        element.tap()
        
        let deleteString = stringValue.map { _ in
            XCUIKeyboardKey.delete.rawValue
        }.joined(separator: "")

        element.typeText(deleteString)
    }

}
