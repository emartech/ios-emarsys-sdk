

import Foundation
@testable import EmarsysSDK
import mimic

struct FakeRandomProvider: DoubleProvider, Mimic {
    
    let fnProvide = Fn<Double>()
    
    func provide() -> Double {
        return try! fnProvide.invoke()
    }
}
