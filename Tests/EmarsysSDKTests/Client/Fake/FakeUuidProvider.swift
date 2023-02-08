

import Foundation
@testable import EmarsysSDK

struct FakeUuidProvider: StringProvider, Faked {
    
    let instanceId = UUID().uuidString
    
    let provide = "provide"
    
    func provide() async -> String {
        return try! handleCall(\.provide)
    }
}
