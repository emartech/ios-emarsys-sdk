//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {

    override var traitCollection: UITraitCollection {
        let realTraits = super.traitCollection
        let fakeTraits = UITraitCollection(horizontalSizeClass: .regular)
        return UITraitCollection(traitsFrom: [realTraits, fakeTraits])
    }
    
}
