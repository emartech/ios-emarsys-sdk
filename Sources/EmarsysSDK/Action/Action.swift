//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
protocol Action {
    
    func execute() async throws
}
