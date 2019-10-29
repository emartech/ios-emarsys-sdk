//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "PRERequestContext.h"
#import "EMSUUIDProvider.h"
#import "EMSTimestampProvider.h"
#import "EMSDeviceInfo.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"

SPEC_BEGIN(PRERequestContextTests)

        __block EMSTimestampProvider *timestampProvider;
        __block EMSUUIDProvider *uuidProvider;
        __block EMSDeviceInfo *deviceInfo;

        beforeEach(^{
            timestampProvider = [EMSTimestampProvider new];
            uuidProvider = [EMSUUIDProvider new];
            deviceInfo = [EMSDeviceInfo new];
        });

        afterEach(^{
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSPredictSuiteName];
            [userDefaults setObject:nil
                             forKey:kEMSCustomerId];
            [userDefaults setObject:nil
                             forKey:kEMSVisitorId];
            [userDefaults synchronize];
        });

        describe(@"initWithTimestampProvider:uuidProvider:merchantId:deviceInfo:", ^{
            it(@"should throw exception when timestampProvider is nil", ^{
                @try {
                    [[PRERequestContext alloc] initWithTimestampProvider:nil
                                                            uuidProvider:uuidProvider
                                                              merchantId:@"merchantId"
                                                              deviceInfo:deviceInfo];
                    fail(@"Expected Exception when timestampProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: timestampProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when uuidProvider is nil", ^{
                @try {
                    [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                            uuidProvider:nil
                                                              merchantId:@"merchantId"
                                                              deviceInfo:deviceInfo];
                    fail(@"Expected Exception when uuidProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: uuidProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when deviceInfo is nil", ^{
                @try {
                    [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                            uuidProvider:uuidProvider
                                                              merchantId:@"merchantId"
                                                              deviceInfo:nil];
                    fail(@"Expected Exception when deviceInfo is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: deviceInfo"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"setCustomerId:", ^{
            it(@"should persist the parameter", ^{
                NSString *const customerId = @"testId";
                [[[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                         uuidProvider:uuidProvider
                                                           merchantId:@"merchantId"
                                                           deviceInfo:deviceInfo] setCustomerId:customerId];
                [[[[[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                           uuidProvider:uuidProvider
                                                             merchantId:@"merchantId"
                                                             deviceInfo:deviceInfo] customerId] should] equal:customerId];
            });
        });

        describe(@"setVisitorId:", ^{
            it(@"should persist the parameter", ^{
                NSString *const visitorId = @"visitorId";
                [[[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                         uuidProvider:uuidProvider
                                                           merchantId:@"merchantId"
                                                           deviceInfo:deviceInfo] setVisitorId:visitorId];
                [[[[[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                           uuidProvider:uuidProvider
                                                             merchantId:@"merchantId"
                                                             deviceInfo:deviceInfo] visitorId] should] equal:visitorId];
            });
        });

        describe(@"xp:", ^{
            it(@"should persist the parameter", ^{
                NSString *const xp = @"xp";
                [[[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                         uuidProvider:uuidProvider
                                                           merchantId:@"merchantId"
                                                           deviceInfo:deviceInfo] setXp:xp];
                [[[[[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                           uuidProvider:uuidProvider
                                                             merchantId:@"merchantId"
                                                             deviceInfo:deviceInfo] xp] should] equal:xp];
            });

            it(@"should remove the persisted value when it set to nil", ^{
                NSString *const xp = @"xp";
                [[[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                         uuidProvider:uuidProvider
                                                           merchantId:@"merchantId"
                                                           deviceInfo:deviceInfo] setXp:xp];
                [[[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                         uuidProvider:uuidProvider
                                                           merchantId:@"merchantId"
                                                           deviceInfo:deviceInfo] setXp:nil];
                [[[[[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                           uuidProvider:uuidProvider
                                                             merchantId:@"merchantId"
                                                             deviceInfo:deviceInfo] xp] should] beNil];
            });
        });

        describe(@"predictInnerFeature", ^{
            it(@"should enable predictInnerFeature when merchantId is set", ^{
                PRERequestContext *requestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                                            uuidProvider:uuidProvider
                                                                                              merchantId:@"merchantId"
                                                                                              deviceInfo:deviceInfo];
                [MEExperimental disableFeature:EMSInnerFeature.predict];

                [requestContext setMerchantId:@"merchantId"];

                [[theValue([MEExperimental isFeatureEnabled:EMSInnerFeature.predict]) should] beYes];
            });

            it(@"should disable predictInnerFeature when merchantId is set to nil", ^{
                PRERequestContext *requestContext = [[PRERequestContext alloc] initWithTimestampProvider:timestampProvider
                                                                                            uuidProvider:uuidProvider
                                                                                              merchantId:@"merchantId"
                                                                                              deviceInfo:deviceInfo];
                [MEExperimental enableFeature:EMSInnerFeature.predict];

                [requestContext setMerchantId:nil];

                [[theValue([MEExperimental isFeatureEnabled:EMSInnerFeature.predict]) should] beNo];
            });
        });

SPEC_END
