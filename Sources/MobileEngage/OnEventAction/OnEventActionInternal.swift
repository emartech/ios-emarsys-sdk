//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation

class OnEventActionInternal: NSObject, EMSOnEventActionProtocol {
    
    var eventHandler: EMSEventHandler? {
        didSet {
            self.actionFactory?.eventHandler = eventHandler
        }
    }
    
    var actionFactory: EMSActionFactory?

    @objc init(actionFactory: EMSActionFactory? = nil) {
        self.actionFactory = actionFactory
    }
    
}
