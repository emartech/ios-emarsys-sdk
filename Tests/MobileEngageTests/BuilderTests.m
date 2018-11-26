#import "Kiwi.h"
#import "EMSConfig.h"

SPEC_BEGIN(BuilderTest)

        describe(@"setExperimentalFeatures", ^{
            it(@"should set the given accepted experimental features in the config", ^{
                NSArray *features = @[];

                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMobileEngageApplicationCode:@"code" applicationPassword:@"pass"];
                    [builder setExperimentalFeatures:features];
                    [builder setMerchantId:@"merchantId"];
                    [builder setContactFieldId:@"contactFieldId"];

                }];

                [[config.experimentalFeatures should] equal:features];
            });
        });

        describe(@"setCredentialsWithApplicationCode", ^{

            it(@"should create a config with applicationCode", ^{
                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMobileEngageApplicationCode:@"test1" applicationPassword:@"pwd"];
                    [builder setMerchantId:@"merchantId"];
                    [builder setContactFieldId:@"contactFieldId"];

                }];

                [[@"test1" should] equal:config.applicationCode];
            });

            it(@"should create a config with applicationPassword", ^{
                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMobileEngageApplicationCode:@"test1" applicationPassword:@"pwd"];
                    [builder setMerchantId:@"merchantId"];
                    [builder setContactFieldId:@"contactFieldId"];

                }];

                [[@"pwd" should] equal:config.applicationPassword];
            });

            it(@"should throw exception when applicationCode is nil", ^{
                @try {
                    [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:nil applicationPassword:@"pwd"];
                        [builder setMerchantId:@"merchantId"];
                        [builder setContactFieldId:@"contactFieldId"];

                    }];
                    fail(@"Expected Exception when applicationCode is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when secret is nil", ^{
                @try {
                    [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"test1" applicationPassword:nil];
                        [builder setMerchantId:@"merchantId"];
                        [builder setContactFieldId:@"contactFieldId"];

                    }];
                    fail(@"Expected Exception when applicationPassword is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });
        });

        describe(@"setMerchantId", ^{

            it(@"should throw exception when merchantId is nil", ^{
                @try {
                    [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"code" applicationPassword:@"pass"];
                        [builder setMerchantId:nil];
                        [builder setContactFieldId:@"contactFieldId"];
                    }];
                    fail(@"Expected Exception when merchantId is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should set merchantId on EMSConfig", ^{
                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMobileEngageApplicationCode:@"code" applicationPassword:@"pass"];
                    [builder setMerchantId:@"merchantId"];
                    [builder setContactFieldId:@"contactFieldId"];
                }];
                [[@"merchantId" should] equal:config.merchantId];

            });
        });
        describe(@"setContactFieldId", ^{

            it(@"should throw exception when contactFieldId is nil", ^{
                @try {
                    [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"code" applicationPassword:@"pass"];
                        [builder setMerchantId:@"merchantId"];
                        [builder setContactFieldId:nil];
                    }];
                    fail(@"Expected Exception when contactFieldId is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should set contactFieldId on EMSConfig", ^{
                EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setMobileEngageApplicationCode:@"code" applicationPassword:@"pass"];
                    [builder setMerchantId:@"merchantId"];
                    [builder setContactFieldId:@"contactFieldId"];
                }];
                [[@"contactFieldId" should] equal:config.contactFieldId];

            });
        });

SPEC_END
