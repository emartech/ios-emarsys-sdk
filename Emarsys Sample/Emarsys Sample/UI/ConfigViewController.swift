//
//  Copyright © 2019. Emarsys. All rights reserved.
//

import Foundation
import EmarsysSDKTarget

class ConfigViewController: UIViewController {

    @IBOutlet weak var applicationCodeValue: UITextField!
    @IBOutlet weak var merchantIdValue: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        handleKeybordDismiss()
        
        applicationCodeValue.text = Emarsys.config.applicationCode()
        merchantIdValue.text = Emarsys.config.merchantId()
    }

    @IBAction func changeApplicationCodeButtonClicked(_ sender: Any) {
        Emarsys.config.changeApplicationCode(applicationCodeValue.text) { [unowned self] error in
            self.applicationCodeValue.text = Emarsys.config.applicationCode()
            if error != nil {
                print(error!)
            }
        }
    }

    @IBAction func changeMerchantIdButtonClicked(_ sender: Any) {
        Emarsys.config.changeMerchantId(merchantIdValue.text)
    }
}
