

import Foundation
@testable import EmarsysSDK

struct FakeUuidProvider: StringProvider, Faked {
    
    let instanceId = UUID().uuidString
    
    let provideFuncName = "provide"
    
    func provide() -> String {
        return try! handleCall(\.provideFuncName)
    }
}
