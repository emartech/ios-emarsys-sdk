//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import XCTest

class OnEventResponseHandlerTests: XCTestCase {

    var actionFactory: FakeActionFactory?
    var repository: FakeDisplayedIAMRepository?
    var timestampProvider: EMSTimestampProvider?
    var requestFactory: FakeRequestFactory?
    var requestManager: FakeRequestManager?
    var responseHandler: EMSOnEventResponseHandler?

    override func setUpWithError() throws {
        self.actionFactory = FakeActionFactory {
        }
        self.repository = FakeDisplayedIAMRepository()
        self.timestampProvider = EMSTimestampProvider()
        self.requestFactory = FakeRequestFactory()
        self.requestManager = FakeRequestManager()

        self.responseHandler = EMSOnEventResponseHandler(requestManager: self.requestManager!,
                requestFactory: self.requestFactory!,
                displayedIAMRepository: self.repository!,
                actionFactory: self.actionFactory!,
                timestampProvider: self.timestampProvider!)
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

    func testHandleResponseShouldStoreDisplayedIAMWithRepository() throws {
        let responseModel = createResponse()
        let displayedIAM = MEDisplayedIAM(campaignId: "1234", timestamp: Date())

        self.responseHandler!.handleResponse(responseModel)

        XCTAssertEqual(displayedIAM?.campaignId, self.repository?.addedItem?.campaignId)
    }

    func testHandleResponseShouldNotCallRepositoryWhenCampaingIdIsNotPresentInRequestBody() throws {
        let data = [
            "onEventAction": [
                "actions": [
                    ["actionKey": "actionValue"]
                ]
            ]
        ] as [String: Any]
        let requestModel = EMSRequestModel()
        let responseModel = EMSResponseModel(statusCode: 200, headers: ["headerKey": "headerValue"], body: data.toData(), requestModel: requestModel, timestamp: Date())

        self.responseHandler!.handleResponse(responseModel)

        XCTAssertFalse(self.repository!.calledAdd)
    }

    func testHandleResponseCallsRequestManagerWithInAppViewedEventRequestModel() throws {
        let responseModel = createResponse()

        self.responseHandler?.handleResponse(responseModel)

        XCTAssertEqual(self.requestManager?.submittedRequestModel, self.requestFactory?.createdRequestModel)
    }

    func createResponse() -> EMSResponseModel {
        let data = [
            "campaignId": "1234",
            "onEventAction": [
                "actions": [
                    ["actionKey": "actionValue"]
                ]
            ]
        ] as [String: Any]

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

    override func createAction(withActionDictionary action: [String: Any]) -> EMSActionProtocol? {
        return FakeAction(completion: self.completion)
    }
}


extension Dictionary {

    func toData() -> Data {
        return try! JSONSerialization.data(withJSONObject: self, options: [])
    }

}
