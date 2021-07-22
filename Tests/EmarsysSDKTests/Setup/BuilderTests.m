#import "Kiwi.h"
#import "EMSConfig.h"

SPEC_BEGIN(BuilderTest)

        describe(@"setExperimentalFeatures", ^{
            it(@"should set the given accepted experimental features in the config", ^{

                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMobileEngageApplicationCode:@"code"];
                    [builder setExperimentalFeatures:@[]];
                    [builder setMerchantId:@"merchantId"];
                }];

                [[config.experimentalFeatures should] equal:@[]];
            });
        });

        describe(@"setCredentialsWithApplicationCode", ^{

            it(@"should create a config with applicationCode", ^{
                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMobileEngageApplicationCode:@"test1"];
                    [builder setMerchantId:@"merchantId"];
                }];

                [[@"test1" should] equal:config.applicationCode];
            });
        });

        describe(@"setMerchantId", ^{

            it(@"should set merchantId on EMSConfig", ^{
                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMobileEngageApplicationCode:@"code"];
                    [builder setMerchantId:@"merchantId"];
                }];
                [[@"merchantId" should] equal:config.merchantId];

            });
        });

SPEC_END
