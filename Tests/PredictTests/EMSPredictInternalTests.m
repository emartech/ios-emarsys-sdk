//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSPredictInternal.h"
#import "PRERequestContext.h"
#import "EMSRequestManager.h"
#import "EMSShard.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSCartItem.h"
#import "EMSDeviceInfo.h"
#import "EMSResponseModel.h"
#import "EMSProduct.h"
#import "EMSProduct+Emarsys.h"
#import "NSError+EMSCore.h"
#import "EMSPredictRequestModelBuilderProvider.h"
#import "EMSPredictRequestModelBuilder.h"
#import "EMSProductMapper.h"
#import "EMSLogic.h"
#import "EMSRecommendationFilter.h"

SPEC_BEGIN(EMSPredictInternalTests)

        describe(@"init", ^{
            it(@"should throw exception when requestManager is nil", ^{
                @try {
                    [[EMSPredictInternal alloc] initWithRequestContext:[PRERequestContext mock]
                                                        requestManager:nil
                                                requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                         productMapper:[EMSProductMapper mock]];
                    fail(@"Expected Exception when requestManager is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestManager"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when requestContext is nil", ^{
                @try {
                    [[EMSPredictInternal alloc] initWithRequestContext:nil
                                                        requestManager:[EMSRequestManager mock]
                                                requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                         productMapper:[EMSProductMapper mock]];
                    fail(@"Expected Exception when requestContext is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestContext"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when requestBuilderProvider is nil", ^{
                @try {
                    [[EMSPredictInternal alloc] initWithRequestContext:[PRERequestContext mock]
                                                        requestManager:[EMSRequestManager mock]
                                                requestBuilderProvider:nil
                                                         productMapper:[EMSProductMapper mock]];
                    fail(@"Expected Exception when requestBuilderProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestBuilderProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when productMapper is nil", ^{
                @try {
                    [[EMSPredictInternal alloc] initWithRequestContext:[PRERequestContext mock]
                                                        requestManager:[EMSRequestManager mock]
                                                requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                         productMapper:nil];
                    fail(@"Expected Exception when productMapper is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: productMapper"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"setContactWithContactFieldValue:", ^{

            it(@"should throw exception when contactFieldValue is nil", ^{
                @try {
                    [[EMSPredictInternal new] setContactWithContactFieldValue:nil];
                    fail(@"Expected Exception when contactFieldValue is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: contactFieldValue"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should set the customerId in RequestContext", ^{
                PRERequestContext *requestContextMock = [PRERequestContext mock];
                EMSRequestManager *requestManagerMock = [EMSRequestManager mock];
                NSString *const customerId = @"customerID";
                EMSPredictInternal *internal = [[EMSPredictInternal alloc] initWithRequestContext:requestContextMock
                                                                                   requestManager:requestManagerMock
                                                                           requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                                                    productMapper:[EMSProductMapper mock]];

                [[requestContextMock should] receive:@selector(setCustomerId:) withArguments:customerId];
                [internal setContactWithContactFieldValue:customerId];
            });

        });

        describe(@"trackCategoryViewWithCategoryPath:", ^{

            it(@"should throw exception when categoryPath is nil", ^{
                @try {
                    [[EMSPredictInternal new] trackCategoryViewWithCategoryPath:nil];
                    fail(@"Expected Exception when categoryPath is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: categoryPath"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit a shard to requestManager", ^{
                NSString *itemId = @"idOfTheItem";
                NSDate *timestamp = [NSDate date];

                NSString *categoryPath = @"categoryPath";

                EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
                EMSUUIDProvider *uuidProvider = [EMSUUIDProvider mock];
                [[uuidProvider should] receive:@selector(provideUUIDString)
                                     andReturn:itemId
                                     withCount:2];
                [[timestampProvider should] receive:@selector(provideTimestamp)
                                          andReturn:timestamp
                                          withCount:2];

                EMSShard *expectedShard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                        [builder setType:@"predict_item_category_view"];
                        [builder addPayloadEntryWithKey:@"vc"
                                                  value:categoryPath];
                    }
                                                  timestampProvider:timestampProvider
                                                       uuidProvider:uuidProvider];

                EMSRequestManager *requestManager = [EMSRequestManager mock];
                [[requestManager should] receive:@selector(submitShard:)
                                   withArguments:expectedShard];

                PRERequestContext *requestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                                            uuidProvider:uuidProvider
                                                                                              merchantId:@"merchantId"
                                                                                              deviceInfo:[EMSDeviceInfo new]];
                EMSPredictInternal *internal = [[EMSPredictInternal alloc] initWithRequestContext:requestContext
                                                                                   requestManager:requestManager
                                                                           requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                                                    productMapper:[EMSProductMapper mock]];
                [internal trackCategoryViewWithCategoryPath:categoryPath];
            });

        });

        describe(@"trackItemViewWithItemId:", ^{

            it(@"should throw exception when itemId is nil", ^{
                @try {
                    [[EMSPredictInternal new] trackItemViewWithItemId:nil];
                    fail(@"Expected Exception when itemId is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: itemId"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit shard to requestManager", ^{
                NSString *itemId = @"idOfTheItem";
                NSDate *timestamp = [NSDate date];

                EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
                EMSUUIDProvider *uuidProvider = [EMSUUIDProvider mock];
                [[uuidProvider should] receive:@selector(provideUUIDString)
                                     andReturn:itemId
                                     withCount:2];
                [[timestampProvider should] receive:@selector(provideTimestamp)
                                          andReturn:timestamp
                                          withCount:2];

                EMSShard *expectedShard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                        [builder setType:@"predict_item_view"];
                        [builder addPayloadEntryWithKey:@"v"
                                                  value:[NSString stringWithFormat:@"i:%@", itemId]];
                    }
                                                  timestampProvider:timestampProvider
                                                       uuidProvider:uuidProvider];

                EMSRequestManager *requestManager = [EMSRequestManager mock];
                [[requestManager should] receive:@selector(submitShard:)
                                   withArguments:expectedShard];

                PRERequestContext *requestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                                            uuidProvider:uuidProvider
                                                                                              merchantId:@"merchantId"
                                                                                              deviceInfo:[EMSDeviceInfo new]];
                EMSPredictInternal *internal = [[EMSPredictInternal alloc] initWithRequestContext:requestContext
                                                                                   requestManager:requestManager
                                                                           requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                                                    productMapper:[EMSProductMapper mock]];
                [internal trackItemViewWithItemId:itemId];
            });

        });

        describe(@"trackRecommendationClick:", ^{

            it(@"should throw exception when product is nil", ^{
                @try {
                    [[EMSPredictInternal new] trackRecommendationClick:nil];
                    fail(@"Expected Exception when product is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: product"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit shard to requestManager", ^{
                EMSProduct *product = [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
                    [builder setRequiredFieldsWithProductId:@"testItemId"
                                                      title:@"testTitle"
                                                    linkUrl:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                                    feature:@"testFeature"
                                                     cohort:@"testCohort"];
                }];
                NSDate *timestamp = [NSDate date];

                EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
                EMSUUIDProvider *uuidProvider = [EMSUUIDProvider mock];
                [[uuidProvider should] receive:@selector(provideUUIDString)
                                     andReturn:product.productId
                                     withCount:2];
                [[timestampProvider should] receive:@selector(provideTimestamp)
                                          andReturn:timestamp
                                          withCount:2];

                EMSShard *expectedShard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                        [builder setType:@"predict_item_view"];
                        [builder addPayloadEntryWithKey:@"v"
                                                  value:[NSString stringWithFormat:@"i:%@,t:%@,c:%@",
                                                                                   product.productId,
                                                                                   product.feature,
                                                                                   product.cohort]];
                    }
                                                  timestampProvider:timestampProvider
                                                       uuidProvider:uuidProvider];

                EMSRequestManager *requestManager = [EMSRequestManager mock];
                [[requestManager should] receive:@selector(submitShard:)
                                   withArguments:expectedShard];

                PRERequestContext *requestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                                            uuidProvider:uuidProvider
                                                                                              merchantId:@"merchantId"
                                                                                              deviceInfo:[EMSDeviceInfo new]];
                EMSPredictInternal *internal = [[EMSPredictInternal alloc] initWithRequestContext:requestContext
                                                                                   requestManager:requestManager
                                                                           requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                                                    productMapper:[EMSProductMapper mock]];
                [internal trackRecommendationClick:product];
            });

        });

        describe(@"trackCartWithCartItems:", ^{

            it(@"should throw exception when cartItems is nil", ^{
                @try {
                    [[EMSPredictInternal new] trackCartWithCartItems:nil];
                    fail(@"Expected Exception when cartItems is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: cartItems"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit the correct shard for cart items", ^{
                NSDate *timestamp = [NSDate date];
                NSString *const shardId = @"shardId";

                EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
                [[timestampProvider should] receive:@selector(provideTimestamp) andReturn:timestamp];

                EMSUUIDProvider *shardIdProvider = [EMSUUIDProvider mock];
                [[shardIdProvider should] receive:@selector(provideUUIDString) andReturn:shardId];

                PRERequestContext *const requestContext = [PRERequestContext mock];
                [[requestContext should] receive:@selector(timestampProvider) andReturn:timestampProvider];
                [[requestContext should] receive:@selector(uuidProvider) andReturn:shardIdProvider];

                EMSShard *expectedShard = [[EMSShard alloc] initWithShardId:shardId
                                                                       type:@"predict_cart"
                                                                       data:@{@"cv": @"1", @"ca": @"i:itemId1,p:200.0,q:100.0|i:itemId2,p:201.0,q:101.0"}
                                                                  timestamp:timestamp
                                                                        ttl:FLT_MAX];

                EMSRequestManager *const requestManager = [EMSRequestManager mock];
                [[requestManager should] receive:@selector(submitShard:) withArguments:expectedShard];
                EMSPredictInternal *internal = [[EMSPredictInternal alloc] initWithRequestContext:requestContext
                                                                                   requestManager:requestManager
                                                                           requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                                                    productMapper:[EMSProductMapper mock]];

                [internal trackCartWithCartItems:@[
                    [EMSCartItem itemWithItemId:@"itemId1" price:200.0 quantity:100.0],
                    [EMSCartItem itemWithItemId:@"itemId2" price:201.0 quantity:101.0]
                ]];
            });

        });

        describe(@"trackSearchWithSearchTerm:", ^{

            it(@"should throw exception when searchTerm is nil", ^{
                @try {
                    [[EMSPredictInternal new] trackSearchWithSearchTerm:nil];
                    fail(@"Expected Exception when cartItems is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: searchTerm"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit shard to requestManager", ^{
                NSString *searchTerm = @"searchTerm";
                NSDate *timestamp = [NSDate date];

                EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
                EMSUUIDProvider *uuidProvider = [EMSUUIDProvider mock];
                [[uuidProvider should] receive:@selector(provideUUIDString)
                                     andReturn:searchTerm
                                     withCount:2];
                [[timestampProvider should] receive:@selector(provideTimestamp)
                                          andReturn:timestamp
                                          withCount:2];

                EMSShard *expectedShard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                        [builder setType:@"predict_search_term"];
                        [builder addPayloadEntryWithKey:@"q"
                                                  value:searchTerm];
                    }
                                                  timestampProvider:timestampProvider
                                                       uuidProvider:uuidProvider];

                EMSRequestManager *requestManager = [EMSRequestManager mock];
                [[requestManager should] receive:@selector(submitShard:)
                                   withArguments:expectedShard];

                PRERequestContext *requestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                                            uuidProvider:uuidProvider
                                                                                              merchantId:@"merchantId"
                                                                                              deviceInfo:[EMSDeviceInfo new]];
                EMSPredictInternal *internal = [[EMSPredictInternal alloc] initWithRequestContext:requestContext
                                                                                   requestManager:requestManager
                                                                           requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                                                    productMapper:[EMSProductMapper mock]];
                [internal trackSearchWithSearchTerm:searchTerm];
            });

        });

        describe(@"trackPurchaseWithOrderId:items:", ^{

            it(@"should throw exception when orderId is nil", ^{
                @try {
                    [[EMSPredictInternal new] trackPurchaseWithOrderId:nil items:@[]];
                    fail(@"Expected Exception when orderId is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: orderId"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when items is nil", ^{
                @try {
                    [[EMSPredictInternal new] trackPurchaseWithOrderId:@"orderId" items:nil];
                    fail(@"Expected Exception when items is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: items"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit the correct shard for purchase", ^{
                NSDate *timestamp = [NSDate date];
                NSString *const shardId = @"shardId";
                NSString *const orderId = @"orderId";

                EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
                [[timestampProvider should] receive:@selector(provideTimestamp) andReturn:timestamp];

                EMSUUIDProvider *shardIdProvider = [EMSUUIDProvider mock];
                [[shardIdProvider should] receive:@selector(provideUUIDString) andReturn:shardId];

                PRERequestContext *const requestContext = [PRERequestContext mock];
                [[requestContext should] receive:@selector(timestampProvider) andReturn:timestampProvider];
                [[requestContext should] receive:@selector(uuidProvider) andReturn:shardIdProvider];

                EMSShard *expectedShard = [[EMSShard alloc] initWithShardId:shardId
                                                                       type:@"predict_purchase"
                                                                       data:@{@"oi": orderId, @"co": @"i:itemId1,p:200.0,q:100.0|i:itemId2,p:201.0,q:101.0"}
                                                                  timestamp:timestamp
                                                                        ttl:FLT_MAX];

                EMSRequestManager *const requestManager = [EMSRequestManager mock];
                [[requestManager should] receive:@selector(submitShard:) withArguments:expectedShard];
                EMSPredictInternal *internal = [[EMSPredictInternal alloc] initWithRequestContext:requestContext
                                                                                   requestManager:requestManager
                                                                           requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                                                    productMapper:[EMSProductMapper mock]];


                [internal trackPurchaseWithOrderId:orderId items:@[
                    [EMSCartItem itemWithItemId:@"itemId1" price:200.0 quantity:100.0],
                    [EMSCartItem itemWithItemId:@"itemId2" price:201.0 quantity:101.0]
                ]];
            });

        });

        describe(@"clearContact", ^{
            it(@"should setCustomerId and visitorId to nil on requestContext", ^{
                PRERequestContext *const requestContext = [PRERequestContext mock];
                [[requestContext should] receive:@selector(setCustomerId:)
                                   withArguments:nil];
                [[requestContext should] receive:@selector(setVisitorId:)
                                   withArguments:nil];

                EMSRequestManager *const requestManager = [EMSRequestManager nullMock];

                EMSPredictInternal *internal = [[EMSPredictInternal alloc] initWithRequestContext:requestContext
                                                                                   requestManager:requestManager
                                                                           requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                                                    productMapper:[EMSProductMapper mock]];
                [internal clearContact];
            });
        });

        describe(@"recommendProductsWithLogic:productsBlock:", ^{

            __block EMSRequestManager *mockRequestManager;
            __block PRERequestContext *mockRequestContext;
            __block EMSPredictRequestModelBuilderProvider *mockBuilderProvider;
            __block EMSProductMapper *mockProductMapper;
            __block EMSPredictInternal *predictInternal;
            __block EMSPredictRequestModelBuilder *mockBuilder;

            beforeEach(^{
                mockRequestManager = [EMSRequestManager nullMock];
                mockRequestContext = [PRERequestContext nullMock];
                mockBuilderProvider = [EMSPredictRequestModelBuilderProvider nullMock];
                mockBuilder = [EMSPredictRequestModelBuilder nullMock];
                [mockBuilderProvider stub:@selector(provideBuilder) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastSearchTerm:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastCartItems:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastViewItemId:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastCategoryPath:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLimit:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withFilter:) andReturn:mockBuilder];

                mockProductMapper = [EMSProductMapper nullMock];
                [mockRequestContext stub:@selector(timestampProvider) andReturn:[EMSTimestampProvider new]];
                [mockRequestContext stub:@selector(uuidProvider) andReturn:[EMSUUIDProvider new]];
                [mockRequestContext stub:@selector(merchantId) andReturn:@"1428C8EE286EC34B"];

                predictInternal = [[EMSPredictInternal alloc] initWithRequestContext:mockRequestContext
                                                                      requestManager:mockRequestManager
                                                              requestBuilderProvider:mockBuilderProvider
                                                                       productMapper:mockProductMapper];
            });

            it(@"should throw exception productBlocks is nil", ^{
                @try {
                    [[EMSPredictInternal new] recommendProductsWithLogic:EMSLogic.search productsBlock:nil];
                    fail(@"Expected Exception when productBlocks is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: productsBlock"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception logic is nil", ^{
                @try {
                    [[EMSPredictInternal new] recommendProductsWithLogic:nil
                                                           productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
                                                           }];
                    fail(@"Expected Exception when logic is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: logic"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit a requestModel into requestManager with search logic", ^{
                EMSRequestModel *mockRequestModel = [EMSRequestModel mock];

                [[mockRequestManager should] receive:@selector(submitRequestModelNow:successBlock:errorBlock:)
                                       withArguments:mockRequestModel, kw_any(), kw_any()];
                [[mockBuilder should] receive:@selector(withLogic:)
                                    andReturn:mockBuilder
                                withArguments:[EMSLogic searchWithSearchTerm:@"polo shirt"]];
                [[mockBuilder should] receive:@selector(build)
                                    andReturn:mockRequestModel];
                [predictInternal recommendProductsWithLogic:[EMSLogic searchWithSearchTerm:@"polo shirt"]
                                              productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
                                              }];
            });

            it(@"should submit a requestModel into requestManager with cart logic", ^{
                EMSRequestModel *mockRequestModel = [EMSRequestModel mock];

                EMSCartItem *cartItem1 = [[EMSCartItem alloc] initWithItemId:@"cartItemId1"
                                                                       price:123
                                                                    quantity:1];
                EMSCartItem *cartItem2 = [[EMSCartItem alloc] initWithItemId:@"cartItemId2"
                                                                       price:456
                                                                    quantity:2];

                EMSLogic *logic = [EMSLogic cartWithCartItems:@[cartItem1, cartItem2]];

                [[mockRequestManager should] receive:@selector(submitRequestModelNow:successBlock:errorBlock:)
                                       withArguments:mockRequestModel, kw_any(), kw_any()];
                [[mockBuilder should] receive:@selector(withLogic:)
                                    andReturn:mockBuilder
                                withArguments:logic];
                [[mockBuilder should] receive:@selector(build)
                                    andReturn:mockRequestModel];
                [predictInternal recommendProductsWithLogic:logic
                                              productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
                                              }];
            });

            it(@"should submit a requestModel into requestManager with logic and last values", ^{
                EMSLogic *logic = [EMSLogic searchWithSearchTerm:@"polo shirt"];
                NSString *lastSearchTerm = @"lastSearchTerm";
                EMSCartItem *cartItem1 = [[EMSCartItem alloc] initWithItemId:@"cartItemId1"
                                                                       price:123
                                                                    quantity:1];
                EMSCartItem *cartItem2 = [[EMSCartItem alloc] initWithItemId:@"cartItemId2"
                                                                       price:456
                                                                    quantity:2];
                NSArray *lastCartItems = @[cartItem1, cartItem2];
                NSString *lastViewItemId = @"lastViewItemId";
                NSString *lastCategoryPath = @"lastCategoryPath";

                EMSRequestModel *mockRequestModel = [EMSRequestModel mock];

                [[mockRequestManager should] receive:@selector(submitRequestModelNow:successBlock:errorBlock:)
                                       withArguments:mockRequestModel, kw_any(), kw_any()];
                [[mockBuilder should] receive:@selector(withLogic:)
                                    andReturn:mockBuilder
                                withArguments:logic];
                [[mockBuilder should] receive:@selector(withLastSearchTerm:)
                                    andReturn:mockBuilder
                                withArguments:lastSearchTerm];
                [[mockBuilder should] receive:@selector(withLastCartItems:)
                                    andReturn:mockBuilder
                                withArguments:lastCartItems];
                [[mockBuilder should] receive:@selector(withLastViewItemId:)
                                    andReturn:mockBuilder
                                withArguments:lastViewItemId];
                [[mockBuilder should] receive:@selector(withLastCategoryPath:)
                                    andReturn:mockBuilder
                                withArguments:lastCategoryPath];
                [[mockBuilder should] receive:@selector(build)
                                    andReturn:mockRequestModel];

                [predictInternal trackSearchWithSearchTerm:lastSearchTerm];
                [predictInternal trackCartWithCartItems:lastCartItems];
                [predictInternal trackItemViewWithItemId:lastViewItemId];
                [predictInternal trackCategoryViewWithCategoryPath:lastCategoryPath];
                [predictInternal recommendProductsWithLogic:logic
                                              productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
                                              }];
            });

            it(@"should submit a requestModel into requestManager with logic and last values with product", ^{
                EMSLogic *logic = [EMSLogic searchWithSearchTerm:@"polo shirt"];
                NSString *lastSearchTerm = @"lastSearchTerm";
                EMSCartItem *cartItem1 = [[EMSCartItem alloc] initWithItemId:@"cartItemId1"
                                                                       price:123
                                                                    quantity:1];
                EMSCartItem *cartItem2 = [[EMSCartItem alloc] initWithItemId:@"cartItemId2"
                                                                       price:456
                                                                    quantity:2];
                NSArray *lastCartItems = @[cartItem1, cartItem2];
                NSString *lastViewItemId = @"lastViewItemId";
                NSString *lastCategoryPath = @"lastCategoryPath";

                EMSRequestModel *mockRequestModel = [EMSRequestModel mock];

                [[mockRequestManager should] receive:@selector(submitRequestModelNow:successBlock:errorBlock:)
                                       withArguments:mockRequestModel, kw_any(), kw_any()];
                [[mockBuilder should] receive:@selector(withLogic:)
                                    andReturn:mockBuilder
                                withArguments:logic];
                [[mockBuilder should] receive:@selector(withLastSearchTerm:)
                                    andReturn:mockBuilder
                                withArguments:lastSearchTerm];
                [[mockBuilder should] receive:@selector(withLastCartItems:)
                                    andReturn:mockBuilder
                                withArguments:lastCartItems];
                [[mockBuilder should] receive:@selector(withLastViewItemId:)
                                    andReturn:mockBuilder
                                withArguments:lastViewItemId];
                [[mockBuilder should] receive:@selector(withLastCategoryPath:)
                                    andReturn:mockBuilder
                                withArguments:lastCategoryPath];
                [[mockBuilder should] receive:@selector(build)
                                    andReturn:mockRequestModel];

                [predictInternal trackSearchWithSearchTerm:lastSearchTerm];
                [predictInternal trackCartWithCartItems:lastCartItems];
                [predictInternal trackRecommendationClick:[EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
                    [builder setRequiredFieldsWithProductId:@"lastViewItemId"
                                                      title:@"testTitle"
                                                    linkUrl:[NSURL URLWithString:@"https://www.emarsys.com"]
                                                    feature:@"testFeature"
                                                     cohort:@"testCohort"];
                }]];
                [predictInternal trackCategoryViewWithCategoryPath:lastCategoryPath];
                [predictInternal recommendProductsWithLogic:logic
                                              productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
                                              }];
            });

            it(@"should receive products", ^{
                EMSProduct *expectedProduct = [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
                    [builder setRequiredFieldsWithProductId:@"2120"
                                                      title:@"LSL Men Polo Shirt LE16"
                                                    linkUrl:[[NSURL alloc] initWithString:@"http://lifestylelabels.com/lsl-men-polo-shirt-le16.html"]
                                                    feature:@"RELATED"
                                                     cohort:@"testCohort"];
                }];
                __block NSThread *returnedThread = nil;
                __block NSArray<EMSProduct *> *returnedProducts = nil;
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResponse"];

                [[mockProductMapper should] receive:@selector(mapFromResponse:)
                                          andReturn:@[expectedProduct]];

                [[NSOperationQueue new] addOperationWithBlock:^{
                    KWCaptureSpy *spy = [mockRequestManager captureArgument:@selector(submitRequestModelNow:successBlock:errorBlock:)
                                                                    atIndex:1];


                    [predictInternal recommendProductsWithLogic:EMSLogic.search
                                                  productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
                                                      returnedProducts = products;
                                                      returnedThread = [NSThread currentThread];
                                                      [expectation fulfill];
                                                  }];

                    CoreSuccessBlock successBlock = spy.argument;

                    successBlock(@"testRequestId", [EMSResponseModel nullMock]);
                }];
                XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                      timeout:5.0];
                [[theValue(waiterResult) should] equal:theValue(XCTWaiterResultCompleted)];
                [[returnedProducts should] equal:@[expectedProduct]];
                [[returnedThread should] equal:NSThread.mainThread];
            });

            it(@"should receive error", ^{
                __block NSError *returnedError = nil;
                __block NSThread *returnedThread = nil;
                NSError *expectedError = [NSError errorWithCode:400
                                           localizedDescription:@"Test Error"];
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForError"];

                [[NSOperationQueue new] addOperationWithBlock:^{
                    KWCaptureSpy *spy = [mockRequestManager captureArgument:@selector(submitRequestModelNow:successBlock:errorBlock:)
                                                                    atIndex:2];


                    [predictInternal recommendProductsWithLogic:EMSLogic.search
                                                  productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
                                                      returnedError = error;
                                                      returnedThread = [NSThread currentThread];
                                                      [expectation fulfill];
                                                  }];

                    CoreErrorBlock errorBlock = spy.argument;

                    errorBlock(@"testRequestId", expectedError);
                }];
                XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                      timeout:5.0];
                [[theValue(waiterResult) should] equal:theValue(XCTWaiterResultCompleted)];
                [[expectedError should] equal:returnedError];
                [[returnedThread should] equal:NSThread.mainThread];
            });
        });

        describe(@"recommendProductsWithLogic:limit:productsBlock:", ^{

            __block EMSRequestManager *mockRequestManager;
            __block PRERequestContext *mockRequestContext;
            __block EMSPredictRequestModelBuilderProvider *mockBuilderProvider;
            __block EMSProductMapper *mockProductMapper;
            __block EMSPredictInternal *predictInternal;
            __block EMSPredictRequestModelBuilder *mockBuilder;

            beforeEach(^{
                mockRequestManager = [EMSRequestManager nullMock];
                mockRequestContext = [PRERequestContext nullMock];
                mockBuilderProvider = [EMSPredictRequestModelBuilderProvider nullMock];
                mockBuilder = [EMSPredictRequestModelBuilder nullMock];
                [mockBuilderProvider stub:@selector(provideBuilder) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastSearchTerm:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastCartItems:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastViewItemId:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastCategoryPath:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLimit:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLogic:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withFilter:) andReturn:mockBuilder];

                mockProductMapper = [EMSProductMapper nullMock];
                [mockRequestContext stub:@selector(timestampProvider) andReturn:[EMSTimestampProvider new]];
                [mockRequestContext stub:@selector(uuidProvider) andReturn:[EMSUUIDProvider new]];
                [mockRequestContext stub:@selector(merchantId) andReturn:@"1428C8EE286EC34B"];

                predictInternal = [[EMSPredictInternal alloc] initWithRequestContext:mockRequestContext
                                                                      requestManager:mockRequestManager
                                                              requestBuilderProvider:mockBuilderProvider
                                                                       productMapper:mockProductMapper];
            });

            it(@"should pass limit to requestModelBuilder", ^{
                [[mockBuilder should] receive:@selector(withLimit:)
                                    andReturn:mockBuilder
                                withArguments:@123];

                [predictInternal recommendProductsWithLogic:EMSLogic.search
                                                      limit:@123
                                              productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
                                              }];
            });
        });

        describe(@"recommendProductsWithLogic:filters:productsBlock:", ^{

            __block EMSRequestManager *mockRequestManager;
            __block PRERequestContext *mockRequestContext;
            __block EMSPredictRequestModelBuilderProvider *mockBuilderProvider;
            __block EMSProductMapper *mockProductMapper;
            __block EMSPredictInternal *predictInternal;
            __block EMSPredictRequestModelBuilder *mockBuilder;

            beforeEach(^{
                mockRequestManager = [EMSRequestManager nullMock];
                mockRequestContext = [PRERequestContext nullMock];
                mockBuilderProvider = [EMSPredictRequestModelBuilderProvider nullMock];
                mockBuilder = [EMSPredictRequestModelBuilder nullMock];
                [mockBuilderProvider stub:@selector(provideBuilder) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastSearchTerm:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastCartItems:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastViewItemId:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastCategoryPath:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLimit:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLogic:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withFilter:) andReturn:mockBuilder];

                mockProductMapper = [EMSProductMapper nullMock];
                [mockRequestContext stub:@selector(timestampProvider) andReturn:[EMSTimestampProvider new]];
                [mockRequestContext stub:@selector(uuidProvider) andReturn:[EMSUUIDProvider new]];
                [mockRequestContext stub:@selector(merchantId) andReturn:@"1428C8EE286EC34B"];

                predictInternal = [[EMSPredictInternal alloc] initWithRequestContext:mockRequestContext
                                                                      requestManager:mockRequestManager
                                                              requestBuilderProvider:mockBuilderProvider
                                                                       productMapper:mockProductMapper];
            });

            it(@"should pass filter to requestModelBuilder", ^{
                NSArray<id <EMSRecommendationFilterProtocol>> *filters = @[
                    [EMSRecommendationFilter excludeFilterWithField:@"testField"
                                                            isValue:@"testFieldValue"],
                    [EMSRecommendationFilter excludeFilterWithField:@"testField2"
                                                           hasValue:@"testFieldValue2"]];

                [[mockBuilder should] receive:@selector(withFilter:)
                                    andReturn:mockBuilder
                                withArguments:filters];

                [predictInternal recommendProductsWithLogic:EMSLogic.search
                                                    filters:filters
                                              productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
                                              }];
            });
        });

        describe(@"recommendProductsWithLogic:filters:limit:productsBlock:", ^{

            __block EMSRequestManager *mockRequestManager;
            __block PRERequestContext *mockRequestContext;
            __block EMSPredictRequestModelBuilderProvider *mockBuilderProvider;
            __block EMSProductMapper *mockProductMapper;
            __block EMSPredictInternal *predictInternal;
            __block EMSPredictRequestModelBuilder *mockBuilder;

            beforeEach(^{
                mockRequestManager = [EMSRequestManager nullMock];
                mockRequestContext = [PRERequestContext nullMock];
                mockBuilderProvider = [EMSPredictRequestModelBuilderProvider nullMock];
                mockBuilder = [EMSPredictRequestModelBuilder nullMock];
                [mockBuilderProvider stub:@selector(provideBuilder) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastSearchTerm:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastCartItems:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastViewItemId:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLastCategoryPath:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLimit:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withLogic:) andReturn:mockBuilder];
                [mockBuilder stub:@selector(withFilter:) andReturn:mockBuilder];

                mockProductMapper = [EMSProductMapper nullMock];
                [mockRequestContext stub:@selector(timestampProvider) andReturn:[EMSTimestampProvider new]];
                [mockRequestContext stub:@selector(uuidProvider) andReturn:[EMSUUIDProvider new]];
                [mockRequestContext stub:@selector(merchantId) andReturn:@"1428C8EE286EC34B"];

                predictInternal = [[EMSPredictInternal alloc] initWithRequestContext:mockRequestContext
                                                                      requestManager:mockRequestManager
                                                              requestBuilderProvider:mockBuilderProvider
                                                                       productMapper:mockProductMapper];
            });

            it(@"should pass filter to requestModelBuilder", ^{
                NSArray<id <EMSRecommendationFilterProtocol>> *filters = @[
                    [EMSRecommendationFilter excludeFilterWithField:@"testField"
                                                            isValue:@"testFieldValue"],
                    [EMSRecommendationFilter excludeFilterWithField:@"testField2"
                                                           hasValue:@"testFieldValue2"]];

                [[mockBuilder should] receive:@selector(withFilter:)
                                    andReturn:mockBuilder
                                withArguments:filters];
                [[mockBuilder should] receive:@selector(withLimit:)
                                    andReturn:mockBuilder
                                withArguments:@123];

                [predictInternal recommendProductsWithLogic:EMSLogic.search
                                                    filters:filters
                                                      limit:@123
                                              productsBlock:^(NSArray<EMSProduct *> *products, NSError *error) {
                                              }];
            });
        });

        describe(@"trackTag:withAttributes:", ^{

            it(@"should throw exception when tag is nil", ^{
                @try {
                    [[EMSPredictInternal new] trackTag:nil withAttributes:@{}];
                    fail(@"Expected Exception when tag is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: tag"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit shard to requestManager when attributes is nil", ^{
                NSString *tag = @"testTag";
                NSDate *timestamp = [NSDate date];

                EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
                EMSUUIDProvider *uuidProvider = [EMSUUIDProvider mock];
                [[uuidProvider should] receive:@selector(provideUUIDString)
                                     andReturn:@"uuid"
                                     withCount:2];
                [[timestampProvider should] receive:@selector(provideTimestamp)
                                          andReturn:timestamp
                                          withCount:2];

                EMSShard *expectedShard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                        [builder setType:@"predict_tag"];
                        [builder addPayloadEntryWithKey:@"t"
                                                  value:tag];
                    }
                                                  timestampProvider:timestampProvider
                                                       uuidProvider:uuidProvider];

                EMSRequestManager *requestManager = [EMSRequestManager mock];
                [[requestManager should] receive:@selector(submitShard:)
                                   withArguments:expectedShard];

                PRERequestContext *requestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                                            uuidProvider:uuidProvider
                                                                                              merchantId:@"merchantId"
                                                                                              deviceInfo:[EMSDeviceInfo new]];
                EMSPredictInternal *internal = [[EMSPredictInternal alloc] initWithRequestContext:requestContext
                                                                                   requestManager:requestManager
                                                                           requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                                                    productMapper:[EMSProductMapper mock]];
                [internal trackTag:tag withAttributes:nil];
            });

            it(@"should submit shard to requestManager with attributes", ^{
                NSString *tag = @"testTag";
                NSDictionary *attributes = @{
                    @"att1": @"value1",
                    @"att2": @"value2",
                    @"att3": @"value3"};
                NSDate *timestamp = [NSDate date];

                EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
                EMSUUIDProvider *uuidProvider = [EMSUUIDProvider mock];
                [[uuidProvider should] receive:@selector(provideUUIDString)
                                     andReturn:@"uuid"
                                     withCount:2];
                [[timestampProvider should] receive:@selector(provideTimestamp)
                                          andReturn:timestamp
                                          withCount:2];


                NSData *serializedData = [NSJSONSerialization dataWithJSONObject:@{@"name": tag, @"attributes": attributes}
                                                                         options:0
                                                                           error:nil];
                NSString *expectedPayload = [[NSString alloc] initWithData:serializedData
                                                                  encoding:NSUTF8StringEncoding];

                EMSShard *expectedShard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                        [builder setType:@"predict_tag"];
                        [builder addPayloadEntryWithKey:@"ta"
                                                  value:expectedPayload];
                    }
                                                  timestampProvider:timestampProvider
                                                       uuidProvider:uuidProvider];

                EMSRequestManager *requestManager = [EMSRequestManager mock];
                [[requestManager should] receive:@selector(submitShard:)
                                   withArguments:expectedShard];

                PRERequestContext *requestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                                            uuidProvider:uuidProvider
                                                                                              merchantId:@"merchantId"
                                                                                              deviceInfo:[EMSDeviceInfo new]];
                EMSPredictInternal *internal = [[EMSPredictInternal alloc] initWithRequestContext:requestContext
                                                                                   requestManager:requestManager
                                                                           requestBuilderProvider:[EMSPredictRequestModelBuilderProvider mock]
                                                                                    productMapper:[EMSProductMapper mock]];
                [internal trackTag:tag withAttributes:attributes];
            });

        });
SPEC_END
