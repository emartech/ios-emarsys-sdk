//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

struct LoggingPredict: PredictInstance {
    let sdkLogger: SdkLogger

    func trackCart(items: [any CartItem]) {
        
    }
    
    func trackPurchase(orderId: String, items: [any CartItem]) {
        
    }
    
    func trackItemView(itemId: String) {
        
    }
    
    func trackCategoryView(categoryPath: String) {
        
    }
    
    func trackSearchTerm(_ searchTerm: String) {
        
    }
    
    func trackTag(_ tag: String, attributes: [String : String]?) {
        
    }
    
    func trackRecommendationClick(product: any Product) {
        
    }
    
    func recommendProducts(logic: Logic, filters: [Filter]?, limit: Int?, availabilityZone: String?) async -> [any Product] {
        return []
    }
}
