//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSPredictMapper.h"
#import "EMSShard.h"
#import "EMSRequestModel.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "PRERequestContext.h"
#import "EMSDeviceInfo.h"
#import "EMSEndpoint.h"
#import "EMSValueProvider.h"

#define USER_AGENT [NSString stringWithFormat:@"EmarsysSDK|osversion:%@|platform:%@", [[EMSDeviceInfo new] osVersion], [[EMSDeviceInfo new] systemName]]

SPEC_BEGIN(EMSPredictMapperTests)

        __block EMSPredictMapper *mapper;
        __block EMSTimestampProvider *timestampProvider;
        __block EMSUUIDProvider *uuidProvider;
        __block PRERequestContext *requestContext;
        __block EMSDeviceInfo *deviceInfo;
        __block EMSEndpoint *endpoint;

        NSDate *timestamp = [NSDate date];
        NSString *uuidString = @"uuidString";
        NSString *merchantId = @"merchantId";
        NSString *customerId = @"3";

        beforeEach(^{
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSPredictSuiteName];
            [userDefaults setObject:nil
                             forKey:kEMSCustomerId];
            [userDefaults setObject:nil
                             forKey:kEMSVisitorId];
            [userDefaults synchronize];

            timestampProvider = [EMSTimestampProvider mock];
            uuidProvider = [EMSUUIDProvider mock];
            deviceInfo = [EMSDeviceInfo new];

            [timestampProvider stub:@selector(provideTimestamp)
                          andReturn:timestamp];
            [uuidProvider stub:@selector(provideUUIDString)
                     andReturn:uuidString];
            requestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                     uuidProvider:uuidProvider
                                                                       merchantId:merchantId
                                                                       deviceInfo:deviceInfo];
            [requestContext setCustomerId:customerId];

            EMSValueProvider *predictUrlProvider = [[EMSValueProvider alloc] initWithDefaultValue:@"https://recommender.scarabresearch.com"
                                                                                         valueKey:@"PREDICT_URL"];
            endpoint = [[EMSEndpoint alloc] initWithClientServiceUrlProvider:[EMSValueProvider mock]
                                                     eventServiceUrlProvider:[EMSValueProvider mock]
                                                          predictUrlProvider:predictUrlProvider
                                                         deeplinkUrlProvider:[EMSValueProvider mock]
                                                   v2EventServiceUrlProvider:[EMSValueProvider mock]
                                                            inboxUrlProvider:[EMSValueProvider mock]];
            mapper = [[EMSPredictMapper alloc] initWithRequestContext:requestContext
                                                             endpoint:endpoint];
        });

        describe(@"initWithRequestContext:endpoint:", ^{
            it(@"should throw exception when requestContext is nil", ^{
                @try {
                    [[EMSPredictMapper alloc] initWithRequestContext:nil
                                                            endpoint:[EMSEndpoint mock]];
                    fail(@"Expected Exception when requestContext is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestContext"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when endpoint is nil", ^{
                @try {
                    [[EMSPredictMapper alloc] initWithRequestContext:[PRERequestContext mock]
                                                            endpoint:nil];
                    fail(@"Expected Exception when endpoint is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: endpoint"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"requestFromShards:", ^{

            it(@"should throw exception when shards are nil", ^{
                @try {
                    [mapper requestFromShards:nil];
                    fail(@"Expected Exception when shardList is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: shards"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when shardList is empty", ^{
                @try {
                    [mapper requestFromShards:@[]];
                    fail(@"Expected Exception when shardList is empty!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: [shards count] > 0"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should return with a RequestModel when the shards array is valid", ^{
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"shardId"
                                                               type:@"shardType"
                                                               data:@{@"dataKey": @"dataValue"}
                                                          timestamp:[NSDate date]
                                                                ttl:42.0];
                NSArray<EMSShard *> *shards = @[shard];

                EMSRequestModel *requestModel = [mapper requestFromShards:shards];

                [[requestModel shouldNot] beNil];
            });

            it(@"should return with a RequestModel with User-Agent set", ^{
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"shardId"
                                                               type:@"shardType"
                                                               data:@{@"dataKey": @"dataValue"}
                                                          timestamp:[NSDate date]
                                                                ttl:42.0];
                NSArray<EMSShard *> *shards = @[shard];

                EMSRequestModel *requestModel = [mapper requestFromShards:shards];


                [[requestModel.headers[@"User-Agent"] should] equal:USER_AGENT];
            });

            it(@"should use injected timestampProvider and uuidProvider to create a requestModel", ^{
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"shardId"
                                                               type:@"shardType"
                                                               data:@{@"dataKey": @"dataValue"}
                                                          timestamp:[NSDate date]
                                                                ttl:42.0];
                NSArray<EMSShard *> *shards = @[shard];

                EMSRequestModel *requestModel = [mapper requestFromShards:shards];

                [[requestModel.timestamp should] equal:timestamp];
                [[requestModel.requestId should] equal:uuidString];
                [[requestModel.url.absoluteString should] startWithString:@"https://recommender.scarabresearch.com/merchants/merchantId"];
            });

            it(@"should create a requestModel with parameterized url", ^{
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"shardId"
                                                               type:@"shardType"
                                                               data:@{@"dataKey": @"dataValue>>::,|"}
                                                          timestamp:[NSDate date]
                                                                ttl:42.0];
                NSArray<EMSShard *> *shards = @[shard];

                EMSRequestModel *requestModel = [mapper requestFromShards:shards];

                [[requestModel.timestamp should] equal:timestamp];
                [[requestModel.requestId should] equal:uuidString];
                [[requestModel.url.absoluteString should] equal:@"https://recommender.scarabresearch.com/merchants/merchantId?cp=1&ci=3&dataKey=dataValue%3E%3E%3A%3A%2C%7C"];
            });

            it(@"should return with correct requestModel when the shard list contain only one shard and there is no visitorId", ^{
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"shardId"
                                                               type:@"shardType"
                                                               data:@{@"dataKey": @"dataValue"}
                                                          timestamp:timestamp
                                                                ttl:42.0];
                NSArray<EMSShard *> *shards = @[shard];
                EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:uuidString
                                                                                         timestamp:timestamp
                                                                                            expiry:42.0
                                                                                               url:[NSURL URLWithString:@"https://recommender.scarabresearch.com/merchants/merchantId?cp=1&ci=3&dataKey=dataValue"]
                                                                                            method:@"GET"
                                                                                           payload:nil
                                                                                           headers:@{@"User-Agent": USER_AGENT}
                                                                                            extras:nil];

                requestContext.visitorId = nil;
                mapper = [[EMSPredictMapper alloc] initWithRequestContext:requestContext
                                                                 endpoint:endpoint];
                EMSRequestModel *requestModel = [mapper requestFromShards:shards];

                [[requestModel should] equal:expectedRequestModel];
            });

            it(@"should return with correct requestModel when the shard list contain only one shard and there is a visitorId", ^{
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"shardId"
                                                               type:@"shardType"
                                                               data:@{@"dataKey": @"dataValue"}
                                                          timestamp:timestamp
                                                                ttl:42.0];
                NSArray<EMSShard *> *shards = @[shard];
                EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:uuidString
                                                                                         timestamp:timestamp
                                                                                            expiry:42.0
                                                                                               url:[NSURL URLWithString:@"https://recommender.scarabresearch.com/merchants/merchantId?vi=visitorId&cp=1&ci=3&dataKey=dataValue"]
                                                                                            method:@"GET"
                                                                                           payload:nil
                                                                                           headers:@{@"User-Agent": USER_AGENT}
                                                                                            extras:nil];

                requestContext.visitorId = @"visitorId";
                mapper = [[EMSPredictMapper alloc] initWithRequestContext:requestContext
                                                                 endpoint:endpoint];
                EMSRequestModel *requestModel = [mapper requestFromShards:shards];

                [[requestModel should] equal:expectedRequestModel];
            });

            it(@"should return with correct requestModel when there is no customerId", ^{
                EMSShard *shard = [[EMSShard alloc] initWithShardId:@"shardId"
                                                               type:@"shardType"
                                                               data:@{@"dataKey": @"dataValue"}
                                                          timestamp:timestamp
                                                                ttl:42.0];
                NSArray<EMSShard *> *shards = @[shard];
                EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:uuidString
                                                                                         timestamp:timestamp
                                                                                            expiry:42.0
                                                                                               url:[NSURL URLWithString:@"https://recommender.scarabresearch.com/merchants/merchantId?cp=1&dataKey=dataValue"]
                                                                                            method:@"GET"
                                                                                           payload:nil
                                                                                           headers:@{@"User-Agent": USER_AGENT}
                                                                                            extras:nil];

                requestContext.visitorId = nil;
                requestContext.customerId = nil;
                mapper = [[EMSPredictMapper alloc] initWithRequestContext:requestContext
                                                                 endpoint:endpoint];
                EMSRequestModel *requestModel = [mapper requestFromShards:shards];

                [[requestModel should] equal:expectedRequestModel];
            });

        });


SPEC_END
