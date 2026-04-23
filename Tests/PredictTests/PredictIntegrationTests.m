//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
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

@property(nonatomic, strong) NSArray<XCTestExpectation *> *expectations;
@property(nonatomic, strong) PredictIntegrationDependencyContainer *dependencyContainer;

@end

@implementation PredictIntegrationTests

- (void)setUp {
    [super setUp];

    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
        [builder setMerchantId:@"1428C8EE286EC34B"];
    }];

    XCTestExpectation *setupExpectation = [[XCTestExpectation alloc] initWithDescription:@"waitForSetup"];
    self.dependencyContainer = [[PredictIntegrationDependencyContainer alloc] initWithConfig:config
                                                                               expectations:@[setupExpectation]];
    [EmarsysTestUtils setupEmarsysWithConfig:config
                         dependencyContainer:self.dependencyContainer];

    [XCTWaiter waitForExpectations:@[setupExpectation]
                           timeout:10];

    [self.dependencyContainer setExpectations:[@[] mutableCopy]];
    [self waitATickOnOperationQueue:self.dependencyContainer.publicApiOperationQueue];
    [self waitATickOnOperationQueue:self.dependencyContainer.coreOperationQueue];

    self.expectations = @[
        [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"]];
    [self.dependencyContainer setExpectations:self.expectations.mutableCopy];
}

- (void)tearDown {
    [EmarsysTestUtils tearDownEmarsys];
    [super tearDown];
}

- (void)testTrackCartWithCartItems_shouldSendRequestWithCartItems {
    NSString *expectedQueryParams = @"ca=i%3A2508%2Cp%3A200%2Cq%3A100%7Ci%3A2073%2Cp%3A201%2Cq%3A101";

    [Emarsys.predict trackCartWithCartItems:@[
        [EMSCartItem itemWithItemId:@"2508"
                              price:200.0
                           quantity:100.0],
        [EMSCartItem itemWithItemId:@"2073"
                              price:201.0
                           quantity:101.0]
    ]];

    [EMSWaiter waitForExpectations:self.expectations
                           timeout:10];

    XCTAssertTrue([self.dependencyContainer.lastResponseModel statusCode] >= 200 &&
                  [self.dependencyContainer.lastResponseModel statusCode] <= 299);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedQueryParams]);
}

- (void)testTrackPurchaseWithOrderIdItems_shouldSendRequestWithOrderIdAndItems {
    NSString *expectedOrderIdQueryParams = @"oi=orderId";
    NSString *expectedItemsQueryParams = @"co=i%3A2508%2Cp%3A200%2Cq%3A100%7Ci%3A2073%2Cp%3A201%2Cq%3A101";

    [Emarsys.predict trackPurchaseWithOrderId:@"orderId"
                                        items:@[
                                            [EMSCartItem itemWithItemId:@"2508"
                                                                  price:200.0
                                                               quantity:100.0],
                                            [EMSCartItem itemWithItemId:@"2073"
                                                                  price:201.0
                                                               quantity:101.0]
                                        ]];

    [EMSWaiter waitForExpectations:self.expectations
                           timeout:10];

    XCTAssertEqual([self.dependencyContainer.lastResponseModel statusCode], 200);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedOrderIdQueryParams]);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedItemsQueryParams]);
}

- (void)testTrackCategoryViewWithCategoryPath_shouldSendRequestWithCategoryPath {
    NSString *expectedQueryParams = @"vc=DESIGNS%3ELiving%20Room";

    [Emarsys.predict trackCategoryViewWithCategoryPath:@"DESIGNS>Living Room"];

    [EMSWaiter waitForExpectations:self.expectations
                           timeout:10];

    XCTAssertEqual([self.dependencyContainer.lastResponseModel statusCode], 200);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedQueryParams]);
}

- (void)testTrackItemViewWithItemId_shouldSendRequestWithItemId {
    NSString *expectedQueryParams = @"v=i%3A2508%252B";

    [Emarsys.predict trackItemViewWithItemId:@"2508+"];

    [EMSWaiter waitForExpectations:self.expectations
                           timeout:10];

    XCTAssertEqual([self.dependencyContainer.lastResponseModel statusCode], 200);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedQueryParams]);
}

- (void)testTrackRecommendationClick_shouldSendRequestWithProduct {
    NSString *expectedQueryParams = @"v=i%3A2508%2Ct%3AtestFeature%2Cc%3AtestCohort";

    [self retryWithRunnerBlock:^(XCTestExpectation *expectation) {
        EMSProduct *product = [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
            [builder setRequiredFieldsWithProductId:@"2508"
                                              title:@"testTitle"
                                            linkUrl:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                            feature:@"testFeature"
                                             cohort:@"testCohort"];
        }];

        [Emarsys.predict trackRecommendationClick:product];

        [expectation fulfill];
    }
        assertionBlock:^(XCTWaiterResult waiterResult) {
            [EMSWaiter waitForExpectations:self.expectations
                                   timeout:10];

            XCTAssertEqual([self.dependencyContainer.lastResponseModel statusCode], 200);
            XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedQueryParams]);
        }
            retryCount:3];
}

- (void)testTrackSearchWithSearchTerm_shouldSendRequestWithSearchTerm {
    NSString *expectedQueryParams = @"q=searchTerm";

    [Emarsys.predict trackSearchWithSearchTerm:@"searchTerm"];

    [EMSWaiter waitForExpectations:self.expectations
                           timeout:10];

    XCTAssertEqual([self.dependencyContainer.lastResponseModel statusCode], 200);
    XCTAssertTrue([self.dependencyContainer.lastResponseModel.requestModel.url.absoluteString containsString:expectedQueryParams]);
}

- (void)testVisitorId_shouldSimulateLoginFlow {
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
    XCTAssertNotNil(visitorId);

    [Emarsys clearContact];

    [Emarsys setContactWithContactFieldId:@2575
                        contactFieldValue:@"test1@test.com"
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
    XCTAssertNotNil(visitorId2);
}

#pragma mark - recommendProducts

- (void)testRecommendProducts_searchShouldRecommendProductsBySearchTermWithSearchTerm {
    NSString *searchTerm = @"Ropa";
    __block NSArray *returnedProducts = nil;

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForProducts"];
    [Emarsys.predict recommendProductsWithLogic:[EMSLogic searchWithSearchTerm:searchTerm]
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

- (void)testRecommendProducts_searchShouldRecommendProductsBySearchTerm {
    NSString *searchTerm = @"Ropa";
    [Emarsys.predict trackSearchWithSearchTerm:searchTerm];

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

- (void)testRecommendProducts_cartShouldRecommendProductsByCartItemsWithCartItems {
    EMSCartItem *cartItem1 = [[EMSCartItem alloc] initWithItemId:@"cartItemId1"
                                                           price:123
                                                        quantity:1];
    EMSCartItem *cartItem2 = [[EMSCartItem alloc] initWithItemId:@"cartItemId2"
                                                           price:456
                                                        quantity:2];

    EMSLogic *logic = [EMSLogic cartWithCartItems:@[cartItem1, cartItem2]];
    [self assertWithLogic:logic expectedCount:2];
}

- (void)testRecommendProducts_cartShouldRecommendProductsByCartItems {
    EMSCartItem *cartItem1 = [[EMSCartItem alloc] initWithItemId:@"cartItemId1"
                                                           price:123
                                                        quantity:1];
    EMSCartItem *cartItem2 = [[EMSCartItem alloc] initWithItemId:@"cartItemId2"
                                                           price:456
                                                        quantity:2];

    [Emarsys.predict trackCartWithCartItems:@[cartItem1, cartItem2]];
    [self assertWithLogic:EMSLogic.cart expectedCount:2];
}

- (void)testRecommendProducts_relatedShouldRecommendProductsByViewItemIdWithViewItemId {
    [Emarsys.predict trackItemViewWithItemId:@"2200"];

    [self assertWithLogic:EMSLogic.related expectedCount:2];
}

- (void)testRecommendProducts_relatedShouldRecommendProductsByViewItemId {
    EMSLogic *logic = [EMSLogic relatedWithViewItemId:@"2200"];

    [self assertWithLogic:logic expectedCount:2];
}

- (void)testRecommendProducts_categoryShouldRecommendProductsByCategoryPathWithCategoryPath {
    NSString *categoryPath = @"Ropa bebe nina>Ropa Interior";
    EMSLogic *logic = [EMSLogic categoryWithCategoryPath:categoryPath];

    [self assertWithLogic:logic expectedCount:2];
}

- (void)testRecommendProducts_personalShouldRecommendProducts {
    EMSLogic *logic = [EMSLogic personal];

    [self assertWithLogic:logic expectedCount:2];
}

- (void)testRecommendProducts_personalShouldRecommendProductsWithVariants {
    EMSLogic *logic = [EMSLogic personalWithVariants:@[@"1", @"2", @"3"]];

    [self assertWithLogic:logic expectedCount:6];
}

- (void)testRecommendProducts_homeShouldRecommendProducts {
    EMSLogic *logic = [EMSLogic home];

    [self assertWithLogic:logic expectedCount:2];
}

- (void)testRecommendProducts_homeShouldRecommendProductsWithVariants {
    EMSLogic *logic = [EMSLogic homeWithVariants:@[@"1", @"2", @"3"]];

    [self assertWithLogic:logic expectedCount:6];
}

- (void)testRecommendProducts_categoryShouldRecommendProductsByCategoryPath {
    NSString *categoryPath = @"Ropa bebe nina>Ropa Interior";
    [Emarsys.predict trackCategoryViewWithCategoryPath:categoryPath];

    [self assertWithLogic:EMSLogic.category expectedCount:2];
}

- (void)testRecommendProducts_alsoBoughtShouldRecommendProductsByViewItemIdWithViewItemId {
    EMSLogic *logic = [EMSLogic alsoBoughtWithViewItemId:@"2200"];

    [self assertWithLogic:logic expectedCount:2];
}

- (void)testRecommendProducts_alsoBoughtShouldRecommendProductsByViewItemId {
    [Emarsys.predict trackItemViewWithItemId:@"2200"];

    [self assertWithLogic:EMSLogic.alsoBought expectedCount:2];
}

- (void)testRecommendProducts_popularShouldRecommendProductsByCategoryPathWithCategoryPath {
    NSString *categoryPath = @"Ropa bebe nina>Ropa Interior";
    EMSLogic *logic = [EMSLogic popularWithCategoryPath:categoryPath];

    [self assertWithLogic:logic expectedCount:2];
}

- (void)testRecommendProducts_popularShouldRecommendProductsByCategoryPath {
    NSString *categoryPath = @"Ropa bebe nina>Ropa Interior";
    [Emarsys.predict trackCategoryViewWithCategoryPath:categoryPath];

    [self assertWithLogic:EMSLogic.popular expectedCount:2];
}

- (void)assertWithLogic:(EMSLogic *)logic expectedCount:(int)expectedCount {
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
}

@end
