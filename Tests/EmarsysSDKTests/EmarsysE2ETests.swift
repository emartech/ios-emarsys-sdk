//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import XCTest

class EmarsysE2ETests: XCTestCase {
    
    let timeout = 2.0

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        EmarsysTestUtils.tearDownEmarsys()
    }

    func testChangeApplicationCodeFromNil() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let timestamp = dateFormatter.string(from: Date())
        let config = EMSConfig.make { builder in
        }

        Emarsys.setup(with: config)
        
        changeAppCode("EMS11-C3FD3", cId: 2575)
        
        setContact("test@test.com")
        
        sendEvent("iosE2EChangeAppCodeFromNil", timestamp: timestamp)

        retry { [unowned self] () in

            _ = try filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)
        }
    }

    func testChangeApplicationCode() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let timestamp = dateFormatter.string(from: Date())
        let config = EMSConfig.make { builder in
            builder.setMobileEngageApplicationCode("14C19-A121F")
            builder.setContactFieldId(2575)
        }

        Emarsys.setup(with: config)

        changeAppCode("EMS11-C3FD3", cId: 2575)

        setContact("test@test.com")

        sendEvent("iosE2EChangeAppCodeFromNil", timestamp: timestamp)

        retry { [unowned self] () in

            _ = try filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)
        }
    }

    func testInboxTags() {
        enum InboxError: Error {
            case missingTag
            case existingTag
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let timestamp = dateFormatter.string(from: Date())
        let config = EMSConfig.make { builder in
            builder.setMobileEngageApplicationCode("EMS11-C3FD3")
            builder.setContactFieldId(2575)
        }

        Emarsys.setup(with: config)

        setContact("test@test.com")

        sendEvent("iosE2EChangeAppCodeFromNil", timestamp: timestamp)

        retry { [unowned self] () in

            let message = try filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)

            Emarsys.messageInbox.addTag("testtag", forMessage: message.id)
        }

        var messageWithTag: EMSMessage?

        retry { [unowned self] () in

            messageWithTag = try filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)

            if let tags = messageWithTag?.tags, !tags.contains("testtag") {
                throw InboxError.missingTag
            }
        }

        XCTAssertTrue(messageWithTag?.tags?.contains("testtag") ?? false)

        Emarsys.messageInbox.removeTag("testtag", fromMessage: messageWithTag?.id ?? "")

        var messageWithoutTag: EMSMessage?

        retry { [unowned self] () in

            messageWithoutTag = try filterForInboxMessage("iosE2EChangeAppCodeFromNil", body: timestamp)

            if let tags = messageWithoutTag?.tags, tags.contains("testtag") {
                throw InboxError.existingTag
            }
        }

        XCTAssertFalse(messageWithoutTag?.tags?.contains("testtag") ?? true)
    }
    
    func changeAppCode(_ code: String, cId: NSNumber) {
        let changeAppCodeExpectation = XCTestExpectation(description: "waitForResult")
        Emarsys.config.changeApplicationCode(code, contactFieldId: cId) { error in
            XCTAssertNil(error)
            changeAppCodeExpectation.fulfill()
        }
        _ = XCTWaiter.wait(for: [changeAppCodeExpectation], timeout: timeout)
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
        enum InboxError: Error {
            case missingMessage
        }

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

    func retry(retryCount: Int = 3, delay: Double? = 1.0, retryClosure: @escaping () throws -> ()) {
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