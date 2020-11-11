//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import XCTest

class OnEventResponseHandlerTests: XCTestCase {
    
    var actionFactory: FakeActionFactory?
    var responseHandler: OnEventResponseHandler?
    
    override func setUpWithError() throws {
        self.actionFactory = FakeActionFactory {
        }
        self.responseHandler = OnEventResponseHandler(actionFactory: self.actionFactory!)
    }

    func testShouldHandleResponse() throws {
        let responseModel = createResponse()

        let shouldHandle = self.responseHandler!.shouldHandleResponse(responseModel)
        
        XCTAssertTrue(shouldHandle)
    }

    func testHandleResponse() throws {
        let responseModel = createResponse()
        
        var success = false
        
        let expectation = XCTestExpectation(description: "waitForCompletion")
        self.actionFactory?.completion = {
            success = true
            expectation.fulfill()
        }
        _ = XCTWaiter.wait(for: [expectation], timeout: 3)
        
        self.responseHandler!.handleResponse(responseModel)
        
        XCTAssertTrue(success)
    }
    
    func createResponse() -> EMSResponseModel {
        let data = [
            "onEventAction": [
                "actions": [
                    ["actionKey": "actionValue"]
                ]
            ]
        ]
        
        let requestModel = EMSRequestModel()
        return EMSResponseModel(statusCode: 200, headers: ["headerKey": "headerValue"], body: data.toData(), requestModel: requestModel, timestamp: Date())
    }
    
}

class FakeAction: NSObject, EMSActionProtocol {
    
    var completion: () -> ()
    
    init(completion: @escaping () -> ()) {
        self.completion = completion
    }
    
    func execute() {
        completion()
    }
}

class FakeActionFactory: EMSActionFactory {
    
    var completion: () -> ()
    
    init(completion: @escaping () -> ()) {
        self.completion = completion
    }
    
    override func createAction(withActionDictionary action: [String : Any]) -> EMSActionProtocol? {
        return FakeAction(completion: self.completion)
    }
}


extension Dictionary {
    
    func toData() -> Data {
        return try! JSONSerialization.data(withJSONObject: self, options: [])
    }
    
}
