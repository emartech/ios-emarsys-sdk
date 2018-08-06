#import "Kiwi.h"
#import "EMSRequestManager.h"
#import "MobileEngageInternal.h"
#import "MobileEngageInternal+Private.h"
#import "MEConfigBuilder.h"
#import "MEConfig.h"
#import "EMSRequestModelBuilder.h"
#import "EMSRequestModelMatcher.h"
#import "EMSAuthentication.h"
#import "EMSDeviceInfo.h"
#import "MobileEngageVersion.h"
#import "MERequestContext.h"
#import "FakeRequestManager.h"
#import "MEIdResponseHandler.h"
#import "MEIAMResponseHandler.h"
#import "MobileEngageInternal+Test.h"
#import "MEExperimental.h"
#import "MERequestRepositoryProxy.h"
#import "MEIAMCleanupResponseHandler.h"
#import "MENotificationCenterManager.h"
#import "MEInApp.h"
#import "MERequestModelRepositoryFactory.h"
#import "MEExperimental+Test.h"
#import "NSDate+EMSCore.h"
#import "EMSWaiter.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EMSSQLiteQueueDB.db"]

static NSString *const kAppId = @"kAppId";
static NSString *const kAppSecret = @"kAppSecret";
static NSString *const kMEId = @"kMeId";
static NSString *const kMEIdSignature = @"kMeIdSignature";

MobileEngageInternal *_mobileEngage;

SPEC_BEGIN(MobileEngageInternalTests)

        registerMatchers(@"EMS");

        __block MERequestContext *requestContext;

        beforeEach(^{
            [MEExperimental enableFeature:INAPP_MESSAGING];
            _mobileEngage = [MobileEngageInternal new];
            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:kAppId
                                       applicationPassword:kAppSecret];
                [builder setExperimentalFeatures:@[INAPP_MESSAGING]];
            }];

            [[NSFileManager defaultManager] removeItemAtPath:DB_PATH
                                                       error:nil];
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
            [userDefaults setObject:nil forKey:kMEID];
            [userDefaults setObject:nil forKey:kMEID_SIGNATURE];
            [userDefaults setObject:nil forKey:kLastAppLoginPayload];
            [userDefaults synchronize];

            requestContext = [[MERequestContext alloc] initWithConfig:config];
            [_mobileEngage setupWithConfig:config
                             launchOptions:[NSDictionary new]
                  requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                   requestContext:[MERequestContext mock]]
                             logRepository:nil
                            requestContext:requestContext];

        });

        id (^requestManagerMock)(void) = ^id() {
            NSString *applicationCode = kAppId;
            NSString *applicationPassword = @"appSecret";
            NSDictionary *additionalHeaders = @{
                @"Content-Type": @"application/json",
                @"X-MOBILEENGAGE-SDK-VERSION": MOBILEENGAGE_SDK_VERSION,
                @"X-MOBILEENGAGE-SDK-MODE": @"debug"
            };
            id requestManager = [EMSRequestManager mock];

            [[requestManager should] receive:@selector(setAdditionalHeaders:)
                            withCountAtLeast:1
                                   arguments:additionalHeaders];

            MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:applicationCode
                                       applicationPassword:applicationPassword];
            }];

            requestContext = [[MERequestContext alloc] initWithConfig:config];
            [_mobileEngage setupWithRequestManager:requestManager
                                            config:config
                                     launchOptions:[NSDictionary new]
                                    requestContext:requestContext];
            return requestManager;
        };

        id (^requestModel)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
            return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:url];
                    [builder setMethod:HTTPMethodPOST];
                    [builder setPayload:payload];
                    [builder setHeaders:@{@"Authorization": [EMSAuthentication createBasicAuthWithUsername:kAppId
                                                                                                  password:@"appSecret"]}];
                }
                                  timestampProvider:requestContext.timestampProvider
                                       uuidProvider:requestContext.uuidProvider];
        };

        id (^requestModelV3)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
            return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                    [builder setUrl:url];
                    [builder setMethod:HTTPMethodPOST];
                    [builder setPayload:payload];
                    [builder setHeaders:@{@"X-ME-ID": kMEID,
                        @"X-ME-ID-SIGNATURE": kMEID_SIGNATURE,
                        @"X-ME-APPLICATIONCODE": kAppId}];
                }
                                  timestampProvider:requestContext.timestampProvider
                                       uuidProvider:requestContext.uuidProvider];
        };

        describe(@"setupWithConfig:launchOptions:requestRepositoryFactory:logRepository:", ^{
            it(@"should setup the RequestManager with base64 auth header", ^{
                requestManagerMock();
            });

            beforeEach(^{
                [MEExperimental reset];
            });

            context(@"ResponseHandlers", ^{

                it(@"should register MEIDResponseHandler if INAPP is turned on", ^{
                    [MEExperimental enableFeature:INAPP_MESSAGING];
                    requestManagerMock();

                    BOOL registered = NO;
                    for (AbstractResponseHandler *responseHandler in _mobileEngage.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIdResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should register MEIDResponseHandler if USER_CENTRIC_INBOX is turned on", ^{
                    [MEExperimental enableFeature:USER_CENTRIC_INBOX];
                    requestManagerMock();

                    BOOL registered = NO;
                    for (AbstractResponseHandler *responseHandler in _mobileEngage.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIdResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should  register MEIDResponseHandler only once if USER_CENTRIC_INBOX and INAPP is turned on", ^{
                    [MEExperimental enableFeature:USER_CENTRIC_INBOX];
                    [MEExperimental enableFeature:INAPP_MESSAGING];
                    requestManagerMock();

                    NSUInteger registerCount = 0;
                    for (AbstractResponseHandler *responseHandler in _mobileEngage.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIdResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(1)];
                });

                it(@"should register MEIAMResponseHandler if INAPP is turned on", ^{
                    [MEExperimental enableFeature:INAPP_MESSAGING];
                    requestManagerMock();

                    BOOL registered = NO;
                    for (AbstractResponseHandler *responseHandler in _mobileEngage.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIAMResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should register MEIAMCleanupResponseHandler if INAPP is turned on", ^{
                    [MEExperimental enableFeature:INAPP_MESSAGING];
                    requestManagerMock();

                    BOOL registered = NO;
                    for (AbstractResponseHandler *responseHandler in _mobileEngage.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIAMCleanupResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });
            });

            it(@"should throw an exception when there is no requestRepositoryFactory", ^{
                @try {
                    MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                        [builder setCredentialsWithApplicationCode:kAppId
                                               applicationPassword:kAppSecret];
                        [builder setExperimentalFeatures:@[INAPP_MESSAGING]];
                    }];
                    MobileEngageInternal *internal = [MobileEngageInternal new];
                    [internal setupWithConfig:config
                                launchOptions:[NSDictionary new]
                     requestRepositoryFactory:nil
                                logRepository:nil
                               requestContext:requestContext];
                    fail(@"Expected Exception when requestRepositoryFactory is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: requestRepositoryFactory"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should call setupWithRequestManager:config:launchOptions: with MERequestRepositoryProxy when INAPP feature turned on", ^{
                [MEExperimental enableFeature:INAPP_MESSAGING];
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:kAppId
                                           applicationPassword:kAppSecret];
                }];
                MobileEngageInternal *internal = [MobileEngageInternal new];
                KWCaptureSpy *spy = [internal captureArgument:@selector(setupWithRequestManager:config:launchOptions:requestContext:)
                                                      atIndex:0];
                [internal setupWithConfig:config
                            launchOptions:[NSDictionary new]
                 requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                  requestContext:requestContext]
                            logRepository:nil
                           requestContext:requestContext];
                EMSRequestManager *manager = spy.argument;
                [[NSStringFromClass([manager.repository class]) should] equal:NSStringFromClass([MERequestRepositoryProxy class])];
            });

            it(@"should call setupWithRequestManager:config:launchOptions: with EMSRequestModelRepository when INAPP and INBOX is turned off", ^{
                [MEExperimental reset];
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:kAppId
                                           applicationPassword:kAppSecret];
                }];
                MobileEngageInternal *internal = [MobileEngageInternal new];
                KWCaptureSpy *spy = [internal captureArgument:@selector(setupWithRequestManager:config:launchOptions:requestContext:)
                                                      atIndex:0];
                [internal setupWithConfig:config
                            launchOptions:[NSDictionary new]
                 requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                  requestContext:requestContext]
                            logRepository:nil
                           requestContext:requestContext];
                EMSRequestManager *manager = spy.argument;
                [[NSStringFromClass([manager.repository class]) should] equal:NSStringFromClass([EMSRequestModelRepository class])];
            });

            it(@"should call setupWithRequestManager:config:launchOptions: with MERequestRepositoryProxy when INBOX feature turned on", ^{
                [MEExperimental enableFeature:USER_CENTRIC_INBOX];
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:kAppId
                                           applicationPassword:kAppSecret];
                }];
                MobileEngageInternal *internal = [MobileEngageInternal new];
                KWCaptureSpy *spy = [internal captureArgument:@selector(setupWithRequestManager:config:launchOptions:requestContext:)
                                                      atIndex:0];
                [internal setupWithConfig:config
                            launchOptions:[NSDictionary new]
                 requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                  requestContext:requestContext]
                            logRepository:nil
                           requestContext:requestContext];
                EMSRequestManager *manager = spy.argument;
                [[NSStringFromClass([manager.repository class]) should] equal:NSStringFromClass([MERequestRepositoryProxy class])];
            });

            it(@"should call setupWithRequestManager:config:launchOptions: with MERequestRepositoryProxy when INAPP and INBOX feature turned on", ^{
                [MEExperimental enableFeatures:@[INAPP_MESSAGING, USER_CENTRIC_INBOX]];
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:kAppId
                                           applicationPassword:kAppSecret];
                }];
                MobileEngageInternal *internal = [MobileEngageInternal new];
                KWCaptureSpy *spy = [internal captureArgument:@selector(setupWithRequestManager:config:launchOptions:requestContext:)
                                                      atIndex:0];
                [internal setupWithConfig:config
                            launchOptions:[NSDictionary new]
                 requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                  requestContext:requestContext]
                            logRepository:nil
                           requestContext:requestContext];
                EMSRequestManager *manager = spy.argument;
                [[NSStringFromClass([manager.repository class]) should] equal:NSStringFromClass([MERequestRepositoryProxy class])];
            });

        });

        describe(@"setPushToken:", ^{
            it(@"should call appLogin with lastAppLogin parameters", ^{
                NSData *deviceToken = [NSData new];
                [[_mobileEngage should] receive:@selector(appLoginWithContactFieldId:contactFieldValue:)
                                      withCount:1
                                      arguments:nil, nil, nil];

                _mobileEngage.requestContext.appLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:nil
                                                                                                   contactFieldValue:nil];
                [_mobileEngage setPushToken:deviceToken];
            });

            it(@"should call appLogin with lastAppLogin parameters when there are previous values", ^{
                NSData *deviceToken = [NSData new];
                [[_mobileEngage should] receive:@selector(appLoginWithContactFieldId:contactFieldValue:)
                                      withCount:1
                                      arguments:@12, @"23", nil];

                _mobileEngage.requestContext.appLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:@12
                                                                                                   contactFieldValue:@"23"];
                [_mobileEngage setPushToken:deviceToken];
            });

            it(@"appLogin should save last anonymous AppLogin parameters", ^{
                [[requestManagerMock() should] receive:@selector(submit:)];
                [_mobileEngage appLogin];
                [[_mobileEngage.requestContext.appLoginParameters shouldNot] beNil];
                [[_mobileEngage.requestContext.appLoginParameters.contactFieldId should] beNil];
                [[_mobileEngage.requestContext.appLoginParameters.contactFieldValue should] beNil];
            });

            it(@"appLogin should save last AppLogin parameters", ^{
                [[requestManagerMock() should] receive:@selector(submit:)];
                [_mobileEngage appLoginWithContactFieldId:@3 contactFieldValue:@"test@test.com"];
                [[_mobileEngage.requestContext.appLoginParameters shouldNot] beNil];
                [[_mobileEngage.requestContext.appLoginParameters.contactFieldId should] equal:@3];
                [[_mobileEngage.requestContext.appLoginParameters.contactFieldValue should] equal:@"test@test.com"];
            });

            it(@"should not call appLogin with setPushToken when there was no previous appLogin call", ^{
                NSData *deviceToken = [NSData new];
                [[_mobileEngage shouldNot] receive:@selector(appLoginWithContactFieldId:contactFieldValue:)];
                [_mobileEngage setPushToken:deviceToken];
            });
        });


        describe(@"anonymous appLogin", ^{
            it(@"must not return with nil", ^{
                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                NSString *uuid = [_mobileEngage appLogin];
                [[uuid shouldNot] beNil];
            });

            it(@"should return with requestModel's requestId", ^{
                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];
                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                NSString *uuid = [_mobileEngage appLogin];
                EMSRequestModel *actualModel = spy.argument;
                [[uuid should] equal:actualModel.requestId];
            });

            it(@"should submit a corresponding RequestModel", ^{
                id requestManager = requestManagerMock();
                EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
                });

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];
                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                [_mobileEngage appLogin];

                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });

            it(@"appLogin should save the MEID returned in the response", ^{
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:kAppId
                                           applicationPassword:kAppSecret];
                }];
                MobileEngageInternal *internal = [MobileEngageInternal new];
                [internal setupWithConfig:config
                            launchOptions:[NSDictionary new]
                 requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                  requestContext:requestContext]
                            logRepository:nil
                           requestContext:requestContext];

                FakeRequestManager *fakeRequestManager = [FakeRequestManager managerWithSuccessBlock:internal.successBlock
                                                                                          errorBlock:internal.errorBlock];
                internal.requestManager = fakeRequestManager;

                NSNumber *meId = @123456789;
                NSString *meIdSignature = @"signature";
                NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"api_me_id": meId, @"me_id_signature": meIdSignature}
                                                               options:0
                                                                 error:nil];
                EMSRequestModel *request = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setUrl:@"https://www.somethi.ng"];
                    }
                                                          timestampProvider:requestContext.timestampProvider
                                                               uuidProvider:requestContext.uuidProvider];
                fakeRequestManager.responseModels = [@[[[EMSResponseModel alloc] initWithStatusCode:200
                                                                                            headers:@{}
                                                                                               body:data
                                                                                       requestModel:request
                                                                                          timestamp:[NSDate date]]] mutableCopy];

                [internal appLogin];

                [fakeRequestManager waitForAllExpectations];

                [[internal.requestContext.meId should] equal:[meId stringValue]];
            });

        });

        describe(@"appLoginWithContactFieldId:contactFieldValue:", ^{
            it(@"must not return with nil", ^{
                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                NSString *uuid = [_mobileEngage appLoginWithContactFieldId:@3
                                                         contactFieldValue:@"test@test.com"];
                [[uuid shouldNot] beNil];
            });

            it(@"should return with requestModel's requestId", ^{
                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];
                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                NSString *uuid = [_mobileEngage appLoginWithContactFieldId:@3
                                                         contactFieldValue:@"test@test.com"];
                EMSRequestModel *actualModel = spy.argument;
                [[uuid should] equal:actualModel.requestId];
            });

            it(@"should submit a corresponding RequestModel", ^{
                id requestManager = requestManagerMock();
                EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"contact_field_id": @3,
                    @"contact_field_value": @"test@test.com",
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
                });

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];
                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                [_mobileEngage appLoginWithContactFieldId:@3
                                        contactFieldValue:@"test@test.com"];
                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });
        });

        describe(@"multiple applogin calls", ^{

            it(@"should not result in multiple applogin requests even if the payload is the same", ^{
                FakeRequestManager *requestManager = [FakeRequestManager new];
                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                }];

                [_mobileEngage setupWithRequestManager:requestManager
                                                config:config
                                         launchOptions:[NSDictionary new]
                                        requestContext:[[MERequestContext alloc] initWithConfig:config]];
                [MEExperimental reset];

                EMSRequestModel *firstModel = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"contact_field_id": @3,
                    @"contact_field_value": @"test@test.com",
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
                });


                EMSRequestModel *secondModel = requestModel([NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/ems_lastMobileActivity"], @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"contact_field_id": @3,
                    @"contact_field_value": @"test@test.com"
                });

                [_mobileEngage appLoginWithContactFieldId:@3
                                        contactFieldValue:@"test@test.com"];
                [_mobileEngage appLoginWithContactFieldId:@3
                                        contactFieldValue:@"test@test.com"];

                [[requestManager.submittedModels[0] should] beSimilarWithRequest:firstModel];
                [[requestManager.submittedModels[1] should] beSimilarWithRequest:secondModel];
            });

            it(@"should result in multiple applogin requests if the payload is not the same", ^{
                FakeRequestManager *requestManager = [FakeRequestManager new];
                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                }];

                [_mobileEngage setupWithRequestManager:requestManager
                                                config:config
                                         launchOptions:[NSDictionary new]
                                        requestContext:[[MERequestContext alloc] initWithConfig:config]];
                [MEExperimental reset];

                EMSRequestModel *firstModel = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"contact_field_id": @4,
                    @"contact_field_value": @"nottest@test.com",
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
                });


                EMSRequestModel *secondModel = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"contact_field_id": @3,
                    @"contact_field_value": @"test@test.com",
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
                });


                [_mobileEngage appLoginWithContactFieldId:@4
                                        contactFieldValue:@"nottest@test.com"];
                [_mobileEngage appLoginWithContactFieldId:@3
                                        contactFieldValue:@"test@test.com"];

                [[requestManager.submittedModels[0] should] beSimilarWithRequest:firstModel];
                [[requestManager.submittedModels[1] should] beSimilarWithRequest:secondModel];
            });

            it(@"should result in multiple applogin requests if the payload is the same size", ^{
                FakeRequestManager *requestManager = [FakeRequestManager new];
                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                }];

                [_mobileEngage setupWithRequestManager:requestManager
                                                config:config
                                         launchOptions:[NSDictionary new]
                                        requestContext:[[MERequestContext alloc] initWithConfig:config]];
                [MEExperimental reset];

                EMSRequestModel *firstModel = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"contact_field_id": @3,
                    @"contact_field_value": @"test@test.com",
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
                });


                EMSRequestModel *secondModel = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"contact_field_id": @4,
                    @"contact_field_value": @"nottest@test.com",
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
                });


                [_mobileEngage appLoginWithContactFieldId:@3
                                        contactFieldValue:@"test@test.com"];
                [_mobileEngage appLoginWithContactFieldId:@4
                                        contactFieldValue:@"nottest@test.com"];

                [[requestManager.submittedModels[0] should] beSimilarWithRequest:firstModel];
                [[requestManager.submittedModels[1] should] beSimilarWithRequest:secondModel];
            });

            it(@"should not result in multiple applogin requests if the payload is the same, even if MobileEngage is re-initialized", ^{
                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                }];

                FakeRequestManager *requestManager = [FakeRequestManager new];
                [_mobileEngage setupWithRequestManager:requestManager
                                                config:config
                                         launchOptions:[NSDictionary new]
                                        requestContext:[[MERequestContext alloc] initWithConfig:config]];
                [MEExperimental reset];

                EMSRequestModel *firstModel = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login", @{
                    @"application_id": kAppId,
                    @"platform": @"ios",
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"language": [EMSDeviceInfo languageCode],
                    @"timezone": [EMSDeviceInfo timeZone],
                    @"device_model": [EMSDeviceInfo deviceModel],
                    @"os_version": [EMSDeviceInfo osVersion],
                    @"contact_field_id": @3,
                    @"contact_field_value": @"test@test.com",
                    @"push_token": @NO,
                    @"application_version": @"1.0",
                    @"ems_sdk": MOBILEENGAGE_SDK_VERSION
                });


                EMSRequestModel *secondModel = requestModel([NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/ems_lastMobileActivity"], @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"contact_field_id": @3,
                    @"contact_field_value": @"test@test.com"
                });


                [_mobileEngage appLoginWithContactFieldId:@3
                                        contactFieldValue:@"test@test.com"];

                _mobileEngage = [MobileEngageInternal new];
                [_mobileEngage setupWithRequestManager:requestManager
                                                config:config
                                         launchOptions:[NSDictionary new]
                                        requestContext:[[MERequestContext alloc] initWithConfig:config]];

                [_mobileEngage appLoginWithContactFieldId:@3
                                        contactFieldValue:@"test@test.com"];

                [[requestManager.submittedModels[0] should] beSimilarWithRequest:firstModel];
                [[requestManager.submittedModels[1] should] beSimilarWithRequest:secondModel];
            });
        });

        describe(@"applogout", ^{
            it(@"must not return with nil", ^{
                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];
                NSString *uuid = [_mobileEngage appLogout];
                [[uuid shouldNot] beNil];
            });

            it(@"should return with requestModel's requestId", ^{
                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];
                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                NSString *uuid = [_mobileEngage appLogout];

                EMSRequestModel *actualModel = spy.argument;
                [[uuid should] equal:actualModel.requestId];
            });

            it(@"should submit a corresponding RequestModel if there is no saved applogin parameters", ^{
                id requestManager = requestManagerMock();
                EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/logout", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                });

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];
                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                [_mobileEngage appLogout];

                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });

            it(@"should submit a corresponding RequestModel if there is saved applogin parameters", ^{
                id requestManager = requestManagerMock();
                EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/users/logout", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"contact_field_id": @3,
                    @"contact_field_value": @"test@test.com"
                });

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];
                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];

                [_mobileEngage.requestContext setAppLoginParameters:[MEAppLoginParameters parametersWithContactFieldId:@3
                                                                                                     contactFieldValue:@"test@test.com"]];
                [_mobileEngage appLogout];

                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });

            it(@"should clear appLoginParameters", ^{
                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:)];

                [_mobileEngage.requestContext setAppLoginParameters:[MEAppLoginParameters parametersWithContactFieldId:@3
                                                                                                     contactFieldValue:@"test@test.com"]];
                [_mobileEngage appLogout];
                [[_mobileEngage.requestContext.appLoginParameters should] beNil];
            });

            it(@"should clear lastAppLoginPayload", ^{
                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:)];

                [_mobileEngage.requestContext setLastAppLoginPayload:@{@"t": @"v"}];
                [_mobileEngage appLogout];
                [[_mobileEngage.requestContext.lastAppLoginPayload should] beNil];
            });

        });

        describe(@"trackMessageOpenWithUserInfo:", ^{
            context(@"device centric inbox", ^{

                beforeEach(^{
                    [MEExperimental reset];
                });

                it(@"must not return with nil", ^{
                    id requestManager = requestManagerMock();
                    [[requestManager should] receive:@selector(submit:)
                                       withArguments:kw_any(), kw_any(), kw_any()];
                    NSString *uuid = [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];
                    [[uuid shouldNot] beNil];
                });

                it(@"should return with requestModel's requestId", ^{
                    id requestManager = requestManagerMock();
                    [[requestManager should] receive:@selector(submit:)
                                       withArguments:kw_any(), kw_any(), kw_any()];
                    KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                                atIndex:0];
                    NSString *uuid = [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];

                    EMSRequestModel *actualModel = spy.argument;
                    [[uuid should] equal:actualModel.requestId];
                });


                it(@"should submit a corresponding RequestModel when there is no contact_field_id and contact_field_value", ^{
                    id requestManager = requestManagerMock();

                    EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                        @"application_id": kAppId,
                        @"hardware_id": [EMSDeviceInfo hardwareId],
                        @"sid": @"123456789"
                    });

                    [[requestManager should] receive:@selector(submit:)
                                       withArguments:kw_any(), kw_any(), kw_any()];

                    KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                                atIndex:0];
                    [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];

                    EMSRequestModel *actualModel = spy.argument;
                    [[model should] beSimilarWithRequest:actualModel];
                });

                it(@"should submit a corresponding RequestModel when there are contact_field_id and contact_field_value", ^{
                    id requestManager = requestManagerMock();
                    MEAppLoginParameters *appLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:@3
                                                                                                contactFieldValue:@"test@test.com"];

                    [_mobileEngage.requestContext stub:@selector(appLoginParameters)
                                             andReturn:appLoginParameters];

                    EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                        @"application_id": kAppId,
                        @"hardware_id": [EMSDeviceInfo hardwareId],
                        @"contact_field_id": @3,
                        @"contact_field_value": @"test@test.com",
                        @"sid": @"123456789"
                    });

                    [[requestManager should] receive:@selector(submit:)
                                       withArguments:kw_any(), kw_any(), kw_any()];

                    KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                                atIndex:0];
                    [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @"{\"sid\":\"123456789\"}"}];

                    EMSRequestModel *actualModel = spy.argument;
                    [[model should] beSimilarWithRequest:actualModel];
                });

                it(@"should return with requestModel's non-nil requestId reported in the error when there is no sid", ^{
                    FakeRequestManager *requestManager = [FakeRequestManager managerWithSuccessBlock:nil
                                                                                          errorBlock:nil];
                    _mobileEngage = [MobileEngageInternal new];

                    __block NSError *reportedError;
                    __block NSString *requestIdForReportedError;

                    _mobileEngage.errorBlock = ^(NSString *requestId, NSError *error) {
                        requestIdForReportedError = requestId;
                        reportedError = error;
                    };

                    MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                        [builder setCredentialsWithApplicationCode:kAppId
                                               applicationPassword:kAppSecret];
                    }];

                    requestContext = [[MERequestContext alloc] initWithConfig:config];
                    requestContext.timestampProvider = [EMSTimestampProvider new];
                    requestContext.meId = @"meId";
                    requestContext.meIdSignature = @"meIdSignature";

                    [_mobileEngage setupWithRequestManager:requestManager
                                                    config:config
                                             launchOptions:[NSDictionary new]
                                            requestContext:requestContext];

                    NSString *uuid = [_mobileEngage trackMessageOpenWithUserInfo:@{@"u": @{}}];

                    EMSRequestModel *actualModel = [requestManager.submittedModels firstObject];
                    [[uuid shouldNot] beNil];
                    [[uuid should] equal:requestIdForReportedError];
                });
            });

            context(@"user centric inbox", ^{

                __block FakeRequestManager *requestManager;
                __block NSError *reportedError;
                __block NSString *requestIdForReportedError;

                beforeEach(^{
                    [MEExperimental enableFeature:USER_CENTRIC_INBOX];

                    requestManager = [FakeRequestManager managerWithSuccessBlock:nil errorBlock:nil];
                    _mobileEngage = [MobileEngageInternal new];

                    _mobileEngage.errorBlock = ^(NSString *requestId, NSError *error) {
                        requestIdForReportedError = requestId;
                        reportedError = error;
                    };

                    MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                        [builder setCredentialsWithApplicationCode:kAppId
                                               applicationPassword:kAppSecret];
                    }];

                    requestContext = [[MERequestContext alloc] initWithConfig:config];
                    requestContext.timestampProvider = [EMSTimestampProvider new];
                    requestContext.meId = @"meId";
                    requestContext.meIdSignature = @"meIdSignature";

                    [_mobileEngage setupWithRequestManager:requestManager
                                                    config:config
                                             launchOptions:[NSDictionary new]
                                            requestContext:requestContext];
                });

                afterEach(^{
                    [MEExperimental reset];
                });

                it(@"must not return with nil", ^{
                    MENotification *message = [MENotification new];
                    message.sid = @"sid";
                    message.id = @"messageId";

                    NSString *uuid = [_mobileEngage trackMessageOpenWithInboxMessage:message];
                    [[uuid shouldNot] beNil];
                });

                it(@"should return with requestModel's non-nil requestId reported in the error when there is no messageId", ^{
                    MENotification *message = [MENotification new];
                    message.sid = @"sid";

                    NSString *uuid = [_mobileEngage trackMessageOpenWithInboxMessage:message];

                    EMSRequestModel *actualModel = [requestManager.submittedModels firstObject];
                    [[uuid shouldNot] beNil];
                    [[uuid should] equal:requestIdForReportedError];
                });

                it(@"should return with requestModel's non-nil requestId reported in the error when there is no sid", ^{
                    MENotification *message = [MENotification new];
                    message.id = @"messageId";

                    NSString *uuid = [_mobileEngage trackMessageOpenWithInboxMessage:message];

                    EMSRequestModel *actualModel = [requestManager.submittedModels firstObject];
                    [[uuid shouldNot] beNil];
                    [[uuid should] equal:requestIdForReportedError];
                });

                it(@"should return an error on errorhandler instead of submitting an invalid request without messageId", ^{
                    MENotification *message = [MENotification new];
                    message.sid = @"testID";
                    message.title = @"title";
                    message.body = @"body";
                    message.customData = @{};
                    message.rootParams = @{};
                    message.expirationTime = @100;
                    message.receivedAtTimestamp = @50;

                    [_mobileEngage trackMessageOpenWithInboxMessage:message];

                    [[requestManager.submittedModels should] beEmpty];
                    [[reportedError.localizedDescription should] equal:@"Missing messageId"];
                });

                it(@"should return an error on errorhandler instead of submitting an invalid request without sid", ^{
                    MENotification *message = [MENotification new];
                    message.id = @"testID";
                    message.title = @"title";
                    message.body = @"body";
                    message.customData = @{};
                    message.rootParams = @{};
                    message.expirationTime = @100;
                    message.receivedAtTimestamp = @50;

                    [_mobileEngage trackMessageOpenWithInboxMessage:message];

                    [[requestManager.submittedModels should] beEmpty];
                    [[reportedError.localizedDescription should] equal:@"Missing sid"];
                });
            });
        });

        describe(@"trackMessageOpenWithInboxMessage:", ^{
            it(@"should throw exception when parameter is nil", ^{
                @try {
                    [_mobileEngage trackMessageOpenWithInboxMessage:nil];
                    fail(@"Expected Exception when inboxMessage is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit a corresponding RequestModel when there is no contact_field_id and contact_field_value", ^{
                id requestManager = requestManagerMock();

                EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"sid": @"testID",
                    @"source": @"inbox"
                });

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                MENotification *message = [MENotification new];
                message.sid = @"testID";
                [_mobileEngage trackMessageOpenWithInboxMessage:message];

                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });

            it(@"should submit a corresponding RequestModel when there are contact_field_id and contact_field_value", ^{
                id requestManager = requestManagerMock();

                MEAppLoginParameters *appLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:@3
                                                                                            contactFieldValue:@"contactFieldValue"];

                [_mobileEngage.requestContext stub:@selector(appLoginParameters)
                                         andReturn:appLoginParameters];

                EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"sid": @"valueOfSid",
                    @"contact_field_id": @3,
                    @"contact_field_value": @"contactFieldValue",
                    @"source": @"inbox"
                });

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                MENotification *message = [MENotification new];
                message.sid = @"valueOfSid";
                [_mobileEngage trackMessageOpenWithInboxMessage:message];

                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });

            it(@"should submit a corresponding RequestModel", ^{
                id requestManager = requestManagerMock();

                EMSRequestModel *model = requestModel(@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open", @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"sid": @"valueOfSid",
                    @"source": @"inbox"
                });

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                MENotification *message = [MENotification new];
                message.sid = @"valueOfSid";
                [_mobileEngage trackMessageOpenWithInboxMessage:message];

                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });

            it(@"should return with the requestModel's requestID", ^{
                id requestManager = requestManagerMock();

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                MENotification *message = [MENotification new];
                message.sid = @"valueOfSid";
                NSString *requestID = [_mobileEngage trackMessageOpenWithInboxMessage:message];

                EMSRequestModel *actualModel = spy.argument;
                [[requestID should] equal:actualModel.requestId];
            });

            it(@"must not return with nil", ^{
                id requestManager = requestManagerMock();
                MENotification *message = [MENotification new];
                message.sid = @"testID";
                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                NSString *uuid = [_mobileEngage trackMessageOpenWithInboxMessage:message];

                [[uuid shouldNot] beNil];
            });
        });

        describe(@"trackCustomEvent:eventAttributes:", ^{
            it(@"must not return with nil", ^{
                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];
                _mobileEngage.requestContext.meId = kMEID;
                _mobileEngage.requestContext.meIdSignature = kMEID_SIGNATURE;
                NSString *uuid = [_mobileEngage trackCustomEvent:@""
                                                 eventAttributes:@{}];
                [[uuid shouldNot] beNil];
            });

            it(@"should return with requestModel's requestId", ^{
                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];
                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                _mobileEngage.requestContext.meId = kMEID;
                _mobileEngage.requestContext.meIdSignature = kMEID_SIGNATURE;
                NSString *uuid = [_mobileEngage trackCustomEvent:@""
                                                 eventAttributes:@{}];

                EMSRequestModel *actualModel = spy.argument;
                [[uuid should] equal:actualModel.requestId];
            });

            it(@"should throw exception when eventName is nil", ^{
                @try {
                    [_mobileEngage trackCustomEvent:nil
                                    eventAttributes:@{}];
                    fail(@"Expected Exception when eventName is nil!");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit a corresponding RequestModel, when eventAttributes are set", ^{
                id requestManager = requestManagerMock();

                id timeStampProviderMock = [EMSTimestampProvider mock];
                NSDate *timestamp = [NSDate date];
                [[timeStampProviderMock should] receive:@selector(provideTimestamp)
                                              andReturn:timestamp
                                       withCountAtLeast:0];
                _mobileEngage.requestContext.timestampProvider = timeStampProviderMock;

                _mobileEngage.requestContext.meId = kMEID;
                _mobileEngage.requestContext.meIdSignature = kMEID_SIGNATURE;
                NSString *eventName = @"testEventName";
                NSDictionary *eventAttributes = @{@"someKey": @"someValue"};

                NSDictionary *payload = @{
                    @"clicks": @[],
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"viewed_messages": @[],
                    @"events": @[
                        @{
                            @"type": @"custom",
                            @"name": eventName,
                            @"attributes": eventAttributes,
                            @"timestamp": [timestamp stringValueInUTC]
                        }
                    ]
                };

                EMSRequestModel *model = requestModelV3([NSString stringWithFormat:@"https://mobile-events.eservice.emarsys.net/v3/devices/%@/events", kMEID], payload);

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];

                [_mobileEngage trackCustomEvent:eventName
                                eventAttributes:eventAttributes];
                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });

            it(@"should submit a corresponding RequestModel, when eventAttributes are missing", ^{
                id requestManager = requestManagerMock();

                id timeStampProviderMock = [EMSTimestampProvider mock];
                NSDate *timeStamp = [NSDate date];
                [[timeStampProviderMock should] receive:@selector(provideTimestamp)
                                              andReturn:timeStamp
                                       withCountAtLeast:0];
                _mobileEngage.requestContext.timestampProvider = timeStampProviderMock;

                _mobileEngage.requestContext.meId = kMEID;
                _mobileEngage.requestContext.meIdSignature = kMEID_SIGNATURE;
                NSString *eventName = @"testEventName";

                NSDictionary *payload = @{
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"clicks": @[],
                    @"viewed_messages": @[],
                    @"events": @[
                        @{
                            @"type": @"custom",
                            @"name": eventName,
                            @"timestamp": [timeStamp stringValueInUTC]
                        }
                    ]
                };

                EMSRequestModel *model = requestModelV3([NSString stringWithFormat:@"https://mobile-events.eservice.emarsys.net/v3/devices/%@/events", kMEID], payload);

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];

                [_mobileEngage trackCustomEvent:eventName
                                eventAttributes:nil];
                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });


            it(@"should submit a corresponding RequestModel, when eventAttributes are set and there is no saved contactFieldId and contactFieldValue", ^{
                [MEExperimental reset];

                id requestManager = requestManagerMock();

                NSString *eventName = @"testEventName";
                NSDictionary *eventAttributes = @{@"someKey": @"someValue"};

                NSDictionary *payload = @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"attributes": eventAttributes
                };

                EMSRequestModel *model = requestModel([NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/%@", eventName], payload);

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                [_mobileEngage trackCustomEvent:eventName
                                eventAttributes:eventAttributes];
                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });

            it(@"should submit a corresponding RequestModel, when eventAttributes are set and there are saved contactFieldId and contactFieldValue", ^{
                [MEExperimental reset];

                id requestManager = requestManagerMock();

                MEAppLoginParameters *appLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:@3
                                                                                            contactFieldValue:@"test@test.com"];

                [_mobileEngage.requestContext stub:@selector(appLoginParameters)
                                         andReturn:appLoginParameters];

                NSString *eventName = @"testEventName";
                NSDictionary *eventAttributes = @{@"someKey": @"someValue"};

                NSDictionary *payload = @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"attributes": eventAttributes,
                    @"contact_field_id": @3,
                    @"contact_field_value": @"test@test.com"
                };

                EMSRequestModel *model = requestModel([NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/%@",
                                                                                 eventName], payload);

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                [_mobileEngage trackCustomEvent:eventName
                                eventAttributes:eventAttributes];
                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });


            it(@"should submit a corresponding RequestModel, when eventAttributes are missing and there is no saved contactFieldId and contactFieldValue", ^{
                [MEExperimental reset];

                id requestManager = requestManagerMock();

                NSString *eventName = @"testEventName";

                NSDictionary *payload = @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                };

                EMSRequestModel *model = requestModel([NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/%@",
                                                                                 eventName], payload);

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                [_mobileEngage trackCustomEvent:eventName
                                eventAttributes:nil];
                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });


            it(@"should submit a corresponding RequestModel, when eventAttributes are missing and there are saved contactFieldId and contactFieldValue", ^{
                [MEExperimental reset];

                id requestManager = requestManagerMock();

                MEAppLoginParameters *appLoginParameters = [MEAppLoginParameters parametersWithContactFieldId:@3
                                                                                            contactFieldValue:@"test@test.com"];

                [_mobileEngage.requestContext stub:@selector(appLoginParameters)
                                         andReturn:appLoginParameters];

                NSString *eventName = @"testEventName";

                NSDictionary *payload = @{
                    @"application_id": kAppId,
                    @"hardware_id": [EMSDeviceInfo hardwareId],
                    @"contact_field_id": @3,
                    @"contact_field_value": @"test@test.com"
                };

                EMSRequestModel *model = requestModel([NSString stringWithFormat:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/%@",
                                                                                 eventName], payload);

                [[requestManager should] receive:@selector(submit:)
                                   withArguments:kw_any(), kw_any(), kw_any()];

                KWCaptureSpy *spy = [requestManager captureArgument:@selector(submit:)
                                                            atIndex:0];
                [_mobileEngage trackCustomEvent:eventName
                                eventAttributes:nil];
                EMSRequestModel *actualModel = spy.argument;
                [[model should] beSimilarWithRequest:actualModel];
            });


        });


        describe(@"appStart", ^{

            beforeEach(^{
                _mobileEngage = [MobileEngageInternal new];
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:kAppId
                                           applicationPassword:kAppSecret];
                    [builder setExperimentalFeatures:@[INAPP_MESSAGING]];
                }];
                [_mobileEngage setupWithConfig:config
                                 launchOptions:[NSDictionary new]
                      requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                       requestContext:requestContext]
                                 logRepository:nil
                                requestContext:requestContext];

                _mobileEngage.requestContext.meId = kMEID;
                _mobileEngage.requestContext.meIdSignature = kMEID_SIGNATURE;

            });

            it(@"should register UIApplicationDidBecomeActiveNotification", ^{
                id notificationCenterManagerMock = [MENotificationCenterManager mock];
                [_mobileEngage setNotificationCenterManager:notificationCenterManagerMock];

                [[notificationCenterManagerMock should] receive:@selector(addHandlerBlock:forNotification:)
                                                  withArguments:kw_any(),
                                                                UIApplicationDidBecomeActiveNotification];
                requestManagerMock();
            });

            it(@"should submit appstart event on UIApplicationDidBecomeActiveNotification", ^{
                id notificationCenterManagerMock = [MENotificationCenterManager mock];
                [_mobileEngage setNotificationCenterManager:notificationCenterManagerMock];
                [_mobileEngage.requestContext setMeId:@"testMeId"];
                [_mobileEngage.requestContext setMeIdSignature:@"testMeIdSig"];

                [[notificationCenterManagerMock should] receive:@selector(addHandlerBlock:forNotification:)
                                                  withArguments:kw_any(),
                                                                UIApplicationDidBecomeActiveNotification];
                KWCaptureSpy *spy = [notificationCenterManagerMock captureArgument:@selector(addHandlerBlock:forNotification:)
                                                                           atIndex:0];

                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:) withCountAtLeast:1];
                KWCaptureSpy *submitSpy = [requestManager captureArgument:@selector(submit:) atIndex:0];
                MEHandlerBlock block = spy.argument;
                block();


                EMSRequestModel *result = submitSpy.argument;
                [[[result.url absoluteString] should] equal:@"https://mobile-events.eservice.emarsys.net/v3/devices/testMeId/events"];
                [[result.payload[@"events"][0][@"type"] should] equal:@"internal"];
                [[result.payload[@"events"][0][@"name"] should] equal:@"app:start"];
            });

            it(@"should submit inapp:viewed event when trackInAppDisplay: called", ^{
                [_mobileEngage.requestContext setMeId:@"testMeId"];
                [_mobileEngage.requestContext setMeIdSignature:@"testMeIdSig"];

                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:) withCountAtLeast:1];
                KWCaptureSpy *submitSpy = [requestManager captureArgument:@selector(submit:) atIndex:0];

                [_mobileEngage trackInAppDisplay:@"testCampaignId"];

                EMSRequestModel *result = submitSpy.argument;
                [[[result.url absoluteString] should] equal:@"https://mobile-events.eservice.emarsys.net/v3/devices/testMeId/events"];
                [[result.payload[@"events"][0][@"type"] should] equal:@"internal"];
                [[result.payload[@"events"][0][@"name"] should] equal:@"inapp:viewed"];
                [[result.payload[@"events"][0][@"attributes"][@"message_id"] should] equal:@"testCampaignId"];
            });

            it(@"should submit inapp:viewed event when trackInAppClick: called", ^{
                [_mobileEngage.requestContext setMeId:@"testMeId"];
                [_mobileEngage.requestContext setMeIdSignature:@"testMeIdSig"];

                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:) withCountAtLeast:1];
                KWCaptureSpy *submitSpy = [requestManager captureArgument:@selector(submit:) atIndex:0];

                [_mobileEngage trackInAppClick:@"testCampaignId" buttonId:@"123"];

                EMSRequestModel *result = submitSpy.argument;
                [[[result.url absoluteString] should] equal:@"https://mobile-events.eservice.emarsys.net/v3/devices/testMeId/events"];
                [[result.payload[@"events"][0][@"type"] should] equal:@"internal"];
                [[result.payload[@"events"][0][@"name"] should] equal:@"inapp:click"];
                [[result.payload[@"events"][0][@"attributes"][@"message_id"] should] equal:@"testCampaignId"];
                [[result.payload[@"events"][0][@"attributes"][@"button_id"] should] equal:@"123"];
            });

            it(@"should not call submit on RequestManager when there is no meid (no login)", ^{
                id notificationCenterManagerMock = [MENotificationCenterManager mock];
                [_mobileEngage setNotificationCenterManager:notificationCenterManagerMock];
                [_mobileEngage.requestContext setMeId:nil];

                [[notificationCenterManagerMock should] receive:@selector(addHandlerBlock:forNotification:)
                                                  withArguments:kw_any(),
                                                                UIApplicationDidBecomeActiveNotification];
                KWCaptureSpy *spy = [notificationCenterManagerMock captureArgument:@selector(addHandlerBlock:forNotification:)
                                                                           atIndex:0];

                id requestManager = requestManagerMock();
                [[requestManager shouldNot] receive:@selector(submit:)];
                MEHandlerBlock block = spy.argument;
                block();
            });

        });

        describe(@"trackInternalCustomEvent:eventAttributes:", ^{

            it(@"should throw exception when eventName is nil", ^{
                @try {
                    [_mobileEngage trackInternalCustomEvent:nil
                                            eventAttributes:@{}];
                    fail(@"Expected Exception when eventName is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: eventName"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should submit requestModel with defined name and eventAttributes where type is 'internal'", ^{
                [_mobileEngage.requestContext setMeId:@"testMeId"];
                [_mobileEngage.requestContext setMeIdSignature:@"testMeIdSig"];

                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:) withCountAtLeast:1];
                KWCaptureSpy *submitSpy = [requestManager captureArgument:@selector(submit:) atIndex:0];

                [_mobileEngage trackInternalCustomEvent:@"richNotification:clicked"
                                        eventAttributes:@{
                                            @"button_id": @"ASDF-QWERT-ASDF-QWERT",
                                            @"title": @"TitleOfTheButton"
                                        }];

                EMSRequestModel *result = submitSpy.argument;
                [[[result.url absoluteString] should] equal:@"https://mobile-events.eservice.emarsys.net/v3/devices/testMeId/events"];
                [[result.payload[@"events"][0][@"type"] should] equal:@"internal"];
                [[result.payload[@"events"][0][@"name"] should] equal:@"richNotification:clicked"];
                [[result.payload[@"events"][0][@"attributes"][@"button_id"] should] equal:@"ASDF-QWERT-ASDF-QWERT"];
                [[result.payload[@"events"][0][@"attributes"][@"title"] should] equal:@"TitleOfTheButton"];
            });
        });

        describe(@"meID", ^{

            beforeEach(^{
                _mobileEngage = [MobileEngageInternal new];
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:kAppId
                                           applicationPassword:kAppSecret];
                    [builder setExperimentalFeatures:@[INAPP_MESSAGING]];
                }];
                [_mobileEngage setupWithConfig:config
                                 launchOptions:[NSDictionary new]
                      requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                       requestContext:requestContext]
                                 logRepository:nil
                                requestContext:requestContext];

                _mobileEngage.requestContext.meId = kMEID;
                _mobileEngage.requestContext.meIdSignature = kMEID_SIGNATURE;

            });

            it(@"should store the meID in userDefaults when the setter invoked", ^{
                NSString *meID = @"meIDValue";

                [_mobileEngage.requestContext setMeId:meID];

                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
                NSString *returnedValue = [userDefaults stringForKey:kMEID];

                [[returnedValue should] equal:meID];
            });

            it(@"should load the stored value when setup called on MobileEngageInternal", ^{
                NSString *meID = @"StoredValueOfMobileEngageId";

                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                }];

                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
                [userDefaults setObject:meID
                                 forKey:kMEID];
                [userDefaults synchronize];

                [_mobileEngage setupWithConfig:config
                                 launchOptions:[NSDictionary new]
                      requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                       requestContext:requestContext]
                                 logRepository:nil
                                requestContext:[[MERequestContext alloc] initWithConfig:config]];

                [[_mobileEngage.requestContext.meId should] equal:meID];
            });

            it(@"should be cleared from userdefaults on logout", ^{
                NSString *meID = @"NotNil";

                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                }];
                [_mobileEngage setupWithConfig:config
                                 launchOptions:[NSDictionary new]
                      requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                       requestContext:requestContext]
                                 logRepository:nil
                                requestContext:requestContext];

                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
                [userDefaults setObject:meID
                                 forKey:kMEID];
                [userDefaults synchronize];

                [_mobileEngage appLogout];

                [[_mobileEngage.requestContext.meId should] beNil];
            });

        });

        describe(@"meIdSignature", ^{

            beforeEach(^{
                _mobileEngage = [MobileEngageInternal new];
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:kAppId
                                           applicationPassword:kAppSecret];
                    [builder setExperimentalFeatures:@[INAPP_MESSAGING]];
                }];
                [_mobileEngage setupWithConfig:config
                                 launchOptions:[NSDictionary new]
                      requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                       requestContext:requestContext]
                                 logRepository:nil
                                requestContext:requestContext];

                _mobileEngage.requestContext.meId = kMEID;
                _mobileEngage.requestContext.meIdSignature = kMEID_SIGNATURE;

            });

            it(@"should store the meIDSignature in userDefaults when the setter invoked", ^{
                NSString *meIDSignature = @"meIDSignatureValue";

                [_mobileEngage.requestContext setMeIdSignature:meIDSignature];

                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
                NSString *returnedValue = [userDefaults stringForKey:kMEID_SIGNATURE];

                [[returnedValue should] equal:meIDSignature];
            });

            it(@"should load the stored value when setup called on MobileEngageInternal", ^{
                NSString *meIDSignature = @"signature";

                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                }];

                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
                [userDefaults setObject:meIDSignature
                                 forKey:kMEID_SIGNATURE];
                [userDefaults synchronize];

                [_mobileEngage setupWithConfig:config
                                 launchOptions:[NSDictionary new]
                      requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                       requestContext:requestContext]
                                 logRepository:nil
                                requestContext:[[MERequestContext alloc] initWithConfig:config]];

                [[_mobileEngage.requestContext.meIdSignature should] equal:meIDSignature];
            });

            it(@"should be cleared from userdefaults on logout", ^{
                NSString *meIdSignature = @"NotNil";

                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                }];

                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
                [userDefaults setObject:meIdSignature
                                 forKey:kMEID_SIGNATURE];
                [userDefaults synchronize];
                [_mobileEngage setupWithConfig:config
                                 launchOptions:[NSDictionary new]
                      requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                       requestContext:requestContext]
                                 logRepository:nil
                                requestContext:requestContext];


                [_mobileEngage appLogout];

                [[_mobileEngage.requestContext.meIdSignature should] beNil];
            });
        });

        describe(@"experimental", ^{
            it(@"should enable experimental features based on the features given in the config", ^{
                NSArray<MEFlipperFeature> *features = @[INAPP_MESSAGING];
                NSString *applicationCode = kAppId;
                NSString *applicationPassword = @"appSecret";
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:applicationCode
                                           applicationPassword:applicationPassword];
                    [builder setExperimentalFeatures:features];
                }];
                [_mobileEngage setupWithConfig:config
                                 launchOptions:[NSDictionary new]
                      requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                       requestContext:requestContext]
                                 logRepository:nil
                                requestContext:requestContext];

                for (MEFlipperFeature feature in features) {
                    [[theValue([MEExperimental isFeatureEnabled:feature]) should] beYes];
                }

            });
        });

        describe(@"trackDeepLinkWith:sourceHandler:", ^{
            it(@"should return true when the userActivity type is NSUserActivityTypeBrowsingWeb and webpageURL contains ems_dl query parameter when sourceHandler is exist", ^{
                NSUserActivity *userActivity = [NSUserActivity mock];
                [[userActivity should] receive:@selector(activityType)
                                     andReturn:[NSString stringWithFormat:@"%@", NSUserActivityTypeBrowsingWeb]];
                [[userActivity should] receive:@selector(webpageURL)
                                     andReturn:[[NSURL alloc] initWithString:@"http://www.google.com/something?fancy_url=1&ems_dl=1_2_3_4_5"]];

                BOOL returnValue = [_mobileEngage trackDeepLinkWith:userActivity
                                                      sourceHandler:nil];

                [[theValue(returnValue) should] beYes];
            });

            it(@"should return false when the userActivity type is not NSUserActivityTypeBrowsingWeb", ^{
                NSUserActivity *userActivity = [NSUserActivity mock];
                [[userActivity should] receive:@selector(activityType)
                                     andReturn:@"NotNSUserActivityTypeBrowsingWeb"];
                BOOL returnValue = [_mobileEngage trackDeepLinkWith:userActivity
                                                      sourceHandler:nil];

                [[theValue(returnValue) should] beNo];
            });

            it(@"should call sourceBlock with sourceUrl when its available", ^{
                NSString *source = @"http://www.google.com/something?fancy_url=1&ems_dl=1_2_3_4_5";

                NSUserActivity *userActivity = [NSUserActivity mock];
                [[userActivity should] receive:@selector(activityType)
                                     andReturn:NSUserActivityTypeBrowsingWeb];
                [[userActivity should] receive:@selector(webpageURL)
                                     andReturn:[[NSURL alloc] initWithString:source]];

                XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

                __block NSString *resultSource;
                [_mobileEngage trackDeepLinkWith:userActivity
                                   sourceHandler:^(NSString *source) {
                                       resultSource = source;
                                       [exp fulfill];
                                   }];
                [EMSWaiter waitForExpectations:@[exp]
                                       timeout:2];

                [[resultSource should] equal:source];
            });

            it(@"should submit deepLinkTracker requestModel into requestManager", ^{
                NSString *source = @"http://www.google.com/something?fancy_url=1&ems_dl=1_2_3_4_5";
                NSUserActivity *userActivity = [NSUserActivity mock];
                [[userActivity should] receive:@selector(activityType)
                                     andReturn:NSUserActivityTypeBrowsingWeb];
                [[userActivity should] receive:@selector(webpageURL)
                                     andReturn:[[NSURL alloc] initWithString:source]];
                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:) withCount:1];
                KWCaptureSpy *submitSpy = [requestManager captureArgument:@selector(submit:) atIndex:0];

                [_mobileEngage trackDeepLinkWith:userActivity
                                   sourceHandler:nil];

                EMSRequestModel *result = submitSpy.argument;
                [[[result.url absoluteString] should] equal:@"https://deep-link.eservice.emarsys.net/api/clicks"];
                [[result.payload[@"ems_dl"] should] equal:@"1_2_3_4_5"];
                [[result.method should] equal:@"POST"];
            });

            it(@"should submit deepLinkTracker requestModel into requestManager with empty string payload when ems_dl is not a queryItem", ^{
                NSString *source = @"http://www.google.com/something?fancy_url=1&ems_dl";
                NSUserActivity *userActivity = [NSUserActivity mock];
                [[userActivity should] receive:@selector(activityType)
                                     andReturn:NSUserActivityTypeBrowsingWeb];
                [[userActivity should] receive:@selector(webpageURL)
                                     andReturn:[[NSURL alloc] initWithString:source]];
                id requestManager = requestManagerMock();
                [[requestManager should] receive:@selector(submit:) withCount:1];
                KWCaptureSpy *submitSpy = [requestManager captureArgument:@selector(submit:) atIndex:0];

                [_mobileEngage trackDeepLinkWith:userActivity
                                   sourceHandler:nil];

                EMSRequestModel *result = submitSpy.argument;
                [[[result.url absoluteString] should] equal:@"https://deep-link.eservice.emarsys.net/api/clicks"];
                [[result.payload[@"ems_dl"] should] equal:@""];
                [[result.method should] equal:@"POST"];
            });
        });

        describe(@"requestContext", ^{
            it(@"should not be nil after setup", ^{
                _mobileEngage = [MobileEngageInternal new];
                MEConfig *config = [MEConfig makeWithBuilder:^(MEConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:kAppId
                                           applicationPassword:kAppSecret];
                    [builder setExperimentalFeatures:@[INAPP_MESSAGING]];
                }];
                [_mobileEngage setupWithConfig:config
                                 launchOptions:[NSDictionary new]
                      requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:[MEInApp mock]
                                                                                       requestContext:requestContext]
                                 logRepository:nil
                                requestContext:requestContext];
                [[_mobileEngage.requestContext shouldNot] beNil];
            });
        });

SPEC_END
