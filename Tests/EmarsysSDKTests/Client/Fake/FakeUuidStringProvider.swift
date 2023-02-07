

import Foundation
@testable import EmarsysSDK

struct FakeUuidStringProvider: UuidProvider {
    
    let instanceId = UUID().uuidString
    
    var testUuid: String
    
    func provide() async -> String {
        return testUuid
    }
}
