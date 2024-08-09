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

SPEC_BEGIN(PredictIntegrationTests)

        __block NSArray<XCTestExpectation *> *expectations;
        __block PredictIntegrationDependencyContainer *dependencyContainer;

        beforeEach(^{
            [EmarsysTestUtils tearDownEmarsys];

            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.emarsys.predict"];
            [userDefaults removeObjectForKey:@"contactFieldValue"];
            [userDefaults removeObjectForKey:@"visitorId"];
            [userDefaults synchronize];

            EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setMerchantId:@"1428C8EE286EC34B"];
            }];
            [MEExperimental enableFeature:EMSInnerFeature.predict];

            expectations = @[
                    [[XCTestExpectation alloc] initWithDescription:@"waitForExpectation"]];
            dependencyContainer = [[PredictIntegrationDependencyContainer alloc] initWithConfig:config
                                                                                   expectations:expectations];
            [EMSDependencyInjection setupWithDependencyContainer:dependencyContainer];

            XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForSetup"];
            [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue addOperationWithBlock:^{
                [expectation fulfill];
            }];
            XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                  timeout:10];

            [Emarsys setupWithConfig:config];
        });

        afterEach(^{
            [EmarsysTestUtils tearDownEmarsys];
        });

        describe(@"trackCartWithCartItems:", ^{

            it(@"should send request with cartItems", ^{
                NSString *expectedQueryParams = @"ca=i%3A2508%2Cp%3A200%2Cq%3A100%7Ci%3A2073%2Cp%3A201%2Cq%3A101";

                [Emarsys.predict trackCartWithCartItems:@[
                        [EMSCartItem itemWithItemId:@"2508"
                                              price:200.0
                                           quantity:100.0],
                        [EMSCartItem itemWithItemId:@"2073"
                                              price:201.0
                                           quantity:101.0]
                ]];

                [EMSWaiter waitForExpectations:expectations
                                       timeout:10];

                [[theValue([dependencyContainer.lastResponseModel statusCode]) should] beBetween:theValue(200)
                                                                                             and:theValue(299)];
                [[dependencyContainer.lastResponseModel.requestModel.url.absoluteString should] containString:expectedQueryParams];
            });
        });

        describe(@"trackPurchaseWithOrderId:items:", ^{

            it(@"should send request with orderId and items", ^{
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

                [EMSWaiter waitForExpectations:expectations
                                       timeout:10];

                [[theValue([dependencyContainer.lastResponseModel statusCode]) should] equal:theValue(200)];
                [[dependencyContainer.lastResponseModel.requestModel.url.absoluteString should] containString:expectedOrderIdQueryParams];
                [[dependencyContainer.lastResponseModel.requestModel.url.absoluteString should] containString:expectedItemsQueryParams];
            });
        });

        describe(@"trackCategoryViewWithCategoryPath:", ^{

            it(@"should send request with category path", ^{
                NSString *expectedQueryParams = @"vc=DESIGNS%3ELiving%20Room";

                [Emarsys.predict trackCategoryViewWithCategoryPath:@"DESIGNS>Living Room"];

                [EMSWaiter waitForExpectations:expectations
                                       timeout:10];

                [[theValue([dependencyContainer.lastResponseModel statusCode]) should] equal:theValue(200)];
                [[dependencyContainer.lastResponseModel.requestModel.url.absoluteString should] containString:expectedQueryParams];
            });
        });

        describe(@"trackItemViewWithItemId:", ^{

            it(@"should send request with item id", ^{
                NSString *expectedQueryParams = @"v=i%3A2508%252B";

                [Emarsys.predict trackItemViewWithItemId:@"2508+"];

                [EMSWaiter waitForExpectations:expectations
                                       timeout:10];

                [[theValue([dependencyContainer.lastResponseModel statusCode]) should] equal:theValue(200)];
                [[dependencyContainer.lastResponseModel.requestModel.url.absoluteString should] containString:expectedQueryParams];
            });
        });

        describe(@"trackRecommendationClick:", ^{

            it(@"should send request with product", ^{
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
                                [EMSWaiter waitForExpectations:expectations
                                                       timeout:10];

                                [[theValue([dependencyContainer.lastResponseModel statusCode]) should] equal:theValue(200)];
                                [[dependencyContainer.lastResponseModel.requestModel.url.absoluteString should] containString:expectedQueryParams];
                            }
                                retryCount:3];

            });
        });

        describe(@"trackSearchWithSearchTerm:", ^{

            it(@"should send request with search term", ^{
                NSString *expectedQueryParams = @"q=searchTerm";

                [Emarsys.predict trackSearchWithSearchTerm:@"searchTerm"];

                [EMSWaiter waitForExpectations:expectations
                                       timeout:10];

                [[theValue([dependencyContainer.lastResponseModel statusCode]) should] equal:theValue(200)];
                [[dependencyContainer.lastResponseModel.requestModel.url.absoluteString should] containString:expectedQueryParams];
            });
        });

        describe(@"visitorId", ^{

            it(@"should simulate login flow", ^{
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForSetContact"];
                XCTestExpectation *expectationSearchTerm1 = [[XCTestExpectation alloc] initWithDescription:@"waitForTrackSearchWithSearchTerm1"];
                XCTestExpectation *expectationSearchTerm2 = [[XCTestExpectation alloc] initWithDescription:@"waitForTrackSearchWithSearchTerm2"];
                [dependencyContainer setExpectations:[@[expectationSearchTerm1, expectation, expectationSearchTerm2] mutableCopy]];

                NSString *expectedQueryParams = @"q=searchTerm";
                NSString *visitorId;
                NSString *visitorId2;

                [Emarsys.predict trackSearchWithSearchTerm:@"searchTerm"];
                [EMSWaiter waitForExpectations:@[expectationSearchTerm1]
                                       timeout:10];

                [[theValue([dependencyContainer.lastResponseModel statusCode]) should] equal:theValue(200)];
                [[dependencyContainer.lastResponseModel.requestModel.url.absoluteString should] containString:expectedQueryParams];
                visitorId = dependencyContainer.lastResponseModel.cookies[@"cdv"].value;
                [[visitorId shouldNot] beNil];

                [Emarsys clearContact];

                
                [Emarsys setContactWithContactFieldId:@62470 
                                    contactFieldValue:@"test2@test.com"
                                      completionBlock:^(NSError * _Nullable error) {
                    
                }];

                [Emarsys.predict trackSearchWithSearchTerm:@"searchTerm"];
                [EMSWaiter waitForExpectations:@[expectationSearchTerm2]
                                       timeout:10];

                [[theValue([dependencyContainer.lastResponseModel statusCode]) should] equal:theValue(200)];
                [[dependencyContainer.lastResponseModel.requestModel.url.absoluteString should] containString:expectedQueryParams];
                visitorId2 = dependencyContainer.lastResponseModel.cookies[@"cdv"].value;
                [[visitorId2 shouldNot] beNil];
            });
        });

        describe(@"recommendProducts", ^{
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

            it(@"search should recommend products by searchTerm with searchTerm", ^{
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
            });

            it(@"search should recommend products by searchTerm", ^{
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
            });

            it(@"cart should recommend products by cartItems with cartItems", ^{
                EMSCartItem *cartItem1 = [[EMSCartItem alloc] initWithItemId:@"cartItemId1"
                                                                       price:123
                                                                    quantity:1];
                EMSCartItem *cartItem2 = [[EMSCartItem alloc] initWithItemId:@"cartItemId2"
                                                                       price:456
                                                                    quantity:2];

                EMSLogic *logic = [EMSLogic cartWithCartItems:@[cartItem1, cartItem2]];
                assertWithLogic(logic, 2);
            });

            it(@"cart should recommend products by cartItems", ^{
                EMSCartItem *cartItem1 = [[EMSCartItem alloc] initWithItemId:@"cartItemId1"
                                                                       price:123
                                                                    quantity:1];
                EMSCartItem *cartItem2 = [[EMSCartItem alloc] initWithItemId:@"cartItemId2"
                                                                       price:456
                                                                    quantity:2];

                [Emarsys.predict trackCartWithCartItems:@[cartItem1, cartItem2]];
                assertWithLogic(EMSLogic.cart, 2);
            });

            it(@"related should recommend products by viewItemId with viewItemId", ^{
                [Emarsys.predict trackItemViewWithItemId:@"2200"];

                assertWithLogic(EMSLogic.related, 2);
            });

            it(@"related should recommend products by viewItemId", ^{
                EMSLogic *logic = [EMSLogic relatedWithViewItemId:@"2200"];

                assertWithLogic(logic, 2);
            });

            it(@"category should recommend products by categoryPath with categoryPath", ^{
                EMSLogic *logic = [EMSLogic categoryWithCategoryPath: categoryPath];

                assertWithLogic(logic, 2);
            });

            it(@"personal should recommend products", ^{
                EMSLogic *logic = [EMSLogic personal];

                assertWithLogic(logic, 2);
            });

            it(@"personal should recommend products", ^{
                EMSLogic *logic = [EMSLogic personalWithVariants:@[@"1", @"2", @"3"]];

                assertWithLogic(logic, 6);
            });

            it(@"home should recommend products", ^{
                EMSLogic *logic = [EMSLogic home];

                assertWithLogic(logic, 2);
            });

            it(@"home should recommend products", ^{
                EMSLogic *logic = [EMSLogic homeWithVariants:@[@"1", @"2", @"3"]];

                assertWithLogic(logic, 6);
            });

            it(@"category should recommend products by categoryPath", ^{
                [Emarsys.predict trackCategoryViewWithCategoryPath: categoryPath];

                assertWithLogic(EMSLogic.category, 2);
            });

            it(@"also bought should recommend products by viewItemId with viewItemId", ^{
                EMSLogic *logic = [EMSLogic alsoBoughtWithViewItemId:@"2200"];

                assertWithLogic(logic, 2);
            });

            it(@"also bought should recommend products by viewItemId", ^{
                [Emarsys.predict trackItemViewWithItemId:@"2200"];

                assertWithLogic(EMSLogic.alsoBought, 2);
            });

            it(@"popular should recommend products by categoryPath with categoryPath", ^{
                EMSLogic *logic = [EMSLogic popularWithCategoryPath: categoryPath];

                assertWithLogic(logic, 2);
            });

            it(@"popular should recommend products by categoryPath", ^{
                [Emarsys.predict trackCategoryViewWithCategoryPath: categoryPath];

                assertWithLogic(EMSLogic.popular, 2);
            });
        });

SPEC_END
