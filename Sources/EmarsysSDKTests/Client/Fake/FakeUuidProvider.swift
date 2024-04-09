

import Foundation
@testable import EmarsysSDK
import mimic

struct FakeUuidProvider: StringProvider, Mimic {
    
    let fnProvide = Fn<String>()
    
    func provide() -> String {
        return try! fnProvide.invoke()
    }
}
