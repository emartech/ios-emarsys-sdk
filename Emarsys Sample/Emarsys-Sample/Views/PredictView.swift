//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import SwiftUI
import EmarsysSDK

struct PredictView: View {
    
    @State var itemId: String = ""
    @State var categoryView: String = ""
    @State var searchTerm: String = ""
    @State var orderId: String = ""
    @State var cartItems: [EMSCartItem] = []
    @State var showRecommended: Bool = false
    @State var recommendedProducts: [Product] = []
    @State var logic: EMSLogic = EMSLogic.search()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Item view")
                    .bold()
                TextField("itemId", text: $itemId)
                    .autocapitalization(UITextAutocapitalizationType.none)
                    .frame(height: 20)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack() {
                    Spacer()
                    Button(action: self.trackItemId) {
                        Text("Track")
                    }
                }
            }.padding()
            
            Divider().background(Color.black).padding(.horizontal)
            
            VStack(spacing: 20) {
                Text("Category view")
                    .bold()
                TextField("categoryView", text: $categoryView)
                    .autocapitalization(UITextAutocapitalizationType.none)
                    .frame(height: 20)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack() {
                    Spacer()
                    Button(action: self.trackCategoryView) {
                        Text("Track")
                    }
                }
            }.padding()
            
            Divider().background(Color.black).padding(.horizontal)
            
            VStack(spacing: 20) {
                Text("Search term")
                    .bold()
                TextField("searchTerm", text: $searchTerm)
                    .autocapitalization(UITextAutocapitalizationType.none)
                    .frame(height: 20)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack() {
                    Spacer()
                    Button(action:self.trackSearchTerm) {
                        Text("Track")
                    }
                }
            }.padding()
            
            Divider().background(Color.black).padding(.horizontal)
            
            VStack {
                Text("Cart and purchase").bold()
                HStack {
                    TextField("orderId", text: $orderId) {
                        UIApplication.shared.endEditing()
                    }
                    Button(action: self.trackOrderId) {
                        Text("Track purchase")
                    }
                }
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
//                    MultilineTextView(text: self.cartItems.map({ cartItem -> String in
//                        "id: \(cartItem.itemId), price: \(cartItem.price), quantity: \(cartItem.quantity), \n"
//                    }).joined())
//                        .frame(height: 100)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 15)
//                                .stroke(lineWidth: 1)
//                                .opacity(0.2)
//                        )
                    Button(action: self.addSampleCartItems) {
                        Image(systemName: "plus.circle").font(.system(size: 30))
                    }
                }.onAppear(perform: {
                    self.cartItems.append(self.generateCartItem())
                    self.cartItems.append(self.generateCartItem())
                })
                HStack {
                    Spacer()
                    Button(action: self.trackCartItems) {
                        Text("Track Cart Items")
                    }
                }
            }
            .padding()
            
            Divider().background(Color.black).padding(.horizontal)
            
            VStack(spacing: 20) {
                Text("Recommend by last track")
                    .bold()
                
                HStack() {
                    Spacer()
                    Button(action: self.recommendProducts) {
                        Text("Recommend")
                    }.sheet(isPresented: $showRecommended) {
                        ProductsView(products: self.recommendedProducts)
                    }
                }
            }.padding()
            
            Spacer()
        }
        
    }
    
    func trackItemId() {
        Emarsys.predict.trackItemView(withItemId: self.itemId)
        self.logic = EMSLogic.related(withViewItemId: self.itemId)
    }
    
    func trackCategoryView() {
        Emarsys.predict.trackCategoryView(withCategoryPath: self.categoryView)
        self.logic = EMSLogic.category(withCategoryPath: self.categoryView)
    }
    
    func trackSearchTerm() {
        Emarsys.predict.trackSearch(withSearchTerm: self.searchTerm)
        self.logic = EMSLogic.search(withSearchTerm: self.searchTerm)
    }
    
    func trackOrderId() {
        Emarsys.predict.trackPurchase(withOrderId: self.orderId, items: self.cartItems)
    }
    
    func addSampleCartItems() {
        self.cartItems.append(generateCartItem())
    }
    
    func trackCartItems() {
        Emarsys.predict.trackCart(withCartItems: self.cartItems)
        self.logic = EMSLogic.cart(withCartItems: self.cartItems)
    }
    
    func recommendProducts() {
        Emarsys.predict.recommendProducts(with: self.logic) { products, error in
            guard let existingProducts = products else {
                return
            }
            self.recommendedProducts.removeAll()
            self.convertProducts(products: existingProducts).forEach { product in
                self.recommendedProducts.append(product)
            }
            self.showRecommended = !self.showRecommended
        }
    }
    
    private func convertProducts(products: [EMSProduct]) -> [Product]{
        var result : [Product] = []
        for product in products {
            let imageUrlString = product.imageUrl?.absoluteString
            if let correctImageUrl = imageUrlString?.replacingOccurrences(of: "http:", with: "https:") {
                let url = URL(string: correctImageUrl)
                result.append(Product(title: product.title, feature: product.feature, imageUrl: url))
            } else {
                result.append(Product(title: product.title, feature: product.feature))
            }
        }
        return result
    }
    
    private func generateCartItem() -> EMSCartItem {
           let itemIds = [
               "2185",
               "2186",
               "2187",
               "2188",
               "2189",
               "2190",
               "2191",
               "2192",
               "2193",
               "2194",
               "2195",
               "2196",
               "2197",
               "2198",
               "2199",
               "2200",
               "2201",
               "2202",
               "2206",
               "2209",
               "2210",
               "2211",
               "2213",
               "2215",
               "2231",
               "2232",
               "2233",
               "2235",
               "2236",
               "2237",
               "2239",
               "2240",
               "2241",
               "2244",
               "2289"
           ];
           let price = Double.random(in: 1..<100)
           let quantity = Double.random(in: 1..<5)
           return EMSCartItem(itemId: itemIds[Int.random(in: 0..<itemIds.count)], price: price, quantity: quantity)
       }
}

struct PredictView_Previews: PreviewProvider {
    static var previews: some View {
        PredictView()
    }
}
