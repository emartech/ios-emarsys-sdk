//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

@SdkActor
final class ActionFactoryTests: EmarsysTestCase {
    var eventHandler: EventHandler!
    var dismissHandler: DismissHandler!
    var actionFactory: DefaultActionFactory!
    var pasteBoard: UIPasteboard!
    @MainActor let application = UIApplication.shared
 
    @Inject(\.eventApi)
    var fakeEventApi: FakeEventApi
    
    @Inject(\.notificationCenterWrapper)
    var fakeNotificationCenterWrapper: FakeNotificationCenterWrapper
    
    let testName = "testName"
    let testPayload = ["key":"value"]
    
    override func setUpWithError() throws {
        eventHandler = { name, payload in }
        dismissHandler = { }
        pasteBoard = UIPasteboard()
        actionFactory = DefaultActionFactory(eventApi: fakeEventApi,
                                             eventHandler: eventHandler,
                                             dismissHandler: dismissHandler,
                                             notificationCenterWrapper: fakeNotificationCenterWrapper,
                                             application: application,
                                             uiPasteBoard: pasteBoard)
    }
    
    func testCreate_shouldReturn_customEventAction() throws {
        let testAction = GenericAction(type: "MECustomEvent", url: nil, name: testName, payload: testPayload, method: nil, value: nil, text: nil)
        
        let result = try actionFactory.create(genericAction: testAction)
        
        XCTAssertTrue(result.self is CustomEventAction)
        XCTAssertEqual((result as! CustomEventAction).name, testName)
        XCTAssertEqual((result as! CustomEventAction).payload, testPayload)
    }
    
    func testCreate_shouldReturn_appEventAction() throws {
        let testAction = GenericAction(type: "MEAppEvent", url: nil, name: testName, payload: testPayload, method: nil, value: nil, text: nil)
        
        let result = try actionFactory.create(genericAction: testAction)
        
        XCTAssertTrue(result.self is AppEventAction)
        XCTAssertEqual((result as! AppEventAction).name, testName)
        XCTAssertEqual((result as! AppEventAction).payload, testPayload)
    }
    
    func testCreate_shouldReturn_openExternalURLAction() throws {
        let testURL = "https://emarsys.com"
        let testAction = GenericAction(type: "OpenExternalUrl", url: testURL, name: nil, payload: nil, method: nil, value: nil, text: nil)
        let expectedURL = URL(string: testURL)
        
        let result = try actionFactory.create(genericAction: testAction)
        
        XCTAssertTrue(result.self is OpenExternalURLAction)
        XCTAssertEqual((result as! OpenExternalURLAction).url, expectedURL)
    }
    
    func testCreate_shouldReturn_buttonClickedAction() throws {
        let testAction = GenericAction(type: "ButtonClicked", url: nil, name: nil, payload: nil, method: nil, value: nil, text: nil)
        
        let result = try actionFactory.create(genericAction: testAction)
        
        XCTAssertTrue(result.self is ButtonClickedAction)
    }
    
    func testCreate_shouldReturn_dismissAction() throws {
        let testAction = GenericAction(type: "Dismiss", url: nil, name: nil, payload: nil, method: nil, value: nil, text: nil)
        
        let result = try actionFactory.create(genericAction: testAction)
        
        XCTAssertTrue(result.self is DismissAction)
    }
    
    func testCreate_shouldReturn_requestPushPermissionAction() throws {
        let testAction = GenericAction(type: "RequestPushPermission", url: nil, name: nil, payload: nil, method: nil, value: nil, text: nil)
        
        let result = try actionFactory.create(genericAction: testAction)
        
        XCTAssertTrue(result.self is RequestPushPermissionAction)
    }
    
    func testCreate_shouldReturn_badgeCountAction() throws {
        let testMethod = "add"
        let testValue = 2
        let testAction = GenericAction(type: "BadgeCount", url: nil, name: nil, payload: nil, method: testMethod, value: testValue, text: nil)
        
        let result = try actionFactory.create(genericAction: testAction)
        
        XCTAssertTrue(result.self is BadgeCountAction)
        
        XCTAssertEqual((result as! BadgeCountAction).method, testMethod)
        XCTAssertEqual((result as! BadgeCountAction).value, testValue)
    }
    
    func testCreate_shouldReturn_copyToClipboardAction() throws {
        let text = "testText"
        let testAction = GenericAction(type: "CopyToClipboard", url: nil, name: nil, payload: nil, method: nil, value: nil, text: text)
        
        let result = try actionFactory.create(genericAction: testAction)
        
        XCTAssertTrue(result.self is CopyToClipboardAction)
    }
    
    func testCreate_shouldThrowError_ifActionTypeIsNotSupported() async throws {
        let testAction = GenericAction(type: "Unsupported action", url: nil, name: nil, payload: nil, method: nil, value: nil, text: nil)
        
        await assertThrows(expectedError: Errors.preconditionFailed(message: "Unknown action type: \(testAction.type)")) {
            let _ = try actionFactory.create(genericAction: testAction)
        }
        
    }
}

