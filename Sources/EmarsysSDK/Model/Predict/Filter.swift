//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

import Foundation


class Filter {
    let type: String
    let field: String
    let comparison: String
    let expectations: [String?]
    
    convenience init(type: FilterType, field: String, comparison: Comparison, value: String) {
        self.init(type: type, field: field, comparison: comparison, values: [value])
    }
    
    convenience init(type: FilterType, field: String, comparison: Comparison, values: String...) {
        self.init(type: type, field: field,  comparison: comparison, values: values)
    }
    
    init(type: FilterType, field: String, comparison: Comparison, values: [String]) {
        self.type = type.rawValue.uppercased()
        self.comparison = comparison.rawValue.uppercased()
        self.field = field
        self.expectations = values
    }
}

enum Comparison: String {
    case `is`
    case `in`
    case has
    case overlaps
}

enum FilterType: String {
    case include
    case exclude
}
