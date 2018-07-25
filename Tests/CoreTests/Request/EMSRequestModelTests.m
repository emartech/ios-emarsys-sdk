//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSRequestModel.h"
#import "EMSRequestModelBuilder.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"

SPEC_BEGIN(EMSRequestModelTests)

        describe(@"Builder", ^{

            it(@"should throw exception, when timestampProvider is nil", ^{
                @try {
                    [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                            [builder setUrl:@"http://www.google.com"];
                        }          timestampProvider:nil
                                        uuidProvider:[EMSUUIDProvider mock]];
                    fail(@"Expected exception when timestampProvider is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception, when uuidProvider is nil", ^{
                @try {
                    [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                            [builder setUrl:@"http://www.google.com"];
                        }          timestampProvider:[EMSTimestampProvider new]
                                        uuidProvider:nil];
                    fail(@"Expected exception when uuidProvider is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should use timestampProvider", ^{
                NSDate *expectedDate = [NSDate date];
                EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
                [[timestampProvider should] receive:@selector(provideTimestamp)
                                          andReturn:expectedDate];
                EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"http://www.google.com"];
                    }                                          timestampProvider:timestampProvider
                                                                    uuidProvider:[EMSUUIDProvider new]];
                [[[requestModel timestamp] should] equal:expectedDate];
            });

            it(@"should use uuidProvider", ^{
                NSUUID *expectedUUID = [NSUUID UUID];
                EMSUUIDProvider *uuidProvider = [EMSUUIDProvider mock];
                [[uuidProvider should] receive:@selector(provideUUID)
                                     andReturn:expectedUUID];
                EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"http://www.google.com"];
                    }                                          timestampProvider:[EMSTimestampProvider new]
                                                                    uuidProvider:uuidProvider];
                [[[requestModel requestId] should] equal:[expectedUUID UUIDString]];
            });

            it(@"should create a model with requestId and timestamp", ^{
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"http://www.google.com"];
                    }                                   timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];

                [[model.timestamp shouldNot] beNil];
                [[model.requestId shouldNot] beNil];
            });

            it(@"should create a model where default requestMethod is POST", ^{
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"http://www.google.com"];
                    }                                   timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];

                [[model.method should] equal:@"POST"];
            });

            it(@"should create a model with specified requestMethod when setMethod is called on builder", ^{
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setMethod:HTTPMethodGET];
                        [builder setUrl:@"http://www.google.com"];
                    }                                   timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];

                [[model.method should] equal:@"GET"];
            });

            it(@"should create a model with specified requestUrl when setUrl is called on builder", ^{
                NSString *urlString = @"http://www.google.com";
                NSURL *url = [NSURL URLWithString:urlString];
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:urlString];
                    }                                   timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];

                [[model.url shouldNot] beNil];
                [[model.url should] equal:url];
            });

            it(@"should create a model with specified ttl when setExpiry is called on the builder", ^{
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"http://www.google.com"];
                        [builder setExpiry:3];
                    }                                   timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];

                [[theValue(model.ttl) should] equal:theValue(3)];
            });

            it(@"should create a model with specified body when setBody is called on builder", ^{
                NSString *urlString = @"http://www.google.com";
                NSDictionary *payload = @{@"key": @"value"};
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setPayload:payload];
                        [builder setUrl:@"http://www.google.com"];
                    }                                   timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];

                [[model.payload should] equal:payload];
            });

            it(@"should create a model with specified headers when setHeaders is called on builder", ^{
                NSDictionary<NSString *, NSString *> *headers = @{
                    @"key": @"value",
                    @"key2": @"value2"
                };
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setHeaders:headers];
                        [builder setUrl:@"http://www.google.com"];
                    }                                   timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];

                [[model.headers should] equal:headers];
            });

            it(@"should create a model with specified extras when setExtras is called on builder", ^{
                NSDictionary<NSString *, NSString *> *extras = @{
                    @"extra1": @"value1",
                    @"extra2": @"value2"
                };
                EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"http://www.google.com"];
                        [builder setExtras:extras];
                    }                                   timestampProvider:[EMSTimestampProvider new]
                                                             uuidProvider:[EMSUUIDProvider new]];

                [[model.extras should] equal:extras];
            });

            it(@"should throw an exception, when builderBlock is nil", ^{
                @try {
                    [EMSRequestModel makeWithBuilder:nil timestampProvider:[EMSTimestampProvider new]
                                        uuidProvider:[EMSUUIDProvider new]];
                    fail(@"Assertation doesn't called!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception, when requestUrl is invalid", ^{
                @try {
                    [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                            [builder setUrl:@"fatal"];
                        }          timestampProvider:[EMSTimestampProvider new]
                                        uuidProvider:[EMSUUIDProvider new]];
                    fail(@"Assertation doesn't called!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw an exception, when requestUrl is nil", ^{
                @try {
                    [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        }          timestampProvider:[EMSTimestampProvider new]
                                        uuidProvider:[EMSUUIDProvider new]];
                    fail(@"Assertation doesn't called!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

        });

SPEC_END
