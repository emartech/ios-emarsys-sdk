//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

@SdkActor
protocol PredictApi {
    func trackCart(items: [CartItem])
    func trackPurchase(orderId: String, items: [CartItem])
    func trackItemView(itemId: String)
    func trackCategoryView(categoryPath: String)
    func trackSearchTerm(_ searchTerm: String)
    func trackTag(_ tag: String, attributes: [String: String]?)
    func trackRecommendationClick(product: Product)
    func recommendProducts(logic: Logic, filters: [Filter]?, limit: Int?, availabilityZone: String?) async -> [Product]
}
