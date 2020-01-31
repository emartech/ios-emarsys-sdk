//
//  Copyright © 2017. Emarsys. All rights reserved.
//

import Foundation
import UIKit

extension MESMobileEngageViewController {
    
    func showAlert(with message: String) {
        let controller = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(controller, animated: true)
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MESMobileEngageViewController.keyboardWasShown),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MESMobileEngageViewController.keyboardWillBeHidden),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        let rect: CGRect = notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        scrollViewBottomConstraint.constant = rect.height;
        self.view.layoutIfNeeded()
        
        if let firstResponder = firstResponder() {
            scrollView.scrollRectToVisible(firstResponder.frame, animated: true)
        }
    }
    
    func firstResponder() -> UIView? {
        let responders: [UIView] = [contactFieldValueTextField, sidTextField, customEventNameTextField, customEventAttributesTextView]
        
        return responders.first { (responder:UIView) -> Bool in
            return responder.isFirstResponder
        }
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        scrollViewBottomConstraint.constant = 0;
    }
}
