//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

import Foundation

class FakeRequestFactory: EMSRequestFactory {
    var eventName: String?
    var eventAttributes: Dictionary<String, String>?
    var eventType: EventType?
    var createdRequestModel: EMSRequestModel?


    override func createEventRequestModel(withEventName eventName: String, eventAttributes: [String: String]?, eventType: EventType) -> EMSRequestModel {
        createdRequestModel = EMSRequestModel(
                requestId: "fakeId",
                timestamp: Date(),
                expiry: 1,
                url: URL(string: "https://www.emarsys.com")!,
                method: "POST",
                payload: [:],
                headers: [:],
                extras: [:])
        return createdRequestModel!
    }
}
