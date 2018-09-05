#import "Kiwi.h"
#import "EMSConfig.h"
#import "EMSConfigBuilder.h"

SPEC_BEGIN(BuilderTest)

    describe(@"setExperimentalFeatures", ^{
        it(@"should set the given accepted experimental features in the config", ^{
            NSArray *features = @[INAPP_MESSAGING];

            EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"code" applicationPassword:@"pass"];
                [builder setExperimentalFeatures:features];
            }];

            [[config.experimentalFeatures should] equal:features];
        });
    });

    describe(@"setCredentialsWithApplicationCode", ^{

        it(@"should create a config with applicationCode", ^{
            EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"test1" applicationPassword:@"pwd"];
            }];

            [[theValue(@"test1") should] equal:theValue(config.applicationCode)];
        });

        it(@"should create a config with applicationPassword", ^{
            EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"test1" applicationPassword:@"pwd"];
            }];

            [[theValue(@"pwd") should] equal:theValue(config.applicationPassword)];
        });

        it(@"should throw exception when applicationCode is nil", ^{
            @try {
                [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:nil applicationPassword:@"pwd"];
                }];
                fail(@"Expected Exception when applicationCode is nil!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should throw exception when secret is nil", ^{
            @try {
                [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:@"test1" applicationPassword:nil];
                }];
                fail(@"Expected Exception when applicationPassword is nil!");
            } @catch(NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

    });

SPEC_END
