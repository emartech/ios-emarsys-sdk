//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation

struct Product: Identifiable {
    var id = UUID()
    
    var title: String
    var feature: String
    var imageUrl: URL? = nil
}

