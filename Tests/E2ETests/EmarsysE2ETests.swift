//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import XCTest

class EmarsysE2ETests: XCTestCase {

    let timeout = 2.0

    enum E2EError: Error {
        case missingMessage
        case assertionError(assertionMessage: String)
    }

    var timestamp: String!
    
    override func setUp() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        timestamp = dateFormatter.string(from: Date())
    }
    
    override func tearDown() {
        EmarsysTestUtils.tearDownEmarsys()
    }

    func testChangeApplicationCodeFromNil() throws {
        let config = EMSConfig.make { builder in
        }

        Emarsys.setup(config: config)

        changeAppCode("EMS11-C3FD3")

        setContact(cId: 2575, "test2@test.com")

        sendEvent("iosE2EChangeAppCodeFromNil", timestamp: timestamp)

        _ = filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)
    }

    func testChangeApplicationCode() throws {
        let config = EMSConfig.make { builder in
            builder.setMobileEngageApplicationCode("14C19-A121F")
        }

        Emarsys.setup(config: config)

        changeAppCode("EMS11-C3FD3")

        setContact(cId: 2575, "test2@test.com")

        sendEvent("iosE2EChangeAppCodeFromNil", timestamp: timestamp)

        _ = filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)
    }
    
    func testChangeAppCodeShouldNotViolateDB() throws {
        let config = EMSConfig.make { builder in
        }

        Emarsys.setup(config: config)
        changeAppCode("EMS11-C3FD3")
        
        setContact(cId: 2575, "test2@test.com")

        sendEvent("iosE2EChangeAppCodeFromNil", timestamp: timestamp)
        
        clearContact()
        
        changeAppCode(nil)
        
        sendEvent("iosE2EChangeAppCodeFromNil", timestamp: timestamp)
        
        sendEvent("iosE2EChangeAppCodeFromNil", timestamp: timestamp)
        
        changeAppCode("EMS11-C3FD3")
        
        setContact(cId: 2575, "test2@test.com")
    }

    func changeAppCode(_ code: String?) {
        retry { [unowned self] () in
            var returnedError: Error?
            let changeAppCodeExpectation = XCTestExpectation(description: "waitForResult")
            Emarsys.config.changeApplicationCode(applicationCode: code) { error in
                returnedError = error
                changeAppCodeExpectation.fulfill()
            }
            _ = XCTWaiter.wait(for: [changeAppCodeExpectation], timeout: timeout)

            if let _ = returnedError {
                throw E2EError.assertionError(assertionMessage: "error is not nil")
            }
        }
    }

    func setContact(cId: NSNumber, _ cValue: String) {
        retry { [unowned self] () in
            var returnedError: Error?
            let contactExpectation = XCTestExpectation(description: "waitForResult")
            Emarsys.setContact(contactFieldId: cId, contactFieldValue: cValue) { error in
                returnedError = error
                contactExpectation.fulfill()
            }
            _ = XCTWaiter.wait(for: [contactExpectation], timeout: timeout)
            if let _ = returnedError {
                throw E2EError.assertionError(assertionMessage: "error is not nil")
            }
        }
    }

    func clearContact() {
        retry { [unowned self] () in
            var returnedError: Error?
            let contactExpectation = XCTestExpectation(description: "waitForResult")
            Emarsys.clearContact(completionBlock: { error in
                returnedError = error
                contactExpectation.fulfill()
            })
            _ = XCTWaiter.wait(for: [contactExpectation], timeout: timeout)
            if let _ = returnedError {
                throw E2EError.assertionError(assertionMessage: "error is not nil")
            }
        }
    }

    func sendEvent(_ name: String, timestamp: String) {
        retry { [unowned self] () in
            var returnedError: Error?
            let customEventExpectation = XCTestExpectation(description: "waitForResult")
            Emarsys.trackCustomEvent(eventName: "emarsys-sdk-e2e-inbox-test", eventAttributes: [
                "eventName": name,
                "timestamp": timestamp
            ]) { error in
                returnedError = error
                customEventExpectation.fulfill()
            }
            _ = XCTWaiter.wait(for: [customEventExpectation], timeout: timeout)
            if let _ = returnedError {
                throw E2EError.assertionError(assertionMessage: "error is not nil")
            }
        }
    }

    func filterForInboxMessage(_ title: String, body: String) -> EMSMessage {
        var inboxMessage: EMSMessage?
        retry { [unowned self] () in
            let fetchMessagesExpectation = XCTestExpectation(description: "waitForResult")
            Emarsys.messageInbox.fetchMessages { (inboxResult, error) in
                inboxMessage = inboxResult?.messages.first(where: { (message) -> Bool in
                    return message.title == title && message.body == body
                })
                fetchMessagesExpectation.fulfill()
            }
            _ = XCTWaiter.wait(for: [fetchMessagesExpectation], timeout: timeout)

            guard let _ = inboxMessage else {
                throw E2EError.missingMessage
            }
        }
        return inboxMessage!
    }

}
