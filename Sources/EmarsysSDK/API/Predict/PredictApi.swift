//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

import Foundation


protocol PredictApi {
    func track(cart items: [CartItem])
    func track(purchase orderId: String, _ items: [CartItem])
    func track(itemView itemId: String)
    func track(categoryView categoryPath: String)
    func track(searchTerm: String)
    func track(_ tag: String, _ attributes: [String: String]?)
    func track(recommendationClick product: Product)
    func recommendProducts(_ logic: Logic, filters: [Filter]?, limit: Int?, availabilityZone: String?) async -> [Product]
}
