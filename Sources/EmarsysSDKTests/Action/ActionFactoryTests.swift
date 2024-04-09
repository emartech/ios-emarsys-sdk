//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

struct FakeActionModel: ActionModellable {
    var type: String
}

@SdkActor
final class ActionFactoryTests: EmarsysTestCase {

    var actionFactory: DefaultActionFactory!
     
    @Inject(\.eventApi)
    var fakeEventApi: FakeEventApi
    
    @Inject(\.notificationCenterWrapper)
    var fakeNotificationCenterWrapper: FakeNotificationCenterWrapper
    
    @Inject(\.application)
    var fakeApplication: FakeApplication
    
    let testName = "testName"
    let testPayload = ["key":"value"]
    
    override func setUpWithError() throws {
        actionFactory = DefaultActionFactory(
            eventApi: fakeEventApi,
            application: fakeApplication,
            notificationCenterWrapper: fakeNotificationCenterWrapper)
    }
    
    func testCreate_shouldReturn_customEventAction() throws {
        let actionModel = CustomEventActionModel(type: "MECustomEvent", name: testName, payload: testPayload)
        
        let result = try actionFactory.create(actionModel)
        
        XCTAssertTrue(result.self is CustomEventAction)
    }
    
    func testCreate_shouldReturn_appEventAction() throws {
        let actionModel = AppEventActionModel(type: "MEAppEvent", name: testName, payload: testPayload)
        
        let result = try actionFactory.create(actionModel)
        
        XCTAssertTrue(result.self is AppEventAction)
    }
    
    func testCreate_shouldReturn_openExternalURLAction() throws {
        let actionModel = OpenExternalURLActionModel(type: "OpenExternalUrl", url: URL(string: "https://emarsys.com")!)
        
        let result = try actionFactory.create(actionModel)
        
        XCTAssertTrue(result.self is OpenExternalURLAction)
    }
    
    func testCreate_shouldReturn_dismissAction() throws {
        let actionModel = DismissActionModel(type: "Dismiss", topic: "testTopic")
        
        let result = try actionFactory.create(actionModel)
        
        XCTAssertTrue(result.self is DismissAction)
    }
    
    func testCreate_shouldReturn_requestPushPermissionAction() throws {
        let actionModel = RequestPushPermissionActionModel(type: "RequestPushPermission")
        
        let result = try actionFactory.create(actionModel)
        
        XCTAssertTrue(result.self is RequestPushPermissionAction)
    }
    
    func testCreate_shouldReturn_badgeCountAction() throws {
        let actionModel = BadgeCountActionModel(type: "RequestPushPermission", method: "testMethod", value: 2)
        
        let result = try actionFactory.create(actionModel)
        
        XCTAssertTrue(result.self is BadgeCountAction)
    }
    
    func testCreate_shouldReturn_copyToClipboardAction() throws {
        let actionModel = CopyToClipboardActionModel(type: "CopyToClipboard", text: "testText")
        
        let result = try actionFactory.create(actionModel)
        
        XCTAssertTrue(result.self is CopyToClipboardAction)
    }
    
    func testCreate_shouldThrowError_ifActionTypeIsNotSupported() async throws {
        let actionModel = FakeActionModel(type: "very fake")
        
        await assertThrows(expectedError: Errors.preconditionFailed(message: "Unknown action type: \(actionModel)")) {
            let _ = try actionFactory.create(actionModel)
        }
        
    }
}
