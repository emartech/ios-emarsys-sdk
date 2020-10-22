//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import SwiftUI

struct MultilineTextView: UIViewRepresentable {
    @State var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.text = text
    }
    
}

struct MultilineTextView_Previews: PreviewProvider {
    static var previews: some View {
        MultilineTextView(
            text: """
            {"eventAttributeKey1":"value1",
            "eventAttributeKey2":"value2"}
            """
        ).border(Color.red)
    }
}
