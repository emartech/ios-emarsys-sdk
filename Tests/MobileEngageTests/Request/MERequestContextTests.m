#import "Kiwi.h"
#import "MERequestContext.h"
#import "EMSUUIDProvider.h"
#import "EMSDeviceInfo.h"

SPEC_BEGIN(MERequestContextTests)


        __block EMSUUIDProvider *uuidProvider = [EMSUUIDProvider new];
        __block EMSTimestampProvider *timestampProvider = [EMSTimestampProvider new];
        __block EMSDeviceInfo *deviceInfo = [EMSDeviceInfo new];

        describe(@"intialization", ^{

            it(@"should throw exception when uuidProvider is nil", ^{
                @try {
                    MERequestContext *requestContext = [[MERequestContext alloc] initWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMerchantId:@"merchantId"];
                            [builder setContactFieldId:@3];
                            [builder setMobileEngageApplicationCode:@"applicationCode"
                                                applicationPassword:@"applicationPassword"];
                        }]
                                                                                   uuidProvider:nil
                                                                              timestampProvider:[EMSTimestampProvider mock]
                                                                                     deviceInfo:[EMSDeviceInfo mock]];
                    fail(@"Expected Exception when uuidProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: uuidProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when timestampProvider is nil", ^{
                @try {
                    MERequestContext *requestContext = [[MERequestContext alloc] initWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMerchantId:@"merchantId"];
                            [builder setContactFieldId:@3];
                            [builder setMobileEngageApplicationCode:@"applicationCode"
                                                applicationPassword:@"applicationPassword"];
                        }]
                                                                                   uuidProvider:[EMSUUIDProvider mock]
                                                                              timestampProvider:nil
                                                                                     deviceInfo:[EMSDeviceInfo mock]];
                    fail(@"Expected Exception when timestampProvider is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: timestampProvider"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when deviceInfo is nil", ^{
                @try {
                    MERequestContext *requestContext = [[MERequestContext alloc] initWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                            [builder setMerchantId:@"merchantId"];
                            [builder setContactFieldId:@3];
                            [builder setMobileEngageApplicationCode:@"applicationCode"
                                                applicationPassword:@"applicationPassword"];
                        }]
                                                                                   uuidProvider:[EMSUUIDProvider mock]
                                                                              timestampProvider:[EMSTimestampProvider mock]
                                                                                     deviceInfo:nil];
                    fail(@"Expected Exception when deviceInfo is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: deviceInfo"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

        });

        describe(@"meId, meIdSignature", ^{

            it(@"should load the stored value when setup called on MobileEngageInternal", ^{
                NSString *meID = @"StoredValueOfMobileEngageId";
                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
                [userDefaults setObject:meID
                                 forKey:kMEID];
                [userDefaults synchronize];
                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMobileEngageApplicationCode:@"kAppId"
                                        applicationPassword:@"kAppSecret"];
                    [builder setMerchantId:@"dummyMerchantId"];
                    [builder setContactFieldId:@3];
                }];
                MERequestContext *context = [[MERequestContext alloc] initWithConfig:config
                                                                        uuidProvider:uuidProvider
                                                                   timestampProvider:timestampProvider
                                                                          deviceInfo:deviceInfo];
                [[context.meId should] equal:meID];
            });


            it(@"should load the stored value when setup called on MobileEngageInternal", ^{
                NSString *meIDSignature = @"signature";

                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
                [userDefaults setObject:meIDSignature
                                 forKey:kMEID_SIGNATURE];
                [userDefaults synchronize];
                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMobileEngageApplicationCode:@"kAppId"
                                        applicationPassword:@"kAppSecret"];
                    [builder setMerchantId:@"dummyMerchantId"];
                    [builder setContactFieldId:@3];
                }];
                MERequestContext *context = [[MERequestContext alloc] initWithConfig:config
                                                                        uuidProvider:uuidProvider
                                                                   timestampProvider:timestampProvider
                                                                          deviceInfo:deviceInfo];

                [[context.meIdSignature should] equal:meIDSignature];
            });
        });

SPEC_END
