//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSDependencyContainer.h"
#import "EMSDependencyInjection.h"
#import "Emarsys.h"
#import "EMSResponseModel.h"
#import "EmarsysTestUtils.h"
#import "EMSCartItem.h"
#import "EMSWaiter.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"
#import "EMSLogic.h"
#import "EMSRecommendationFilter.h"
#import "EMSProductBuilder.h"
#import "EMSProduct.h"
#import "EMSProduct+Emarsys.h"
#import "XCTestCase+Helper.h"

@interface PredictIntegrationDependencyContainer : EMSDependencyContainer

@property(nonatomic, strong) NSMutableArray *expectations;
@property(nonatomic, strong) EMSResponseModel *lastResponseModel;

- (instancetype)initWithConfig:(EMSConfig *)config
                  expectations:(NSArray<XCTestExpectation *> *)expectations;

@end

@implementation PredictIntegrationDependencyContainer

- (instancetype)initWithConfig:(EMSConfig *)config
                  expectations:(NSArray<XCTestExpectation *> *)expectations {
    if (self = [super initWithConfig:config]) {
        _expectations = expectations.mutableCopy;
    }
    return self;
}

- (void (^)(NSString *, EMSResponseModel *))createSuccessBlock {
    __weak typeof(self) weakSelf = self;
    return ^(NSString *requestId, EMSResponseModel *response) {
        [super createSuccessBlock](requestId, response);
        weakSelf.lastResponseModel = response;
        XCTestExpectation *expectation = [weakSelf popExpectation];
        [expectation fulfill];
    };
}

- (XCTestExpectation *)popExpectation {
    XCTestExpectation *expectation = self.expectations.firstObject;
    [self.expectations removeObject:expectation];
    return expectation;
}

@end


@interface PredictIntegrationTests : XCTestCase

@property(nonatomic, strong) PredictIntegrationDependencyContainer *dependencyContainer;
@property(nonatomic, strong) NSArray<XCTestExpectation *> *expectations;

@end

@implementation PredictIntegrationTests

- (void)setUp {
    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
        [builder setMerchantId:@"1428C8EE286EC34B"];
    }];
    
    self.expectations = @[
        [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"]];
    self.dependencyContainer = [[PredictIntegrationDependencyContainer alloc] initWithConfig:config
                                                                                expectations:self.expectations];
    [EmarsysTestUtils setupEmarsysWithConfig:config
                         dependencyContainer:self.dependencyContainer];
    
    [self waitATickOnOperationQueue:self.dependencyContainer.publicApiOperationQueue];
    [self waitATickOnOperationQueue:self.dependencyContainer.coreOperationQueue];
}

- (void)tearDown {
    [self waitATickOnOperationQueue:self.dependencyContainer.publicApiOperationQueue];
    [self waitATickOnOperationQueue:self.dependencyContainer.coreOperationQueue];
    [self.dependencyContainer.expectations removeAllObjects];
    [EmarsysTestUtils tearDownEmarsys];
}

-(void)testTrackCart_shouldSendRequest_withCartItems {
    NSString *expectedQueryParams = @"ca=i%3A2508%2Cp%3A200%2Cq%3A100%7Ci%3A2073%2Cp%3A201%2Cq%3A101";
    
    [self.dependencyContainer.expectations addObject:[[XCTestExpectation alloc] initWithDescription:@"waitForPredictFunction"]];
    
    [Emarsys.predict trackCartWithCartItems:@[
        [EMSCartItem itemWithItemId:@"2508"
                              price:200.0
                           quantity:100.0],
        [EMSCartItem itemWithItemId:@"2073"
                              price:201.0
                           quantity:101.0]
    ]];
    
    [EMSWaiter waitForExpectations:self.dependencyContainer.expectations
                           timeout:10];
    
    XCTAssertTrue([self.dependencyContainer.lastResponseModel statusCode] >= 200 && [self.dependencyContainer.lastResponseModel statusCode] <= 299);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedQueryParams]);
}

-(void)testTrackPurchaseWithOrderId_shouldSendRequest_withOrderIdAndItems {
    NSString *expectedOrderIdQueryParams = @"oi=orderId";
    NSString *expectedItemsQueryParams = @"co=i%3A2508%2Cp%3A200%2Cq%3A100%7Ci%3A2073%2Cp%3A201%2Cq%3A101";
    
    [self.dependencyContainer.expectations addObject:[[XCTestExpectation alloc] initWithDescription:@"waitForPredictFunction"]];
    
    [Emarsys.predict trackPurchaseWithOrderId:@"orderId"
                                        items:@[
        [EMSCartItem itemWithItemId:@"2508"
                              price:200.0
                           quantity:100.0],
        [EMSCartItem itemWithItemId:@"2073"
                              price:201.0
                           quantity:101.0]
    ]];
    
    [EMSWaiter waitForExpectations:self.dependencyContainer.expectations
                           timeout:10];
    
    XCTAssertEqual(self.dependencyContainer.lastResponseModel.statusCode, 200);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedOrderIdQueryParams]);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedItemsQueryParams]);
}

-(void)testTrackCategoryViewWithCategoryPath_shouldSendRequest_withCategoryPath {
    NSString *expectedQueryParams = @"vc=DESIGNS%3ELiving%20Room";
    
    [self.dependencyContainer.expectations addObject:[[XCTestExpectation alloc] initWithDescription:@"waitForPredictFunction"]];
    
    [Emarsys.predict trackCategoryViewWithCategoryPath:@"DESIGNS>Living Room"];
    
    [EMSWaiter waitForExpectations:self.dependencyContainer.expectations
                           timeout:10];
    
    XCTAssertEqual(self.dependencyContainer.lastResponseModel.statusCode, 200);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedQueryParams]);
}

- (void)testTrackItemViewWithItemId_shouldSendRequest_withItemId {
    NSString *expectedQueryParams = @"v=i%3A2508%252B";
    
    [self.dependencyContainer.expectations addObject:[[XCTestExpectation alloc] initWithDescription:@"waitForPredictFunction"]];
    
    [Emarsys.predict trackItemViewWithItemId:@"2508+"];
    
    [EMSWaiter waitForExpectations:self.dependencyContainer.expectations
                           timeout:10];
    
    XCTAssertEqual(self.dependencyContainer.lastResponseModel.statusCode, 200);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedQueryParams]);
}

- (void)testTrackRecommendationClick_shouldSendRequest_withProduct {
    NSString *expectedQueryParams = @"v=i%3A2508%2Ct%3AtestFeature%2Cc%3AtestCohort";
    
    [self retryWithRunnerBlock:^(XCTestExpectation *expectation) {
        EMSProduct *product = [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
            [builder setRequiredFieldsWithProductId:@"2508"
                                              title:@"testTitle"
                                            linkUrl:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                            feature:@"testFeature"
                                             cohort:@"testCohort"];
        }];
        
        [self.dependencyContainer.expectations addObject:[[XCTestExpectation alloc] initWithDescription:@"waitForPredictFunction"]];
        
        [Emarsys.predict trackRecommendationClick:product];
        
        [expectation fulfill];
        
    }
                assertionBlock:^(XCTWaiterResult waiterResult) {
        [EMSWaiter waitForExpectations:self.dependencyContainer.expectations
                               timeout:10];
        
        XCTAssertEqual(self.dependencyContainer.lastResponseModel.statusCode, 200);
        XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedQueryParams]);
    }
                    retryCount:3];
    
}

-(void)testTrackSearchWithSearchTerm_shouldSendRequest_withSearchTerm {
    NSString *expectedQueryParams = @"q=searchTerm";
    
    [self.dependencyContainer.expectations addObject:[[XCTestExpectation alloc] initWithDescription:@"waitForPredictFunction"]];
    
    [Emarsys.predict trackSearchWithSearchTerm:@"searchTerm"];
    
    [EMSWaiter waitForExpectations:self.dependencyContainer.expectations
                           timeout:10];
    
    XCTAssertEqual(self.dependencyContainer.lastResponseModel.statusCode, 200);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedQueryParams]);
}

- (void)testVisitorId_shouldSimulateLoginFlow {
    if (self.dependencyContainer.expectations.count > 0) {
        [self waitForExpectations:self.dependencyContainer.expectations];
    }
    
    XCTestExpectation *expectationSetContact = [[XCTestExpectation alloc] initWithDescription:@"waitForSetContact"];
    XCTestExpectation *expectationClearContact = [[XCTestExpectation alloc] initWithDescription:@"waitForClearContact"];
    XCTestExpectation *expectationSearchTerm = [[XCTestExpectation alloc] initWithDescription:@"waitForTrackSearchWithSearchTerm1"];
    XCTestExpectation *expectationTrackItemWithItemId = [[XCTestExpectation alloc] initWithDescription:@"waitForTrackItemWithItemId"];
    [self.dependencyContainer setExpectations:[@[expectationSearchTerm,
                                            expectationClearContact,
                                            expectationSetContact,
                                            expectationTrackItemWithItemId] mutableCopy]];
    
    NSString *expectedQueryParams = @"q=searchTerm";
    NSString *expectedTrackingQueryParams = @"v=i%3A2508%252B";
    NSString *expectedContactUrl = @"contact-token";
    NSString *visitorId;
    NSString *visitorId2;
    
    [Emarsys.predict trackSearchWithSearchTerm:@"searchTerm"];
    [EMSWaiter waitForExpectations:@[expectationSearchTerm]
                           timeout:10];
    
    XCTAssertEqual(self.dependencyContainer.lastResponseModel.statusCode, 200);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedQueryParams]);
    visitorId = self.dependencyContainer.lastResponseModel.cookies[@"cdv"].value;
    [[visitorId shouldNot] beNil];
    
    [Emarsys clearContact];
    
    [Emarsys setContactWithContactFieldId:@62470
                        contactFieldValue:@"test2@test.com"
                          completionBlock:^(NSError * _Nullable error) {
    }];
    
    [EMSWaiter waitForExpectations:@[expectationSetContact, expectationClearContact]
                           timeout:10];
    
    XCTAssertEqual(self.dependencyContainer.lastResponseModel.statusCode, 200);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedContactUrl]);
    
    [Emarsys.predict trackItemViewWithItemId:@"2508+"];
    [EMSWaiter waitForExpectations:@[expectationTrackItemWithItemId]
                           timeout:10];
    
    XCTAssertEqual(self.dependencyContainer.lastResponseModel.statusCode, 200);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedTrackingQueryParams]);
    visitorId2 = self.dependencyContainer.lastResponseModel.cookies[@"cdv"].value;
    [[visitorId2 shouldNot] beNil];
}

NSString *searchTerm = @"Ropa";
NSString *categoryPath = @"Ropa bebe nina>Ropa Interior";

void (^assertWithLogic)(EMSLogic *logic, int expectedCount) = ^(EMSLogic *logic, int expectedCount) {
    __block NSArray *returnedProducts = nil;
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForProducts"];
    [Emarsys.predict recommendProductsWithLogic:logic
                                        filters:@[[EMSRecommendationFilter excludeFilterWithField:@"price"
                                                                                          isValue:@""]]
                                          limit:@2
                                  productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
        returnedProducts = products;
        [expectation fulfill];
    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:30];
    XCTAssertEqual(XCTWaiterResultCompleted, waiterResult);
    XCTAssertNotNil(returnedProducts);
    XCTAssertEqual([returnedProducts count], expectedCount);
};

- (void)testRecommendProductsSearch_shouldRecommendProductsBySearchTerm_withSearchTerm {
    __block NSArray *returnedProducts = nil;
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForProducts"];
    [Emarsys.predict recommendProductsWithLogic:[EMSLogic searchWithSearchTerm: searchTerm]
                                        filters:@[[EMSRecommendationFilter excludeFilterWithField:@"price"
                                                                                          isValue:@""]]
                                          limit:@2
                                  productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
        returnedProducts = products;
        [expectation fulfill];
    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:30];
    XCTAssertEqual(XCTWaiterResultCompleted, waiterResult);
    XCTAssertNotNil(returnedProducts);
}

- (void)testRecommendProductsSearch_shouldRecommendProductsBySearchTerm {
    [Emarsys.predict trackSearchWithSearchTerm: searchTerm];
    
    __block NSArray *returnedProducts = nil;
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForProducts"];
    [Emarsys.predict recommendProductsWithLogic:EMSLogic.search
                                        filters:@[[EMSRecommendationFilter excludeFilterWithField:@"price"
                                                                                          isValue:@""]]
                                          limit:@2
                                  productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
        returnedProducts = products;
        [expectation fulfill];
    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:30];
    XCTAssertEqual(XCTWaiterResultCompleted, waiterResult);
    XCTAssertNotNil(returnedProducts);
}

- (void)testRecommendProductsCart_shouldRecommendProductsByCartItems_withCartItems {
    EMSCartItem *cartItem1 = [[EMSCartItem alloc] initWithItemId:@"cartItemId1"
                                                           price:123
                                                        quantity:1];
    EMSCartItem *cartItem2 = [[EMSCartItem alloc] initWithItemId:@"cartItemId2"
                                                           price:456
                                                        quantity:2];
    
    EMSLogic *logic = [EMSLogic cartWithCartItems:@[cartItem1, cartItem2]];
    assertWithLogic(logic, 2);
}

- (void)testRecommendProductsCart_shouldRecommendProductsByCartItems {
    EMSCartItem *cartItem1 = [[EMSCartItem alloc] initWithItemId:@"cartItemId1"
                                                           price:123
                                                        quantity:1];
    EMSCartItem *cartItem2 = [[EMSCartItem alloc] initWithItemId:@"cartItemId2"
                                                           price:456
                                                        quantity:2];
    
    [Emarsys.predict trackCartWithCartItems:@[cartItem1, cartItem2]];
    assertWithLogic(EMSLogic.cart, 2);
}

- (void)testRecommendProductsRelated_shouldRecommendProductsByViewItemId_withViewItemId {
    [Emarsys.predict trackItemViewWithItemId:@"2200"];
    
    assertWithLogic(EMSLogic.related, 2);
}

- (void)testRecommendProductsRelated_shouldRecommendProductsByViewItemId {
    EMSLogic *logic = [EMSLogic relatedWithViewItemId:@"2200"];
    
    assertWithLogic(logic, 2);
}

- (void)testRecommendProductsCategory_shouldRecommendProductsByCategoryPath_withCategoryPath {
    EMSLogic *logic = [EMSLogic categoryWithCategoryPath: categoryPath];
    
    assertWithLogic(logic, 2);
}

- (void)testRecommendProductsPersonal_shouldRecommendProducts_withPersonal {
    EMSLogic *logic = [EMSLogic personal];
    
    assertWithLogic(logic, 2);
}

- (void)testRecommendProductsPersonal_shouldRecommendProducts_withPersonalVariants {
    EMSLogic *logic = [EMSLogic personalWithVariants:@[@"1", @"2", @"3"]];
    
    assertWithLogic(logic, 6);
}

- (void)testRecommendProductsHome_shouldRecommendProducts_withHome {
    EMSLogic *logic = [EMSLogic home];
    
    assertWithLogic(logic, 2);
}

- (void)testRecommendProductsHome_shouldRecommendProducts_withProductVariants {
    EMSLogic *logic = [EMSLogic homeWithVariants:@[@"1", @"2", @"3"]];
    
    assertWithLogic(logic, 6);
}

- (void)testRecommendProductsCategory_shouldRecommendProductsByCategoryPath {
    [Emarsys.predict trackCategoryViewWithCategoryPath: categoryPath];
    
    assertWithLogic(EMSLogic.category, 2);
}

- (void)testAlsoBought_shouldRecommendProductsByViewItemId_withViewItemId {
    EMSLogic *logic = [EMSLogic alsoBoughtWithViewItemId:@"2200"];
    
    assertWithLogic(logic, 2);
}

- (void)testAlsoBought_shouldRecommendProductsByViewItemId {
    [Emarsys.predict trackItemViewWithItemId:@"2200"];
    
    assertWithLogic(EMSLogic.alsoBought, 2);
}

- (void)testPopular_shouldRecommendProductsByCategoryPath_withCategoryPath {
    EMSLogic *logic = [EMSLogic popularWithCategoryPath: categoryPath];
    
    assertWithLogic(logic, 2);
}

- (void)testPopular_shouldRecommendProductsByCategoryPath {
    [Emarsys.predict trackCategoryViewWithCategoryPath: categoryPath];
    
    assertWithLogic(EMSLogic.popular, 2);
    
}

@end
