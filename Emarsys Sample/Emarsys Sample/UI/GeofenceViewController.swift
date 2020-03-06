//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation
import UIKit
import EmarsysSDK

class GeofenceViewController: UIViewController {

    @IBAction func requestAuthorizationButtonClicked(_ sender: Any) {
        Emarsys.geofence.requestAlwaysAuthorization()
    }

    @IBAction func enableButtonClicked(_ sender: Any) {
        Emarsys.geofence.enable()
    }
    
    @IBAction func disableButtonClicked(_ sender: Any) {
        Emarsys.geofence.disable()
    }
    
}
