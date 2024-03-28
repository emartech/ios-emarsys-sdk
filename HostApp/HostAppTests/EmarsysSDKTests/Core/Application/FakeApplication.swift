//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
@testable import EmarsysSDK
import mimic

struct FakeApplication: ApplicationApi, Mimic {
    
    var badgeCount: any BadgeCountApi = FakeBadgeCount()
    
    var pasteboard: String? = ""
    
    let fnOpenUrl = Fn<()>()
    let fnRequestPushPermission = Fn<()>()
    
    func openUrl(_ url: URL) {
        return try! fnOpenUrl.invoke(params: url)
    }
    
    func requestPushPermission() async {
        return try! fnRequestPushPermission.invoke()
    }
    
}
