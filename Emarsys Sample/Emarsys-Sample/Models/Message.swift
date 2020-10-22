//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation

struct Message: Identifiable {
    var id = UUID()
    
    var title: String = ""
    var body: String = ""
    var imageUrl: String? = nil
}
