//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
protocol ModifiableCollection: MutableCollection {
    
    func append(_ newElement: Element)
    
}
