//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation

class OnEventResponseHandler: EMSAbstractResponseHandler {

    var actionFactory: EMSActionFactory
    let displayedIAMRepository: EMSRepositoryProtocol
    let timestampProvider: EMSTimestampProvider
    let requestFactory: EMSRequestFactory
    let requestManager: EMSRequestManager

    @objc init(actionFactory: EMSActionFactory,
               displayedIAMRepository: EMSRepositoryProtocol,
               timestampProvider: EMSTimestampProvider,
               requestFactory: EMSRequestFactory,
               requestManager: EMSRequestManager) {
        self.actionFactory = actionFactory
        self.displayedIAMRepository = displayedIAMRepository
        self.timestampProvider = timestampProvider
        self.requestFactory = requestFactory
        self.requestManager = requestManager
    }

    override func shouldHandleResponse(_ response: EMSResponseModel) -> Bool {
        guard let parsedBody = response.parsedBody() as? [String: Any] else {
            return false
        }
        guard let onEventAction = parsedBody["onEventAction"] as? [String: Any] else {
            return false
        }
        return onEventAction["actions"] != nil
    }

    override func handleResponse(_ response: EMSResponseModel) {
        guard let parsedBody = response.parsedBody() as? [String: Any] else {
            return
        }
        guard let onEventAction = parsedBody["onEventAction"] as? [String: Any] else {
            return
        }
        guard let actions = onEventAction["actions"] as? [[String: Any]] else {
            return
        }
        actions.forEach { [unowned self] actionDict in
            self.actionFactory.createAction(withActionDictionary: actionDict)?.execute()
        }
        guard let campaignId = parsedBody["campaignId"] as? String else {
            return
        }
        self.displayedIAMRepository.add(MEDisplayedIAM(campaignId: campaignId, timestamp: self.timestampProvider.provideTimestamp()))
        let eventAttributes = ["campaignId" : campaignId]
        let requestModel = requestFactory.createEventRequestModel(withEventName: "inapp:viewed", eventAttributes: eventAttributes, eventType: EventTypeInternal)
        requestManager.submitRequestModel(requestModel, withCompletionBlock: nil)
    }

}
