//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

import Foundation


struct RecommendedProduct: Product, Equatable {
    let productId: String
    let title: String
    let linkUrl: String
    let feature: String
    let cohort: String
    let customFields: [String: String?] = [String: String?]()
    let imageUrl: URL? = nil
    let zoomImageUrl: URL? = nil
    let categoryPath: String? = nil
    let available: Bool = false
    let productDescription: String? = nil
    let price: Float? = nil
    let msrp: Float? = nil
    let album: String? = nil
    let actor: String? = nil
    let artist: String? = nil
    let author: String? = nil
    let brand: String? = nil
    let year: Int? = nil
}
