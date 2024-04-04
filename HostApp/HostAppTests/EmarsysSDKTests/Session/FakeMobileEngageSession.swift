//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
@testable import EmarsysSDK
import mimic


struct FakeMobileEngageSession: SessionApi, Mimic {
    let fnStart = Fn<()>()
    let fnStop = Fn<()>()
    let fnRegisterForApplifecycleChanges = Fn<()>()
    
    func start() async {
        return try! fnStart.invoke()
    }
    
    func stop() async {
        return try! fnStop.invoke()
    }
    
    func registerForApplifecycleChanges() async {
        return try! fnRegisterForApplifecycleChanges.invoke()
    }
    
    
}
