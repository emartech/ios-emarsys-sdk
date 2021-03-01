//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

import XCTest

class EmarsysInboxE2ETests: XCTestCase {

    let timeout = 2.0
    var timestamp: String = "2021-02-19 13:07:27"
    enum InboxError: Error {
        case missingTag
        case existingTag
        case missingMessage
    }

    func testInboxTags_step0() {
        EmarsysTestUtils.tearDownEmarsys()
    }

    func testInboxTags_step1() {
        let config = EMSConfig.make { builder in
            builder.setMobileEngageApplicationCode("EMS11-C3FD3")
            builder.setContactFieldId(2575)
        }

        Emarsys.setup(with: config)

        setContact("test@test.com")

        sendEvent("iosE2EChangeAppCodeFromNil", timestamp: timestamp)
    }

    func testInboxTags_step2() {
        retry { [unowned self] () in

            let message = try filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)

            Emarsys.messageInbox.addTag("testtag", forMessage: message.id)
        }
    }

    func testInboxTags_step3() {
        var messageWithTag: EMSMessage?

        retry { [unowned self] () in

            messageWithTag = try filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)

            if let tags = messageWithTag?.tags, !tags.contains("testtag") {
                throw InboxError.missingTag
            }
        }

        XCTAssertTrue(messageWithTag?.tags?.contains("testtag") ?? false)

        Emarsys.messageInbox.removeTag("testtag", fromMessage: messageWithTag?.id ?? "")
    }

    func testInboxTags_step4() {
        var messageWithoutTag: EMSMessage?

        retry { [unowned self] () in

            messageWithoutTag = try filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)

            if let tags = messageWithoutTag?.tags, tags.contains("testtag") {
                throw InboxError.existingTag
            }
        }

        XCTAssertFalse(messageWithoutTag?.tags?.contains("testtag") ?? true)
    }

    func testInboxTags_step5() {
        EmarsysTestUtils.tearDownEmarsys()
    }

    func setContact(_ cValue: String) {
        let contactExpectation = XCTestExpectation(description: "waitForResult")
        Emarsys.setContactWithContactFieldValue(cValue) { error in
            XCTAssertNil(error)
            contactExpectation.fulfill()
        }
        _ = XCTWaiter.wait(for: [contactExpectation], timeout: timeout)

    }

    func sendEvent(_ name: String, timestamp: String) {
        let customEventExpectation = XCTestExpectation(description: "waitForResult")
        Emarsys.trackCustomEvent(withName: "emarsys-sdk-e2e-inbox-test", eventAttributes: [
            "eventName": name,
            "timestamp": timestamp
        ]) { error in
            customEventExpectation.fulfill()
        }
        _ = XCTWaiter.wait(for: [customEventExpectation], timeout: 2)
    }

    func filterForInboxMessage(_ title: String, body: String) throws -> EMSMessage {
        Thread.sleep(forTimeInterval: timeout)

        var inboxMessage: EMSMessage?
        let fetchMessagesExpectation = XCTestExpectation(description: "waitForResult")
        Emarsys.messageInbox.fetchMessages { (inboxResult, error) in
            inboxMessage = inboxResult?.messages.first(where: { (message) -> Bool in
                return message.title == title && message.body == body
            })
            fetchMessagesExpectation.fulfill()
        }
        _ = XCTWaiter.wait(for: [fetchMessagesExpectation], timeout: 2)

        guard let message = inboxMessage else {
            throw InboxError.missingMessage
        }

        return message
    }

}

extension XCTestCase {

    func retry(retryCount: Int = 3, delay: Double? = 3.0, retryClosure: @escaping () throws -> ()) {
        var error: Error?
        var index = 0
        repeat {
            error = nil
            do {
                try retryClosure()
                index += 1
            } catch let e {
                error = e
            }
            if error != nil, index < retryCount, let delay = delay {
                Thread.sleep(forTimeInterval: delay)
            }
        } while (error != nil && index < retryCount)

        XCTAssertNil(error)
    }

}