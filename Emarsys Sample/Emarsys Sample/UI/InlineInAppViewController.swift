//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation
import EmarsysSDK

class InlineInAppViewController: UIViewController {
    
    
    @IBOutlet weak var inappFromIB: EMSInlineInAppView!
    @IBOutlet weak var inappFromIBAndCode: EMSInlineInAppView!
    @IBOutlet weak var contentView: UIView!
    

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
    
        inappFromIBAndCode.loadInApp(withViewId: "main-screen-banner")
        inappFromIBAndCode.closeBlock = {
            self.inappFromIBAndCode.isHidden = true
        }
    }
    
    @IBAction func addInlineInAppButtonClicked(_ sender: Any) {
        let inlineInAppFromCode = EMSInlineInAppView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 300))
        inlineInAppFromCode.loadInApp(withViewId: "main-screen-banner")
        inlineInAppFromCode.closeBlock = {
            inlineInAppFromCode.removeFromSuperview()
        }
        
        contentView.addSubview(inlineInAppFromCode)
        contentView.layoutIfNeeded()
    }
}
