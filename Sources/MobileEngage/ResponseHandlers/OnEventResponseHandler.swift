//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation

class OnEventResponseHandler: EMSAbstractResponseHandler {
    
    var actionFactory: EMSActionFactory
    
    init(actionFactory: EMSActionFactory) {
        self.actionFactory = actionFactory
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
    }
    
}
