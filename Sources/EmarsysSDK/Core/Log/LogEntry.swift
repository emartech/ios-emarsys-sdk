//
// Copyright (c) 2022 Emarsys. All rights reserved.
//

import Foundation
import os

struct LogEntry {
    public let topic: String
    public let data: Dictionary<String, Any>
    public let logPrivate: Bool

    init(topic: String, data: Dictionary<String, Any>, logPrivate: Bool) {
        self.topic = topic
        self.data = data
        self.logPrivate = logPrivate
    }
}

