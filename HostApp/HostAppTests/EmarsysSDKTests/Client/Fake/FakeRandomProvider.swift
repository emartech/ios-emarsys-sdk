

import Foundation
@testable import EmarsysSDK

struct FakeRandomProvider: DoubleProvider, Faked {
    
    var faker = Faker()
    
    let provideFuncName = "provide"
    
    func provide() -> Double {
        return try! handleCall(\.provideFuncName)
    }
}
