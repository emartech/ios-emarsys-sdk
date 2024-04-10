//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        
import Foundation

typealias PredictInstance = ActivationAware & PredictApi

class Predict<LoggingInstance: PredictInstance, GathererInstance: PredictInstance, InternalInstance: PredictInstance>: GenericApi<LoggingInstance, GathererInstance, InternalInstance>, PredictInstance {
   
    func trackCart(items: [any CartItem]) {
        guard let active = self.active as? PredictApi else {
            return
        }
        active.trackCart(items: items)
    }
    
    func trackPurchase(orderId: String, items: [any CartItem]) {
        guard let active = self.active as? PredictApi else {
            return
        }
        active.trackPurchase(orderId: orderId, items: items)
    }
    
    func trackItemView(itemId: String) {
        guard let active = self.active as? PredictApi else {
            return
        }
        active.trackItemView(itemId: itemId)
    }
    
    func trackCategoryView(categoryPath: String) {
        guard let active = self.active as? PredictApi else {
            return
        }
        active.trackCategoryView(categoryPath: categoryPath)
    }
    
    func trackSearchTerm(_ searchTerm: String) {
        guard let active = self.active as? PredictApi else {
            return
        }
        active.trackSearchTerm(searchTerm)
    }
    
    func trackTag(_ tag: String, attributes: [String : String]?) {
        guard let active = self.active as? PredictApi else {
            return
        }
        active.trackTag(tag, attributes: attributes)
    }
    
    func trackRecommendationClick(product: any Product) {
        guard let active = self.active as? PredictApi else {
            return
        }
        active.trackRecommendationClick(product: product)
    }
    
    func recommendProducts(logic: Logic, filters: [Filter]?, limit: Int?, availabilityZone: String?) async -> [any Product] {
        return if let active = self.active as? PredictApi {
            await active.recommendProducts(logic: logic, filters: filters, limit: limit, availabilityZone: availabilityZone)
        } else {
            []
        }
    }
}
