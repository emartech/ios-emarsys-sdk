//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
class TimestampProvider: DateProvider {
    func provide() -> Date {
        return Date()
    }
}
