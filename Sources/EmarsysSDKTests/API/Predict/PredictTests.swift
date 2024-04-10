//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
import mimic
@testable import EmarsysSDK

@SdkActor
final class PredictTests: EmarsysTestCase {
    @Inject(\.sdkContext)
    var sdkContext: SdkContext
    
    @Inject(\.sdkLogger)
    var sdkLogger: SdkLogger
    
    @Inject(\.predictInternal)
    var fakePredictInternal: FakePredictApi
    
    var loggintPredict: LoggingPredict!
    var gathererPredict: GathererPredict!
    var predict: Predict<LoggingPredict, GathererPredict, FakePredictApi>!
    

    override func setUpWithError() throws {
        loggintPredict = LoggingPredict(sdkLogger: self.sdkLogger)
        gathererPredict = GathererPredict()
        
        self.sdkContext.setFeatures(features: [.predict])
        self.sdkContext.setSdkState(sdkState: .active)
        
        predict = Predict(loggingInstance: loggintPredict, gathererInstance: gathererPredict, internalInstance: fakePredictInternal, sdkContext: self.sdkContext)
    }

    func testTrackCartItems_shouldDelegateToInstance() async throws {
        let cartItems: [CartItem] = [
            TestCartItem(itemId: "id1", price: 1.0, quantity: 1.0),
            TestCartItem(itemId: "id2", price: 2.0, quantity: 2.0),
            TestCartItem(itemId: "id3", price: 3.0, quantity: 3.0)
        ]
        
        self.fakePredictInternal.when(\.fnTrackCartItems).thenReturn(())
        
        self.predict.trackCart(items: cartItems)
        
        _ = try self.fakePredictInternal
            .verify(\.fnTrackCartItems)
            .wasCalled(Arg.eq(cartItems))
    }

    func testTrackPurchase_shouldDelegateToInstance() throws {
        let orderId = "testOrderId"
        let cartItems = [
            TestCartItem(itemId: "id1", price: 1.0, quantity: 1.0),
            TestCartItem(itemId: "id2", price: 2.0, quantity: 2.0),
            TestCartItem(itemId: "id3", price: 3.0, quantity: 3.0)
        ]
        self.fakePredictInternal.when(\.fnTrackPurchase).thenReturn(())
        
        self.predict.trackPurchase(orderId: orderId, items: cartItems)
        
        let _ = try! self.fakePredictInternal
            .verify(\.fnTrackPurchase)
            .wasCalled(Arg.eq(orderId), Arg.eq(cartItems))
    }

    func testTrackItemView_shouldDelegateToInstance() throws {
        let itemId = "testOrderId"
       
        self.fakePredictInternal.when(\.fnTrackItemView).thenReturn(())
        
        self.predict.trackItemView(itemId: itemId)
        
        let _ = try! self.fakePredictInternal
            .verify(\.fnTrackItemView)
            .wasCalled(Arg.eq(itemId))
    }

    func testTrackCategoryView_shouldDelegateToInstance() throws {
        let categoryPath = "testCategoryPath"
       
        self.fakePredictInternal.when(\.fnTrackCategoryView).thenReturn(())
        
        self.predict.trackCategoryView(categoryPath: categoryPath)
        
        let _ = try! self.fakePredictInternal
            .verify(\.fnTrackCategoryView)
            .wasCalled(Arg.eq(categoryPath))
    }

    func testTrackSearchTerm_shouldDelegateToInstance() throws {
        let searchTerm = "testSearchTerm"
       
        self.fakePredictInternal.when(\.fnTrackSearchTerm).thenReturn(())
        
        self.predict.trackSearchTerm(searchTerm)
        
        let _ = try! self.fakePredictInternal
            .verify(\.fnTrackSearchTerm)
            .wasCalled(Arg.eq(searchTerm))
    }

    func testTrackTag_shouldDelegateToInstance() throws {
        let tag = "testTag"
       
        self.fakePredictInternal.when(\.fnTrackTag).thenReturn(())
        
        self.predict.trackTag(tag, attributes: nil)
        
        let _ = try! self.fakePredictInternal
            .verify(\.fnTrackTag)
            .wasCalled(Arg.eq(tag), Arg.nil)
    }

    func testTrackRecommendationClick_shouldDelegateToInstance() throws {
        let product = RecommendedProduct(productId: "testId", title: "title", linkUrl: "linkURL", feature: "feature", cohort: "cohort")
       
        self.fakePredictInternal.when(\.fnTrackRecommendationClick).thenReturn(())
        
        self.predict.trackRecommendationClick(product: product)
        
        let _ = try! self.fakePredictInternal
            .verify(\.fnTrackRecommendationClick)
            .wasCalled(Arg.eq(product))
    }
}

struct TestCartItem: CartItem {
    var itemId: String
    var price: Double
    var quantity: Double
}
