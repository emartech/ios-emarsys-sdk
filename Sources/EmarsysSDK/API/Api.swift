//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
import Combine

@SdkActor
protocol Api {
    
    var sdkContext: SdkContext { get }
    
    var cancellables: Set<AnyCancellable> { get set }
    
}
