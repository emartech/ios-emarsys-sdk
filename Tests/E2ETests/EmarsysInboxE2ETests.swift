//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

import XCTest

class EmarsysInboxE2ETests: XCTestCase {

    let timeout = 5.0
    var timestamp: String = "2021-02-19 13:07:27"
    enum InboxError: Error {
        case missingTag
        case existingTag
        case missingMessage
        case assertionError(assertionMessage: String)
    }


    func testInboxTags_step0() {
        EmarsysTestUtils.tearDownEmarsys()
    }

    func testInboxTags_step1() {
        let config = EMSConfig.make { builder in
            builder.setMobileEngageApplicationCode("EMS11-C3FD3")
        }

        EmarsysTestUtils.setupEmarsys(with: config, dependencyContainer: nil)

        EmarsysTestUtils.waitForSetPushToken()
        EmarsysTestUtils.waitForSetCustomer()

        sendEvent("iosE2EChangeAppCodeFromNil", timestamp: timestamp)
    }

    func testInboxTags_step2() {
        retry { [unowned self] () in
            let message = filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)

            addTag("testtag", message.id)
        }
    }

    func testInboxTags_step3() {
        var messageWithTag: EMSMessage?

        retry(delay: 5.0) { [unowned self] () in
            messageWithTag = filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)

            if let tags = messageWithTag?.tags, !tags.contains("testtag") {
                throw InboxError.missingTag
            }
        }

        XCTAssertTrue(messageWithTag?.tags?.contains("testtag") ?? false)

        removeTag("testtag", messageWithTag!.id)
    }

    func testInboxTags_step4() {
        var messageWithoutTag: EMSMessage?

        retry { [unowned self] () in
            messageWithoutTag = filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)

            if let tags = messageWithoutTag?.tags, tags.contains("testtag") {
                throw InboxError.existingTag
            }
        }

        XCTAssertFalse(messageWithoutTag?.tags?.contains("testtag") ?? true)
    }

    func testInboxTags_step5() {
        EmarsysTestUtils.tearDownEmarsys()
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
                throw InboxError.assertionError(assertionMessage: "error is not nil")
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
                throw InboxError.assertionError(assertionMessage: "error is not nil")
            }
        }
    }
    
    func addTag(_ tag: String, _ messageId: String) {
        retry { [unowned self] () in
            var returnedError: Error?
            let expectation = XCTestExpectation(description: "waitForAddTag")
            Emarsys.messageInbox.addTag(tag: "testtag", messageId: messageId) { error in
                returnedError = error
                expectation.fulfill()
            }
            if let returnedError {
                throw InboxError.assertionError(assertionMessage: "error is not nil: \(returnedError)")
            }
            _ = XCTWaiter.wait(for: [expectation], timeout: timeout)
        }
    }
    
    func removeTag(_ tag: String, _ messageId: String) {
        retry { [unowned self] () in
            var returnedError: Error?
            let expectation = XCTestExpectation(description: "waitForRemoveTag")
            Emarsys.messageInbox.removeTag(tag: "testtag", messageId: messageId) { error in
                returnedError = error
                expectation.fulfill()
            }
            if let returnedError {
                throw InboxError.assertionError(assertionMessage: "error is not nil: \(returnedError)")
            }
            _ = XCTWaiter.wait(for: [expectation], timeout: timeout)
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
                throw InboxError.missingMessage
            }
        }
        return inboxMessage!
    }

}

extension XCTestCase {

    func retry(retryCount: Int = 10, delay: Double? = 2.0, retryClosure: @escaping () throws -> ()) {
        var error: Error?
        var index = 0
        repeat {
            error = nil
            do {
                index += 1
                try retryClosure()
            } catch let e {
                error = e
                print("Error: \(error!.localizedDescription)")
            }
            if let _ = error, index < retryCount, let delay = delay {
                Thread.sleep(forTimeInterval: delay)
            }
        } while error != nil && index < retryCount

        XCTAssertNil(error)
    }

}
