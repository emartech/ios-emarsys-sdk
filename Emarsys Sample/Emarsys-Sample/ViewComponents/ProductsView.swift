//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import SwiftUI
import EmarsysSDK

struct ProductsView: View {
    @State var products: [Product]
    
    var body: some View {
        List(products) { product in
            HStack {
                Image(uiImage: UIImage(named: "placeholderImage") ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:100, height:100)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(product.title)
                    }
                    HStack {
                        Text(product.feature)
                        Spacer()
                    }
                }
                
            }
            .frame(maxWidth: .infinity)
            .shadow(radius: 1)
            .padding([.horizontal, .vertical], 5)
        }
    }
}

struct ProductsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsView(products: [Product(title: "product1", feature: "feature", imageUrl: nil),
                                Product(title: "product1", feature: "feature", imageUrl: URL(string: "https://cdn.jpegmini.com/user/images/slider_puffin_before_mobile.jpg"))])
    }
}
