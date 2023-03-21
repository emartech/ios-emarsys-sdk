//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
protocol ActionFactory {
    
    func create(genericAction: GenericAction) throws -> Action
}
