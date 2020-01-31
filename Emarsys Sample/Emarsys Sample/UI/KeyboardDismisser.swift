//
//  Copyright © 2019. Emarsys. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
        
    func handleKeybordDismiss() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGestureRecognizer.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func backgroundTapped() {
        self.view.endEditing(true)
    }
    
}
