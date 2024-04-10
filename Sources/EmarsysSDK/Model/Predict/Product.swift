//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
    
import Foundation


protocol Product {
    var productId: String { get }
    var title: String { get }
    var linkUrl: String { get }
    var feature: String { get }
    var cohort: String { get }
    var customFields: [String: String?] { get }
    var imageUrl: URL? { get }
    var zoomImageUrl: URL? { get }
    var categoryPath: String? { get }
    var available: Bool { get }
    var productDescription: String? { get }
    var price: Float? { get }
    var msrp: Float? { get }
    var album: String? { get }
    var actor: String? { get }
    var artist: String? { get }
    var author: String? { get }
    var brand: String? { get }
    var year: Int? { get }
}
