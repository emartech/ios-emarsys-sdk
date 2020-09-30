//
//  Copyright © 2019. Emarsys. All rights reserved.
//

import Foundation
import EmarsysSDK

class ConfigViewController: UIViewController {

    @IBOutlet weak var applicationCodeValue: UITextField!
    @IBOutlet weak var merchantIdValue: UITextField!
    @IBOutlet weak var contactFieldIdValue: UITextField!
    @IBOutlet weak var hwIdField: UILabel!
    @IBOutlet weak var languageCodeField: UILabel!
    @IBOutlet weak var pushSettingsField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleKeybordDismiss()
        
        applicationCodeValue.text = Emarsys.config.applicationCode()
        merchantIdValue.text = Emarsys.config.merchantId()
        contactFieldIdValue.text = Emarsys.config.contactFieldId().stringValue
        hwIdField.text = Emarsys.config.hardwareId()
        languageCodeField.text = Emarsys.config.languageCode()
        pushSettingsField.text = Emarsys.config.pushSettings().description
    }

    @IBAction func changeApplicationCodeButtonClicked(_ sender: Any) {
        if (contactFieldIdValue.text == nil || contactFieldIdValue.text!.isEmpty) {
            Emarsys.config.changeApplicationCode(applicationCodeValue.text) { [unowned self] error in
                self.applicationCodeValue.text = Emarsys.config.applicationCode()
                if error != nil {
                    print(error!)
                }
            }
        } else {
            Emarsys.config.changeApplicationCode(applicationCodeValue.text, contactFieldId: Int(contactFieldIdValue.text!)! as NSNumber) { [unowned self] error in
                self.applicationCodeValue.text = Emarsys.config.applicationCode()
                self.contactFieldIdValue.text = Emarsys.config.contactFieldId().stringValue
                if error != nil {
                    print(error!)
                }
            }
        }
    }

    @IBAction func changeMerchantIdButtonClicked(_ sender: Any) {
        Emarsys.config.changeMerchantId(merchantIdValue.text)
    }
}
