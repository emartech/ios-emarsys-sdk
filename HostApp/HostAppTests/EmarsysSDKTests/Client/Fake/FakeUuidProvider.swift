

import Foundation
@testable import EmarsysSDK

struct FakeUuidProvider: StringProvider, Faked {
    
    var faker = Faker()
    
    let provideFuncName = "provide"
    
    func provide() -> String {
        return try! handleCall(\.provideFuncName)
    }
}
