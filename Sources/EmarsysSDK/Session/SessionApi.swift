//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation


@SdkActor
protocol SessionApi {
    
    func start() async
    
    func stop() async
    
    func registerForApplifecycleChanges() async
}
