//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
protocol State {
        
    var name: String {
        get
    }
    
    func prepare()
    
    func active() async throws
    
    func relax()
    
}
