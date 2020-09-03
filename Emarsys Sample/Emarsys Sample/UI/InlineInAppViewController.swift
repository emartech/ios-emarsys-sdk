//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation
import EmarsysSDK

class InlineInAppViewController: UIViewController {
    
    
    @IBOutlet weak var inappFromIB: EMSInlineInAppView!
    @IBOutlet weak var inappFromIBAndCode: EMSInlineInAppView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewIdTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleKeybordDismiss()
        
        inappFromIB.closeBlock = {
            self.inappFromIB.isHidden = true
        }
        
        inappFromIB.eventHandler = { name, payload in
            let appEventAlert = UIAlertController(title: name, message: payload?.description, preferredStyle: .alert)
            appEventAlert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
            self.present(appEventAlert, animated: true, completion: nil)
        }
        
        inappFromIBAndCode.loadInApp(withViewId: "ia")
        
        inappFromIBAndCode.closeBlock = {
            self.inappFromIBAndCode.isHidden = true
        }
        
        inappFromIBAndCode.completionBlock = { error in
            if(error == nil) {
                print("Succesfully created inline in-app")
            }
        }
    }
    
    @IBAction func addInlineInAppButtonClicked(_ sender: Any) {
        if let viewId = viewIdTextField.text {
            if viewId.isEmpty {
                let alert = UIAlertController(title: "Error", message: "A valid viewID is needed for inline in-app", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let inlineInAppFromCode = EMSInlineInAppView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 300))
                
                inlineInAppFromCode.loadInApp(withViewId: viewId)
                
                inlineInAppFromCode.closeBlock = {
                    inlineInAppFromCode.isHidden = true
                    inlineInAppFromCode.removeFromSuperview()
                    self.contentView.layoutIfNeeded()
                }
                
                contentView.addSubview(inlineInAppFromCode)
                contentView.layoutIfNeeded()
            }
        }
    }
}
