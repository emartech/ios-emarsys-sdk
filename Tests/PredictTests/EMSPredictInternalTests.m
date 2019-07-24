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
#import "NSError+EMSCore.h"

SPEC_BEGIN(EMSPredictInternalTests)

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
                                                                                   requestManager:requestManagerMock];

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
                                                                                   requestManager:requestManager];
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
                                                                                   requestManager:requestManager];
                [internal trackItemViewWithItemId:itemId];
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
                                                                                   requestManager:requestManager];
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

                EMSPredictInternal *internal = [[EMSPredictInternal alloc] initWithRequestContext:requestContext
                                                                                   requestManager:requestManager];
                [internal clearContact];
            });
        });

        describe(@"recommendProducts:", ^{

            __block EMSRequestManager *mockRequestManager;
            __block PRERequestContext *mockRequestContext;
            __block EMSPredictInternal *predictInternal;

            beforeEach(^{
                mockRequestManager = [EMSRequestManager nullMock];
                mockRequestContext = [PRERequestContext nullMock];
                [mockRequestContext stub:@selector(timestampProvider) andReturn:[EMSTimestampProvider new]];
                [mockRequestContext stub:@selector(uuidProvider) andReturn:[EMSUUIDProvider new]];
                [mockRequestContext stub:@selector(merchantId) andReturn:@"1428C8EE286EC34B"];

                predictInternal = [[EMSPredictInternal alloc] initWithRequestContext:mockRequestContext
                                                                      requestManager:mockRequestManager];
            });

            void (^assertProducts)(NSString *rawResponse, NSArray<EMSProduct *> *expectedProducts) = ^(NSString *rawResponse, NSArray<EMSProduct *> *expectedProducts) {
                XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForProducts"];
                __block NSArray<EMSProduct *> *returnedProducts = nil;
                __block NSThread *returnedThread;

                [[NSOperationQueue new] addOperationWithBlock:^{
                    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                                           headers:@{}
                                                                                              body:[rawResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                                      requestModel:[EMSRequestModel nullMock]
                                                                                         timestamp:[NSDate date]];
                    KWCaptureSpy *spy = [mockRequestManager captureArgument:@selector(submitRequestModelNow:successBlock:errorBlock:)
                                                                    atIndex:1];
                    [predictInternal recommendProducts:^(NSArray<EMSProduct *> *products, NSError *error) {
                        returnedProducts = products;
                        returnedThread = [NSThread currentThread];
                        [expectation fulfill];
                    }];
                    CoreSuccessBlock successBlock = spy.argument;
                    successBlock(@"testRequestId", responseModel);
                }];
                XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                                      timeout:5.0];

                [[theValue(waiterResult) should] equal:theValue(XCTWaiterResultCompleted)];
                [[returnedProducts should] equal:expectedProducts];
                [[returnedThread should] equal:NSThread.mainThread];
            };

            it(@"should throw exception productBlocks is nil", ^{
                @try {
                    [[EMSPredictInternal new] recommendProducts:nil];
                    fail(@"Expected Exception when productBlocks is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: productsBlock"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit a requestModel into requestManager", ^{
                [[mockRequestManager should] receive:@selector(submitRequestModelNow:successBlock:errorBlock:)
                                       withArguments:kw_any(), kw_any(), kw_any()];


                KWCaptureSpy *spy = [mockRequestManager captureArgument:@selector(submitRequestModelNow:successBlock:errorBlock:)
                                                                atIndex:0];

                [predictInternal recommendProducts:^(NSArray<EMSProduct *> *products, NSError *error) {
                }];

                EMSRequestModel *capturedModel = spy.argument;

                [[capturedModel.url.absoluteString should] equal:@"https://recommender.scarabresearch.com/merchants/1428C8EE286EC34B/?f=f:SEARCH,l:2,o:0&q=polo%20shirt"];
                [[capturedModel.method should] equal:@"GET"];
            });

            it(@"should receive products", ^{
                NSString *rawResponse = @"{\n"
                                        "  \"cohort\": \"AAAA\",\n"
                                        "  \"visitor\": \"11730071F07F469F\",\n"
                                        "  \"session\": \"28ACE5FD314FCC1A\",\n"
                                        "  \"features\": {\n"
                                        "    \"SEARCH\": {\n"
                                        "      \"hasMore\": true,\n"
                                        "      \"merchants\": [\n"
                                        "        \"1428C8EE286EC34B\"\n"
                                        "      ],\n"
                                        "      \"items\": [\n"
                                        "        {\n"
                                        "          \"id\": \"2119\",\n"
                                        "          \"spans\": [\n"
                                        "            [\n"
                                        "              [\n"
                                        "                8,\n"
                                        "                12\n"
                                        "              ],\n"
                                        "              [\n"
                                        "                13,\n"
                                        "                18\n"
                                        "              ]\n"
                                        "            ],\n"
                                        "            [\n"
                                        "              [\n"
                                        "                4,\n"
                                        "                9\n"
                                        "              ]\n"
                                        "            ]\n"
                                        "          ]\n"
                                        "        },\n"
                                        "        {\n"
                                        "          \"id\": \"2120\",\n"
                                        "          \"spans\": [\n"
                                        "            [\n"
                                        "              [\n"
                                        "                8,\n"
                                        "                12\n"
                                        "              ],\n"
                                        "              [\n"
                                        "                13,\n"
                                        "                18\n"
                                        "              ]\n"
                                        "            ],\n"
                                        "            [\n"
                                        "              [\n"
                                        "                4,\n"
                                        "                9\n"
                                        "              ]\n"
                                        "            ]\n"
                                        "          ]\n"
                                        "        }\n"
                                        "      ]\n"
                                        "    }\n"
                                        "  },\n"
                                        "  \"products\": {\n"
                                        "    \"2119\": {\n"
                                        "      \"item\": \"2119\",\n"
                                        "      \"category\": \"MEN>Shirts\",\n"
                                        "      \"title\": \"LSL Men Polo Shirt SE16\",\n"
                                        "      \"available\": true,\n"
                                        "      \"msrp\": 100,\n"
                                        "      \"price\": 100,\n"
                                        "      \"msrp_gpb\": \"83.2\",\n"
                                        "      \"price_gpb\": \"83.2\",\n"
                                        "      \"msrp_aed\": \"100\",\n"
                                        "      \"price_aed\": \"100\",\n"
                                        "      \"msrp_cad\": \"100\",\n"
                                        "      \"price_cad\": \"100\",\n"
                                        "      \"msrp_mxn\": \"2057.44\",\n"
                                        "      \"price_mxn\": \"2057.44\",\n"
                                        "      \"msrp_pln\": \"100\",\n"
                                        "      \"price_pln\": \"100\",\n"
                                        "      \"msrp_rub\": \"100\",\n"
                                        "      \"price_rub\": \"100\",\n"
                                        "      \"msrp_sek\": \"100\",\n"
                                        "      \"price_sek\": \"100\",\n"
                                        "      \"msrp_try\": \"339.95\",\n"
                                        "      \"price_try\": \"339.95\",\n"
                                        "      \"msrp_usd\": \"100\",\n"
                                        "      \"price_usd\": \"100\",\n"
                                        "      \"link\": \"http://lifestylelabels.com/lsl-men-polo-shirt-se16.html\",\n"
                                        "      \"image\": \"http://lifestylelabels.com/pub/media/catalog/product/m/p/mp001.jpg\",\n"
                                        "      \"zoom_image\": \"http://lifestylelabels.com/pub/media/catalog/product/m/p/mp001.jpg\",\n"
                                        "      \"description\": \"product Description\",\n"
                                        "      \"album\": \"album\",\n"
                                        "      \"actor\": \"actor\",\n"
                                        "      \"artist\": \"artist\",\n"
                                        "      \"author\": \"author\",\n"
                                        "      \"brand\": \"brand\",\n"
                                        "      \"year\": 2000,\n"
                                        "    },\n"
                                        "    \"2120\": {\n"
                                        "      \"item\": \"2120\",\n"
                                        "      \"title\": \"LSL Men Polo Shirt LE16\",\n"
                                        "      \"link\": \"http://lifestylelabels.com/lsl-men-polo-shirt-le16.html\",\n"
                                        "    }\n"
                                        "  }\n"
                                        "}";

                EMSProduct *expectedProduct1 = [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
                    [builder setRequiredFieldsWithProductId:@"2119" title:@"LSL Men Polo Shirt SE16"
                                                    linkUrl:[[NSURL alloc]
                                                            initWithString:@"http://lifestylelabels.com/lsl-men-polo-shirt-se16.html"]];

                    [builder setCategoryPath:@"MEN>Shirts"];
                    [builder setAvailable:@(YES)];
                    [builder setMsrp:@(100.0)];
                    [builder setPrice:@(100.0)];
                    [builder setImageUrl:[[NSURL alloc] initWithString:@"http://lifestylelabels.com/pub/media/catalog/product/m/p/mp001.jpg"]];
                    [builder setZoomImageUrl:[[NSURL alloc] initWithString:@"http://lifestylelabels.com/pub/media/catalog/product/m/p/mp001.jpg"]];
                    [builder setProductDescription:@"product Description"];
                    [builder setAlbum:@"album"];
                    [builder setActor:@"actor"];
                    [builder setArtist:@"artist"];
                    [builder setAuthor:@"author"];
                    [builder setBrand:@"brand"];
                    [builder setYear:@(2000)];
                    [builder setCustomFields:@{@"msrp_gpb": @"83.2",
                            @"price_gpb": @"83.2",
                            @"msrp_aed": @"100",
                            @"price_aed": @"100",
                            @"msrp_cad": @"100",
                            @"price_cad": @"100",
                            @"msrp_mxn": @"2057.44",
                            @"price_mxn": @"2057.44",
                            @"msrp_pln": @"100",
                            @"price_pln": @"100",
                            @"msrp_rub": @"100",
                            @"price_rub": @"100",
                            @"msrp_sek": @"100",
                            @"price_sek": @"100",
                            @"msrp_try": @"339.95",
                            @"price_try": @"339.95",
                            @"msrp_usd": @"100",
                            @"price_usd": @"100"}];
                }];
                EMSProduct *expectedProduct2 = [EMSProduct makeWithBuilder:^(EMSProductBuilder *builder) {
                    [builder setRequiredFieldsWithProductId:@"2120"
                                                      title:@"LSL Men Polo Shirt LE16"
                                                    linkUrl:[[NSURL alloc] initWithString:@"http://lifestylelabels.com/lsl-men-polo-shirt-le16.html"]];
                }];

                assertProducts(rawResponse, @[expectedProduct1, expectedProduct2]);
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


                [predictInternal recommendProducts:^(NSArray<EMSProduct *> *products, NSError *error) {
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
                [[returnedThread should] equal: NSThread.mainThread];
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
                                                                             requestManager:requestManager];
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


                NSData *serializedData = [NSJSONSerialization dataWithJSONObject:@{@"name": tag, @"attributes": attributes} options:0 error:nil];
                NSString *expectedPayload = [[NSString alloc] initWithData:serializedData encoding:NSUTF8StringEncoding];

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
                                                                             requestManager:requestManager];
                [internal trackTag:tag withAttributes:attributes];
            });

        });
SPEC_END
