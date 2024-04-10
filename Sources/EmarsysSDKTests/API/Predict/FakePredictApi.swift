//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

import Foundation
import mimic
@testable import EmarsysSDK


struct FakePredictApi: PredictInstance, Mimic {
    let fnTrackCartItems = Fn<()>()
    let fnTrackPurchase = Fn<()>()
    let fnTrackItemView = Fn<()>()
    let fnTrackCategoryView = Fn<()>()
    let fnTrackSearchTerm = Fn<()>()
    let fnTrackTag = Fn<()>()
    let fnTrackRecommendationClick = Fn<()>()
    let fnRecommendProducts = Fn<([Product])>()

    func trackCart(items: [any CartItem]) {
        return try! self.fnTrackCartItems.invoke(params: items)
    }
    
    func trackPurchase(orderId: String, items: [CartItem]) {
        return try! self.fnTrackPurchase.invoke(params: orderId, items)
    }
    
    func trackItemView(itemId: String) {
        return try! self.fnTrackItemView.invoke(params: itemId)
    }
    
    func trackCategoryView(categoryPath: String) {
        return try! self.fnTrackCategoryView.invoke(params: categoryPath)
    }
    
    func trackSearchTerm(_ searchTerm: String) {
        return try! self.fnTrackSearchTerm.invoke(params: searchTerm)
    }
    
    func trackTag(_ tag: String, attributes: [String: String]?) {
        return try! self.fnTrackTag.invoke(params: tag, attributes)
    }
    
    func trackRecommendationClick(product: Product) {
        return try! self.fnTrackRecommendationClick.invoke(params: product)
    }
    
    func recommendProducts(logic: Logic, filters: [Filter]?, limit: Int?, availabilityZone: String?) async -> [any Product] {
        return try! self.fnRecommendProducts.invoke(params: logic, filters, limit, availabilityZone)
    }
}
