#import "Kiwi.h"
#import "FakeStatusDelegate.h"
#import "MobileEngage.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"
#import "MEExperimental.h"
#import "MEExperimental+Test.h"
#import "MERequestContext.h"
#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EMSSQLiteQueueDB.db"]

SPEC_BEGIN(IntegrationTests)

    FakeStatusDelegate *(^createStatusDelegate)() = ^FakeStatusDelegate *() {
        FakeStatusDelegate *statusDelegate = [FakeStatusDelegate new];
        statusDelegate.printErrors = YES;
        return statusDelegate;
    };

    beforeEach(^{
        [MEExperimental enableFeature:INAPP_MESSAGING];
        [[NSFileManager defaultManager] removeItemAtPath:DB_PATH
                                                   error:nil];

        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
        [userDefaults removeObjectForKey:kMEID];
        [userDefaults removeObjectForKey:kMEID_SIGNATURE];
        [userDefaults removeObjectForKey:kLastAppLoginPayload];
        [userDefaults synchronize];

    });

    describe(@"Public interface methods", ^{
        it(@"should return with eventId, and finish with success for anonymousAppLogin", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                       applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            NSString *eventId = [MobileEngage appLogin];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
        });

        it(@"should return with eventId, and finish with success for appLogin", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                       applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            NSString *eventId = [MobileEngage appLoginWithContactFieldId:@3
                                                       contactFieldValue:@"test@test.com"];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
        });

        it(@"should return with eventId, and finish with success for trackMessageOpen:", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                       applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            NSString *eventId = [MobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"dd8_zXfDdndBNEQi\"}"}];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
        });

        it(@"should return with eventId, and finish with success for trackCustomEvent without attributes", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                       applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            [MobileEngage appLogin];
            [statusDelegate waitForNextSuccess];

            NSString *eventId = [MobileEngage trackCustomEvent:@"eventName"
                                               eventAttributes:nil];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
        });

        it(@"should return with eventId, and finish with success for trackCustomEvent with attributes", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                       applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            [MobileEngage appLogin];
            [statusDelegate waitForNextSuccess];

            NSString *eventId = [MobileEngage trackCustomEvent:@"eventName"
                                               eventAttributes:@{
                                                       @"animal": @"cat",
                                                       @"drink": @"palinka",
                                                       @"food": @"pizza"
                                               }];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
        });

        it(@"should return with eventId, and finish with success for trackCustomEvent without attributes", ^{
            [MEExperimental reset];

            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                       applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            NSString *eventId = [MobileEngage trackCustomEvent:@"eventName"
                                               eventAttributes:nil];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
        });

        it(@"should return with eventId, and finish with success for trackCustomEvent with attributes", ^{
            [MEExperimental reset];

            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                       applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            NSString *eventId = [MobileEngage trackCustomEvent:@"eventName"
                                               eventAttributes:@{
                                                       @"animal": @"cat",
                                                       @"drink": @"palinka",
                                                       @"food": @"pizza"
                                               }];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
        });

        it(@"should return with eventId, and finish with success for appLogout", ^{
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                       applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            }];
            [MobileEngage setupWithConfig:config
                            launchOptions:nil];
            FakeStatusDelegate *statusDelegate = createStatusDelegate();
            [MobileEngage setStatusDelegate:statusDelegate];

            NSString *eventId = [MobileEngage appLogout];

            [[eventId shouldNot] beNil];
            [[expectFutureValue(@(statusDelegate.errorCount)) shouldEventually] equal:@0];
            [[expectFutureValue(@(statusDelegate.successCount)) shouldEventually] equal:@1];
        });
    });

SPEC_END
