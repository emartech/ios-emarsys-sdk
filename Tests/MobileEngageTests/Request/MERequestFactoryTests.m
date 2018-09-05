#import "EMSDeviceInfo.h"
#import "EMSAuthentication.h"
#import "Kiwi.h"
#import "MERequestFactory.h"
#import "EMSRequestModel.h"
#import "MobileEngageVersion.h"
#import "EMSRequestModelMatcher.h"
#import "MERequestContext.h"
#import "EMSConfigBuilder.h"
#import "MEExperimental+Test.h"
#import "MENotification.h"
#import "NSDate+EMSCore.h"

typedef MERequestContext *(^RequestContextBlock)(NSDate *timeStamp);

SPEC_BEGIN(MERequestFactoryTests)

#define kLastMobileActivityURL @"https://push.eservice.emarsys.net/api/mobileengage/v2/events/ems_lastMobileActivity"
#define kAppLoginURL @"https://push.eservice.emarsys.net/api/mobileengage/v2/users/login"

        registerMatchers(@"EMS");

        afterAll(^{
            [MEExperimental reset];
        });

        RequestContextBlock requestContextBlock = ^MERequestContext *(NSDate *timeStamp) {
            EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                       applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                [builder setMerchantId:@"dummyMerchantId"];
                [builder setContactFieldId:@3];
            }];
            EMSTimestampProvider *timestampProvider = [EMSTimestampProvider mock];
            [timestampProvider stub:@selector(provideTimestamp) andReturn:timeStamp];
            MERequestContext *requestContext = [[MERequestContext alloc] initWithConfig:config];
            requestContext.meId = @"requestContextMeId";
            requestContext.meIdSignature = @"requestContextMeIdSignature";
            requestContext.timestampProvider = timestampProvider;
            return requestContext;
        };

        describe(@"createTrackDeepLinkRequestWithTrackingId:requestContext:", ^{
            it(@"should create a RequestModel with deepLinkValue", ^{

                MERequestContext *requestContext = requestContextBlock([NSDate date]);

                NSString *const value = @"dl_value";
                NSString *userAgent = [NSString stringWithFormat:@"Mobile Engage SDK %@ %@ %@", MOBILEENGAGE_SDK_VERSION, [EMSDeviceInfo deviceType], [EMSDeviceInfo osVersion]];
                EMSRequestModel *expected = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                        [builder setMethod:HTTPMethodPOST];
                        [builder setUrl:@"https://deep-link.eservice.emarsys.net/api/clicks"];
                        [builder setHeaders:@{@"User-Agent": userAgent}];
                        [builder setPayload:@{@"ems_dl": value}];
                    }
                                                           timestampProvider:requestContext.timestampProvider
                                                                uuidProvider:requestContext.uuidProvider];

                EMSRequestModel *result = [MERequestFactory createTrackDeepLinkRequestWithTrackingId:value
                                                                                      requestContext:requestContext];
                [[result should] beSimilarWithRequest:expected];
            });

        });

        describe(@"createLoginOrLastMobileActivityRequestWithPushToken:requestContext:", ^{

            __block EMSConfig *config;
            __block NSString *applicationCode;
            __block NSString *password;
            __block NSMutableDictionary *apploginPayload;
            __block NSNumber *contactFieldId;
            __block NSString *contactFieldValue;


            beforeEach(^{
                config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                    [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                           applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                    [builder setMerchantId:@"dummyMerchantId"];
                    [builder setContactFieldId:@3];
                }];
                applicationCode = @"14C19-A121F";
                password = @"PaNkfOD90AVpYimMBuZopCpm8OWCrREu";
                contactFieldId = @3;
                contactFieldValue = @"test@test.com";

                apploginPayload = [NSMutableDictionary new];
                apploginPayload[@"platform"] = @"ios";
                apploginPayload[@"language"] = [EMSDeviceInfo languageCode];
                apploginPayload[@"timezone"] = [EMSDeviceInfo timeZone];
                apploginPayload[@"device_model"] = [EMSDeviceInfo deviceModel];
                apploginPayload[@"os_version"] = [EMSDeviceInfo osVersion];
                apploginPayload[@"ems_sdk"] = MOBILEENGAGE_SDK_VERSION;
                apploginPayload[@"application_id"] = applicationCode;
                apploginPayload[@"hardware_id"] = [EMSDeviceInfo hardwareId];
                apploginPayload[@"contact_field_id"] = contactFieldId;
                apploginPayload[@"contact_field_value"] = contactFieldValue;

                NSString *appVersion = [EMSDeviceInfo applicationVersion];
                if (appVersion) {
                    apploginPayload[@"application_version"] = appVersion;
                }
                apploginPayload[@"push_token"] = @NO;
            });

            context(@"INAPP TURNED OFF", ^{

                beforeEach(^{
                    [MEExperimental reset];
                });

                it(@"should result in applogin request if there was no previous applogin", ^{
                    MERequestContext *requestContext = requestContextBlock([NSDate date]);
                    requestContext.config = config;
                    requestContext.appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:@3 contactFieldValue:@"test@test.com"];
                    requestContext.meId = nil;


                    EMSRequestModel *request = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:nil requestContext:requestContext];
                    [[[request.url absoluteString] should] equal:kAppLoginURL];
                });

                it(@"should result in lastMobileActivity request if there was previous applogin with same payload", ^{
                    MERequestContext *requestContext = requestContextBlock([NSDate date]);
                    requestContext.config = config;
                    requestContext.appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:contactFieldId contactFieldValue:contactFieldValue];
                    requestContext.meId = nil;

                    requestContext.lastAppLoginPayload = apploginPayload;

                    EMSRequestModel *request = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:nil requestContext:requestContext];
                    [[[request.url absoluteString] should] equal:kLastMobileActivityURL];
                });

                it(@"should result in applogin request if there was previous applogin with different payload", ^{
                    MERequestContext *requestContext = requestContextBlock([NSDate date]);
                    requestContext.config = config;
                    requestContext.appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:contactFieldId contactFieldValue:contactFieldValue];
                    requestContext.meId = nil;

                    apploginPayload[@"application_version"] = @"changed";
                    requestContext.lastAppLoginPayload = apploginPayload;

                    EMSRequestModel *request = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:nil requestContext:requestContext];
                    [[[request.url absoluteString] should] equal:kAppLoginURL];
                });
            });

            context(@"INAPP TURNED ON", ^{

                beforeEach(^{
                    config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setCredentialsWithApplicationCode:@"14C19-A121F"
                                               applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                        [builder setMerchantId:@"dummyMerchantId"];
                        [builder setContactFieldId:@3];
                    }];
                    [MEExperimental enableFeature:INAPP_MESSAGING];
                });

                it(@"should result in applogin request if there was previous applogin with same payload and there is no meid", ^{
                    MERequestContext *requestContext = requestContextBlock([NSDate date]);
                    requestContext.config = config;
                    requestContext.appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:contactFieldId contactFieldValue:contactFieldValue];
                    requestContext.lastAppLoginPayload = apploginPayload;
                    requestContext.meId = nil;

                    EMSRequestModel *request = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:nil requestContext:requestContext];
                    [[[request.url absoluteString] should] equal:kAppLoginURL];
                });

                it(@"should result in lastMobileActivity V3 request if there was previous applogin with same payload and there is an existing meid", ^{
                    NSDate *timeStamp = [NSDate date];
                    MERequestContext *requestContext = requestContextBlock(timeStamp);

                    requestContext.config = config;
                    requestContext.appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:contactFieldId contactFieldValue:contactFieldValue];
                    requestContext.meId = @"something";
                    requestContext.lastAppLoginPayload = apploginPayload;

                    EMSRequestModel *request = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:nil requestContext:requestContext];
                    [[[request.url absoluteString] should] equal:@"https://mobile-events.eservice.emarsys.net/v3/devices/something/events"];
                    [[request.payload[@"events"][0][@"name"] should] equal:@"last_mobile_activity"];
                });

                it(@"should result in applogin request if there was previous applogin with different payload and there is no meid", ^{
                    MERequestContext *requestContext = requestContextBlock([NSDate date]);
                    requestContext.config = config;
                    requestContext.appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:contactFieldId contactFieldValue:contactFieldValue];
                    requestContext.meId = nil;

                    apploginPayload[@"application_version"] = @"changed";
                    requestContext.lastAppLoginPayload = apploginPayload;

                    EMSRequestModel *request = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:nil requestContext:requestContext];
                    [[[request.url absoluteString] should] equal:kAppLoginURL];
                });

                it(@"should result in applogin request if there was previous applogin with different payload and there is an existing meid", ^{
                    MERequestContext *requestContext = requestContextBlock([NSDate date]);
                    requestContext.config = config;
                    requestContext.appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:contactFieldId contactFieldValue:contactFieldValue];
                    requestContext.meId = @"something";

                    apploginPayload[@"application_version"] = @"changed";
                    requestContext.lastAppLoginPayload = apploginPayload;

                    EMSRequestModel *request = [MERequestFactory createLoginOrLastMobileActivityRequestWithPushToken:nil requestContext:requestContext];
                    [[[request.url absoluteString] should] equal:kAppLoginURL];
                });
            });

        });

        describe(@"createTrackMessageOpenRequestWithNotification:requestContext:", ^{

            typedef MENotification *(^NotificationBlock)(void);

            NotificationBlock notificationBlock = ^MENotification * {
                MENotification *notification = [MENotification new];
                notification.id = @"notificationId";
                notification.sid = @"notificationSid";
                notification.title = @"notificationTitle";
                notification.body = @"notificationBody";
                notification.customData = @{@"notificationCustomDataKey": @"notificationCustomDataValue"};
                notification.rootParams = @{
                    @"notificationRootParamsKey1": @{@"subKey1": @"subValue1"},
                    @"notificationRootParamsKey2": @"notificationRootParamsValue2"
                };
                notification.expirationTime = @7200;
                notification.receivedAtTimestamp = @12345678123;
                return notification;
            };

            context(@"USER_CENTRIC_INBOX TURNED OFF", ^{

                beforeEach(^{
                    [MEExperimental reset];
                });

                it(@"should create v2 request when USER_CENTRIC_INBOX feature is turned off", ^{
                    MENotification *notification = notificationBlock();
                    MERequestContext *requestContext = requestContextBlock([NSDate date]);

                    EMSRequestModel *requestModel = [MERequestFactory createTrackMessageOpenRequestWithNotification:notification
                                                                                                     requestContext:requestContext];

                    [[requestModel.url.absoluteString should] equal:@"https://push.eservice.emarsys.net/api/mobileengage/v2/events/message_open"];
                    [[requestModel.method should] equal:@"POST"];
                    [[requestModel.payload[@"sid"] should] equal:@"notificationSid"];
                    [[requestModel.payload[@"application_id"] should] equal:@"14C19-A121F"];
                    [[requestModel.payload[@"hardware_id"] should] equal:[EMSDeviceInfo hardwareId]];
                    [[requestModel.headers should] equal:@{@"Authorization": [EMSAuthentication createBasicAuthWithUsername:requestContext.config.applicationCode
                                                                                                                   password:requestContext.config.applicationPassword]}];
                });
            });
            context(@"USER_CENTRIC_INBOX TURNED ON", ^{

                beforeEach(^{
                    [MEExperimental enableFeature:USER_CENTRIC_INBOX];
                });

                afterEach(^{
                    [MEExperimental reset];
                });


                it(@"should create v3 request when USER_CENTRIC_INBOX feature is turned on", ^{
                    MENotification *notification = notificationBlock();
                    NSDate *timeStamp = [NSDate date];
                    MERequestContext *requestContext = requestContextBlock([NSDate date]);

                    EMSRequestModel *requestModel = [MERequestFactory createTrackMessageOpenRequestWithNotification:notification
                                                                                                     requestContext:requestContext];

                    [[requestModel.url.absoluteString should] equal:@"https://mobile-events.eservice.emarsys.net/v3/devices/requestContextMeId/events"];
                    [[requestModel.method should] equal:@"POST"];

                    [[requestModel.headers[@"X-ME-ID"] should] equal:@"requestContextMeId"];
                    [[requestModel.headers[@"X-ME-ID-SIGNATURE"] should] equal:@"requestContextMeIdSignature"];
                    [[requestModel.headers[@"X-ME-APPLICATIONCODE"] should] equal:@"14C19-A121F"];

                    [[requestModel.payload[@"events"][0][@"name"] should] equal:@"inbox:open"];
                    [[requestModel.payload[@"events"][0][@"type"] should] equal:@"internal"];
                    [[requestModel.payload[@"events"][0][@"timestamp"] should] equal:[timeStamp stringValueInUTC]];
                    [[requestModel.payload[@"events"][0][@"attributes"][@"message_id"] should] equal:@"notificationId"];
                    [[requestModel.payload[@"events"][0][@"attributes"][@"sid"] should] equal:@"notificationSid"];
                    [[requestModel.payload[@"clicks"] should] equal:@[]];
                    [[requestModel.payload[@"viewed_messages"] should] equal:@[]];
                    [[requestModel.payload[@"hardware_id"] should] equal:[EMSDeviceInfo hardwareId]];
                });

            });
        });

        describe(@"createTrackMessageOpenRequestWithMessageId:requestContext:", ^{
            beforeEach(^{
                [MEExperimental reset];
                [MEExperimental enableFeature:MESSAGE_OPEN_ON_V3];
            });

            afterEach(^{
                [MEExperimental reset];
            });

            it(@"should create v3 request when INAPP_MESSAGE feature is turned on", ^{
                NSDate *timeStamp = [NSDate date];

                MERequestContext *requestContext = requestContextBlock(timeStamp);

                EMSRequestModel *requestModel = [MERequestFactory createTrackMessageOpenRequestWithMessageId:@"testMessageId"
                                                                                              requestContext:requestContext];

                [[requestModel.url.absoluteString should] equal:@"https://mobile-events.eservice.emarsys.net/v3/devices/requestContextMeId/events"];
                [[requestModel.method should] equal:@"POST"];

                [[requestModel.headers[@"X-ME-ID"] should] equal:@"requestContextMeId"];
                [[requestModel.headers[@"X-ME-ID-SIGNATURE"] should] equal:@"requestContextMeIdSignature"];
                [[requestModel.headers[@"X-ME-APPLICATIONCODE"] should] equal:@"14C19-A121F"];

                [[requestModel.payload[@"events"][0][@"name"] should] equal:@"inbox:open"];
                [[requestModel.payload[@"events"][0][@"type"] should] equal:@"internal"];
                [[requestModel.payload[@"events"][0][@"timestamp"] should] equal:[timeStamp stringValueInUTC]];
                [[requestModel.payload[@"events"][0][@"attributes"][@"sid"] should] equal:@"testMessageId"];
                [[requestModel.payload[@"clicks"] should] equal:@[]];
                [[requestModel.payload[@"viewed_messages"] should] equal:@[]];
                [[requestModel.payload[@"hardware_id"] should] equal:[EMSDeviceInfo hardwareId]];

            });
        });

SPEC_END
