

import Foundation
@testable import EmarsysSDK

struct FakeRandomProvider: DoubleProvider, Faked {
    
    let instanceId = UUID().uuidString
    
    let provideFuncName = "provide"
    
    func provide() -> Double {
        return try! handleCall(\.provideFuncName)
    }
}
