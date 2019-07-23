//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "PredictInternal.h"
#import "PRERequestContext.h"
#import "EMSRequestManager.h"
#import "EMSShard.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSCartItem.h"
#import "EMSDeviceInfo.h"

SPEC_BEGIN(PredictInternalTests)

        describe(@"setContactWithContactFieldValue:", ^{

            it(@"should throw exception when contactFieldValue is nil", ^{
                @try {
                    [[PredictInternal new] setContactWithContactFieldValue:nil];
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
                PredictInternal *internal = [[PredictInternal alloc] initWithRequestContext:requestContextMock
                                                                             requestManager:requestManagerMock];

                [[requestContextMock should] receive:@selector(setCustomerId:) withArguments:customerId];
                [internal setContactWithContactFieldValue:customerId];
            });

        });

        describe(@"trackCategoryViewWithCategoryPath:", ^{

            it(@"should throw exception when categoryPath is nil", ^{
                @try {
                    [[PredictInternal new] trackCategoryViewWithCategoryPath:nil];
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
                PredictInternal *internal = [[PredictInternal alloc] initWithRequestContext:requestContext
                                                                             requestManager:requestManager];
                [internal trackCategoryViewWithCategoryPath:categoryPath];
            });

        });

        describe(@"trackItemViewWithItemId:", ^{

            it(@"should throw exception when itemId is nil", ^{
                @try {
                    [[PredictInternal new] trackItemViewWithItemId:nil];
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
                PredictInternal *internal = [[PredictInternal alloc] initWithRequestContext:requestContext
                                                                             requestManager:requestManager];
                [internal trackItemViewWithItemId:itemId];
            });

        });

        describe(@"trackCartWithCartItems:", ^{

            it(@"should throw exception when cartItems is nil", ^{
                @try {
                    [[PredictInternal new] trackCartWithCartItems:nil];
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
                PredictInternal *internal = [[PredictInternal alloc] initWithRequestContext:requestContext
                                                                             requestManager:requestManager];


                [internal trackCartWithCartItems:@[
                        [EMSCartItem itemWithItemId:@"itemId1" price:200.0 quantity:100.0],
                        [EMSCartItem itemWithItemId:@"itemId2" price:201.0 quantity:101.0]
                ]];
            });

        });

        describe(@"trackSearchWithSearchTerm:", ^{

            it(@"should throw exception when searchTerm is nil", ^{
                @try {
                    [[PredictInternal new] trackSearchWithSearchTerm:nil];
                    fail(@"Expected Exception when searchTerm is nil!");
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
                PredictInternal *internal = [[PredictInternal alloc] initWithRequestContext:requestContext
                                                                             requestManager:requestManager];
                [internal trackSearchWithSearchTerm:searchTerm];
            });

        });

        describe(@"trackPurchaseWithOrderId:items:", ^{

            it(@"should throw exception when orderId is nil", ^{
                @try {
                    [[PredictInternal new] trackPurchaseWithOrderId:nil items:@[]];
                    fail(@"Expected Exception when orderId is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: orderId"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when items is nil", ^{
                @try {
                    [[PredictInternal new] trackPurchaseWithOrderId:@"orderId" items:nil];
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
                PredictInternal *internal = [[PredictInternal alloc] initWithRequestContext:requestContext
                                                                             requestManager:requestManager];


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

                PredictInternal *internal = [[PredictInternal alloc] initWithRequestContext:requestContext
                                                                             requestManager:requestManager];
                [internal clearContact];
            });
        });

        describe(@"recommendProducts:", ^{

            it(@"should throw exception productBlocks is nil", ^{
                @try {
                    [[PredictInternal new] recommendProducts:nil];
                    fail(@"Expected Exception when productBlocks is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: productsBlock"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });
SPEC_END
