//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

import Foundation

class FakeDisplayedIAMRepository: NSObject, EMSRepositoryProtocol {
    var addedItem: MEDisplayedIAM?
    var calledAdd: Bool = false

    func add(_ item: Any) {
        self.addedItem = item as! MEDisplayedIAM
        self.calledAdd = true
    }

    func remove(_ sqlSpecification: EMSSQLSpecificationProtocol!) {
    }

    func query(_ sqlSpecification: EMSSQLSpecificationProtocol!) -> [Any]! {
        fatalError("query(_:) has not been implemented")
    }
}
