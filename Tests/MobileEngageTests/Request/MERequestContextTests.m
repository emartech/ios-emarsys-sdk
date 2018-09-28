#import "Kiwi.h"
#import "MERequestContext.h"
#import "EMSUUIDProvider.h"

SPEC_BEGIN(MERequestContextTests)

        describe(@"uuidProvider", ^{
            it(@"should be initialized after requestContext has been initialized", ^{

                MERequestContext *requestContext = [[MERequestContext alloc] initWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMerchantId:@"merchantId"];
                    [builder setContactFieldId:@3];
                    [builder setMobileEngageApplicationCode:@"applicationCode"
                                        applicationPassword:@"applicationPassword"];
                }]];
                [[requestContext.uuidProvider shouldNot] beNil];
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
                MERequestContext *context = [[MERequestContext alloc] initWithConfig:config];
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
                MERequestContext *context = [[MERequestContext alloc] initWithConfig:config];

                [[context.meIdSignature should] equal:meIDSignature];
            });
        });

SPEC_END
