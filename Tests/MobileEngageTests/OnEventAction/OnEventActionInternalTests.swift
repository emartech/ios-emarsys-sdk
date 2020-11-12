//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import XCTest

class OnEventActionInternalTests: XCTestCase {

    var actionFactory: EMSActionFactory?
    var onEventActionInternal: OnEventActionInternal?
    
    override func setUpWithError() throws {
        actionFactory = FakeActionFactory(completion: {
        })
        self.onEventActionInternal = OnEventActionInternal(actionFactory: self.actionFactory!)
    }

    func testEventHandler() throws {
        let eventHandler = FakeEventHandler()
        
        self.onEventActionInternal?.eventHandler = eventHandler
        
        XCTAssertEqual(self.actionFactory?.eventHandler as? FakeEventHandler, eventHandler)
    }

}

class FakeEventHandler: NSObject, EMSEventHandler {

    func handleEvent(_ eventName: String, payload: [String: NSObject]?) {

    }
}
