//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSShard.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"

SPEC_BEGIN(EMSShardTests)

        describe(@"EMSShard init", ^{

            it(@"should not accept nil for category", ^{
                @try {
                    [[EMSShard alloc] initWithShardId:nil
                                                 type:nil
                                                 data:[NSDictionary new]
                                            timestamp:[NSDate date]
                                                  ttl:1.0];
                    fail(@"Expected exception when category is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should not accept nil for timestamp", ^{
                @try {
                    [[EMSShard alloc] initWithShardId:nil
                                                 type:@"category"
                                                 data:[NSDictionary new]
                                            timestamp:nil
                                                  ttl:1.0];
                    fail(@"Expected exception when timestamp is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should not accept nil for data", ^{
                @try {
                    [[EMSShard alloc] initWithShardId:nil type:@"category" data:nil timestamp:[NSDate date] ttl:1.0];
                    fail(@"Expected exception when data is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

        });

        describe(@"makeWithBuilder:timestampProvider:uuidProvider:", ^{
            it(@"should initialize shard correctly", ^{
                NSDate *expectedDate = [NSDate date];

                NSString *shardType = @"shardType";
                NSString *shardId = @"shardId";
                NSTimeInterval timeInterval = 42.0;

                NSString *payloadKey = @"payloadKey";
                NSDictionary *payloadValue = @{
                        @"key": @{
                                @"key1": @1132,
                                @"key2": @[
                                        @{
                                                @"subkey1": @"subitem1"
                                        },
                                        @{
                                                @"subkey1": @1234.0
                                        }
                                ],
                        }
                };

                EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
                EMSUUIDProvider *uuidProvider = [EMSUUIDProvider mock];
                [[timestampProvider should] receive:@selector(provideTimestamp) andReturn:expectedDate];
                [[uuidProvider should] receive:@selector(provideUUIDString) andReturn:shardId];


                EMSShard *shard = [EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                            [builder setTTL:timeInterval];
                            [builder setType:shardType];
                        [builder addPayloadEntryWithKey:payloadKey
                                                  value:payloadValue];
                        }
                                          timestampProvider:timestampProvider
                                               uuidProvider:uuidProvider];

                [[shard.shardId should] equal:shardId];
                [[shard.timestamp should] equal:expectedDate];
                [[shard.type should] equal:shardType];
                [[theValue(shard.ttl) should] equal:theValue(timeInterval)];
                [[shard.data should] equal:@{payloadKey: payloadValue}];
            });
        });

SPEC_END
