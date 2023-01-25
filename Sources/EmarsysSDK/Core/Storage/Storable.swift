//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation


protocol Storable {

    func toData() -> Data
    
    func fromData(data: Data) -> Self
    
}
