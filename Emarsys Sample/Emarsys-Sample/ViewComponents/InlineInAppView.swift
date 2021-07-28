//
//  Copyright © 2020. Emarys. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import EmarsysSDK

struct InlineInAppView: UIViewRepresentable {
    let inlineInApp = EMSInlineInAppView()
    var viewId: String
    var onClose: () -> Void = {}
    var onEvent: (String, Dictionary<String, Any>?) -> Void = { name, payload in }
    var onCompletion: (Error?) -> Void = { error in }
    
    func makeUIView(context: Context) -> some EMSInlineInAppView {
        inlineInApp.closeBlock = {
            self.onClose()
        }
        inlineInApp.eventHandler = { name, payload in
            self.onEvent(name, payload)
        }
        inlineInApp.completionBlock = { error in
            self.onCompletion(error)
        }
        
        inlineInApp.loadInApp(viewId: viewId)
        
        return inlineInApp
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

struct InlineInAppView_Previews: PreviewProvider {
    static var previews: some View {
        InlineInAppView(viewId: "ia", onClose: { }, onEvent: { name, payload in }, onCompletion: { error in })
    }
}
