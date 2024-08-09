//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "Emarsys.h"
#import "EMSPredictInternal.h"
#import "EMSSQLiteHelper.h"
#import "EMSDBTriggerKey.h"
#import "EMSDependencyContainer.h"
#import "EmarsysTestUtils.h"
#import "EMSAbstractResponseHandler.h"
#import "MEIAMResponseHandler.h"
#import "MEIAMCleanupResponseHandlerV3.h"
#import "EMSVisitorIdResponseHandler.h"
#import "EMSDependencyInjection.h"
#import "EMSNotificationCenterManager.h"
#import "EMSAppStartBlockProvider.h"
#import "MERequestContext.h"
#import "EMSClientStateResponseHandler.h"
#import "EMSPushV3Internal.h"
#import "EMSLoggingPushInternal.h"
#import "EMSLoggingInApp.h"
#import "EMSLoggingPredictInternal.h"
#import "EMSMobileEngageV3Internal.h"
#import "EMSLoggingMobileEngageInternal.h"
#import "EMSContactClientInternal.h"
#import "EMSLoggingContactClientInternal.h"
#import "EMSDeepLinkInternal.h"
#import "EMSGeofenceInternal.h"
#import "EMSLoggingGeofenceInternal.h"
#import "EMSInboxV3.h"
#import "EMSLoggingInboxV3.h"
#import "EMSDeviceInfoV3ClientInternal.h"
#import "EMSQueueDelegator.h"
#import "EMSUUIDProvider.h"
#import "EMSInnerFeature.h"
#import "MEExperimental.h"

@interface EmarsysTests : XCTestCase

@end

@implementation EmarsysTests

- (void)tearDown {
    [EmarsysTestUtils tearDownEmarsys];
}

- (void)testShouldInitializeCategoryForPush {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testExpectation"];

    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];

    __block NSSet *categorySet = nil;
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
        categorySet = categories;
        [expectation fulfill];
    }];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation]
                                                    timeout:10];

    XCTAssertGreaterThan(categorySet.count, 0);
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

- (void)testShouldSetPredict {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];

    [self waitForSetup];

    XCTAssertNotNil((NSObject *) [Emarsys predict]);
}

- (void)testShouldSetPush {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];

    [self waitForSetup];

    XCTAssertNotNil((NSObject *) [Emarsys push]);
}

- (void)testShouldSetNotificationCenterDelegate {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];

    [self waitForSetup];

    XCTAssertNotNil((NSObject *) [Emarsys push]);
}

- (void)testShouldSetConfig {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];

    [self waitForSetup];

    XCTAssertNotNil((NSObject *) [Emarsys config]);
}

- (void)testRegisterTriggers_when_PredictTurnedOn {
    [EmarsysTestUtils tearDownEmarsys];
    [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setMobileEngageApplicationCode:@"14C19-A121F"];
                [builder setMerchantId:@"1428C8EE286EC34B"];
            }]
                         dependencyContainer:nil];

    [self waitForSetup];

    NSDictionary *triggers = [[Emarsys sqliteHelper] registeredTriggers];

    NSArray *afterInsertTriggers = triggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                                             withEvent:[EMSDBTriggerEvent insertEvent]
                                                                              withType:[EMSDBTriggerType afterType]]];

    XCTAssertEqual([afterInsertTriggers count], 2);
    XCTAssertTrue([afterInsertTriggers containsObject:EMSDependencyInjection.dependencyContainer.loggerTrigger]);
    XCTAssertTrue([afterInsertTriggers containsObject:EMSDependencyInjection.dependencyContainer.predictTrigger]);
}

- (void)testRegisterTriggers {
    [EmarsysTestUtils tearDownEmarsys];
    [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setMobileEngageApplicationCode:@"14C19-A121F"];
            }]
                         dependencyContainer:nil];

    [self waitForSetup];

    NSDictionary *triggers = [[Emarsys sqliteHelper] registeredTriggers];

    NSArray *afterInsertTriggers = triggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                                             withEvent:[EMSDBTriggerEvent insertEvent]
                                                                              withType:[EMSDBTriggerType afterType]]];
    XCTAssertEqual([afterInsertTriggers count], 2);
    XCTAssertTrue([afterInsertTriggers containsObject:EMSDependencyInjection.dependencyContainer.loggerTrigger]);
}

- (void)testSetup_config_mustNotBeNil {
    @try {
        [Emarsys setupWithConfig:nil];
        XCTFail(@"Expected Exception when config is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: config"]);
    }
}

- (void)testShouldregisterMEIAMResponseHandler {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];

    [self waitForSetup];

    BOOL registered = NO;
    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
        if ([responseHandler isKindOfClass:[MEIAMResponseHandler class]]) {
            registered = YES;
        }
    }

    XCTAssertTrue(registered);
}

- (void)testShouldregisterMEIAMCleanupResponseHandler {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];

    [self waitForSetup];

    BOOL registered = NO;
    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
        if ([responseHandler isKindOfClass:[MEIAMCleanupResponseHandlerV3 class]]) {
            registered = YES;
        }
    }

    XCTAssertTrue(registered);
}

- (void)testShouldregisterEMSVisitorIdResponseHandler_ifNoFeaturesAreTurnedOn {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];

    [self waitForSetup];

    NSUInteger registerCount = 0;
    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
        if ([responseHandler isKindOfClass:[EMSVisitorIdResponseHandler class]]) {
            registerCount++;
        }
    }

    XCTAssertEqual(registerCount, 1);
}

- (void)testShouldregisterEMSVisitorIdResponseHandler {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];

    [self waitForSetup];

    NSUInteger registerCount = 0;
    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
        if ([responseHandler isKindOfClass:[EMSVisitorIdResponseHandler class]]) {
            registerCount++;
        }
    }

    XCTAssertEqual(registerCount, 1);
}

- (void)testShouldregisterEMSClientStateResponseHandler {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];

    [self waitForSetup];

    NSUInteger registerCount = 0;
    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
        if ([responseHandler isKindOfClass:[EMSClientStateResponseHandler class]]) {
            registerCount++;
        }
    }

    XCTAssertEqual(registerCount, 1);
}

- (void)testShouldInitializeResponseHandlers {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];

    [self waitForSetup];

    XCTAssertEqual([EMSDependencyInjection.dependencyContainer.responseHandlers count], 10);
}

- (void)testShouldRegisterUIApplicationDidBecomeActiveNotification {
    EMSAppStartBlockProvider *mockProvider = OCMClassMock([EMSAppStartBlockProvider class]);
    EMSNotificationCenterManager *mockManager = OCMClassMock([EMSNotificationCenterManager class]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer appStartBlockProvider]).andReturn(mockProvider);
                OCMStub([partialMockContainer notificationCenterManager]).andReturn(mockManager);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];

    OCMVerify([mockProvider createAppStartEventBlock]);
    OCMVerify([mockProvider createDeviceInfoEventBlock]);
    OCMVerify([mockProvider createRemoteConfigEventBlock]);
    OCMVerify([mockProvider createFetchGeofenceEventBlock]);
    OCMVerify([mockManager addHandlerBlock:[OCMArg any]
                           forNotification:@"EmarsysSDKDidFinishSetupNotification"]);
    OCMVerify([mockManager addHandlerBlock:[OCMArg any]
                           forNotification:@"EmarsysSDKDidFinishSetupNotification"]);
    OCMVerify([mockManager addHandlerBlock:[OCMArg any]
                           forNotification:@"EmarsysSDKDidFinishSetupNotification"]);
    OCMVerify([mockManager addHandlerBlock:[OCMArg any]
                           forNotification:UIApplicationDidBecomeActiveNotification]);
}

- (void)testSetupWithConfigShouldSendDeviceInfoAndLogin {
    EMSContactClientInternal *mockContactClient = OCMClassMock([EMSContactClientInternal class]);
    EMSDeviceInfoV3ClientInternal *mockDeviceInfoClient = OCMClassMock([EMSDeviceInfoV3ClientInternal class]);
    MERequestContext *mockRequestContext = OCMClassMock([MERequestContext class]);
    OCMStub([mockRequestContext timestampProvider]).andReturn([EMSTimestampProvider new]);
    OCMStub([mockRequestContext uuidProvider]).andReturn([EMSUUIDProvider new]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer contactClient]).andReturn(mockContactClient);
                OCMStub([partialMockContainer deviceInfoClient]).andReturn(mockDeviceInfoClient);
                OCMStub([partialMockContainer requestContext]).andReturn(mockRequestContext);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];

    OCMVerify([mockDeviceInfoClient trackDeviceInfoWithCompletionBlock:nil]);
    OCMVerify([mockContactClient setContactWithContactFieldId:nil
                                            contactFieldValue:nil]);
}

- (void)testSetupWithConfigShouldNotSendDeviceInfoAndLogin_when_contactFieldValueIsAvailable {
    EMSContactClientInternal *mockContactClient = OCMClassMock([EMSContactClientInternal class]);
    EMSDeviceInfoV3ClientInternal *mockDeviceInfoClient = OCMClassMock([EMSDeviceInfoV3ClientInternal class]);
    MERequestContext *mockRequestContext = OCMClassMock([MERequestContext class]);
    OCMStub([mockRequestContext timestampProvider]).andReturn([EMSTimestampProvider new]);
    OCMStub([mockRequestContext uuidProvider]).andReturn([EMSUUIDProvider new]);

    OCMStub([mockRequestContext contactFieldValue]).andReturn(@"testContactFieldValue");

    OCMReject([mockContactClient setContactWithContactFieldId:[OCMArg any]
                                           contactFieldValue:[OCMArg any]]);
    OCMReject([mockDeviceInfoClient trackDeviceInfoWithCompletionBlock:[OCMArg any]]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer contactClient]).andReturn(mockContactClient);
                OCMStub([partialMockContainer deviceInfoClient]).andReturn(mockDeviceInfoClient);
                OCMStub([partialMockContainer requestContext]).andReturn(mockRequestContext);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];
}

- (void)testSetupWithConfigShouldNotSendDeviceInfoAndLogin_when_contactTokenIsAvailable {
    EMSContactClientInternal *mockContactClient = OCMClassMock([EMSContactClientInternal class]);
    EMSDeviceInfoV3ClientInternal *mockDeviceInfoClient = OCMClassMock([EMSDeviceInfoV3ClientInternal class]);
    MERequestContext *mockRequestContext = OCMClassMock([MERequestContext class]);
    OCMStub([mockRequestContext timestampProvider]).andReturn([EMSTimestampProvider new]);
    OCMStub([mockRequestContext uuidProvider]).andReturn([EMSUUIDProvider new]);

    OCMStub([mockRequestContext contactToken]).andReturn(@"testContactToken");

    OCMReject([mockContactClient setContactWithContactFieldId:[OCMArg any]
                                           contactFieldValue:[OCMArg any]]);
    OCMReject([mockDeviceInfoClient trackDeviceInfoWithCompletionBlock:[OCMArg any]]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer contactClient]).andReturn(mockContactClient);
                OCMStub([partialMockContainer deviceInfoClient]).andReturn(mockDeviceInfoClient);
                OCMStub([partialMockContainer requestContext]).andReturn(mockRequestContext);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];
}

- (void)testShouldDelegateCallToDeeplink {
    NSUserActivity *mockUserActivity = OCMClassMock([NSUserActivity class]);
    EMSSourceHandler sourceHandler = ^(NSString *source) {
    };

    EMSDeepLinkInternal *mockDeepLinkInternal = OCMClassMock([EMSDeepLinkInternal class]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer deepLink]).andReturn(mockDeepLinkInternal);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];

    [Emarsys trackDeepLinkWithUserActivity:mockUserActivity
                             sourceHandler:sourceHandler];

    OCMVerify([mockDeepLinkInternal trackDeepLinkWith:mockUserActivity
                                        sourceHandler:sourceHandler]);
}

- (void)testShouldDelegateCallToMobileEngageWithNilCompletionBlock {
    NSString *eventName = @"eventName";
    NSDictionary<NSString *, NSString *> *eventAttributes = @{@"key": @"value"};

    EMSMobileEngageV3Internal *mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer mobileEngage]).andReturn(mockMobileEngage);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];

    [Emarsys trackCustomEventWithName:eventName
                      eventAttributes:eventAttributes];

    OCMVerify([mockMobileEngage trackCustomEventWithName:eventName
                                         eventAttributes:eventAttributes
                                         completionBlock:[OCMArg any]]);
}

- (void)testShouldDelegateCallToMobileEngage {
    NSString *eventName = @"eventName";
    NSDictionary<NSString *, NSString *> *eventAttributes = @{@"key": @"value"};
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };

    EMSMobileEngageV3Internal *mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer mobileEngage]).andReturn(mockMobileEngage);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];

    [Emarsys trackCustomEventWithName:eventName
                      eventAttributes:eventAttributes
                      completionBlock:completionBlock];

    OCMVerify([mockMobileEngage trackCustomEventWithName:eventName
                                         eventAttributes:eventAttributes
                                         completionBlock:completionBlock]);
}

- (void)testSetAuthorizedContact_shouldDelegateCallToContactClient {
    NSString *idToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };

    EMSContactClientInternal *mockContactClient = OCMClassMock([EMSContactClientInternal class]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer contactClient]).andReturn(mockContactClient);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];

    [Emarsys setAuthenticatedContactWithContactFieldId:@3
                                           openIdToken:idToken
                                       completionBlock:completionBlock];

    OCMVerify([mockContactClient setAuthenticatedContactWithContactFieldId:@3
                                                              openIdToken:idToken
                                                          completionBlock:completionBlock]);
}

- (void)testSetAuthorizedContact_setAuthorizedContactIsNotCalledOnMobileEngage_when_mobileEngageIsDisabled {
    NSString *idToken = @"testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken_testIdToken";
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };

    EMSContactClientInternal *mockContactClient = OCMClassMock([EMSContactClientInternal class]);

    OCMReject([mockContactClient setAuthenticatedContactWithContactFieldId:@3
                                                              openIdToken:idToken
                                                          completionBlock:completionBlock]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer mobileEngage]).andReturn(mockContactClient);
            }
              mobileEngageEnabled:NO
                   predictEnabled:YES];

    [Emarsys setAuthenticatedContactWithContactFieldId:@3
                                           openIdToken:idToken
                                       completionBlock:completionBlock];
}

- (void)testSetAuthenticatedContact_contactFieldId_mustNotBeNil {
    @try {
        [Emarsys setAuthenticatedContactWithContactFieldId:nil
                                               openIdToken:@"testIdToken"
                                           completionBlock:nil];
        XCTFail(@"Expected Exception when contactFieldId is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: contactFieldId"]);
    }
}

- (void)testSetAuthenticatedContact_idToken_mustNotBeNil {
    @try {
        [Emarsys setAuthenticatedContactWithContactFieldId:@3
                                               openIdToken:nil
                                           completionBlock:nil];
        XCTFail(@"Expected Exception when openIdToken is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: openIdToken"]);
    }
}

- (void)testSetAuthenticatedContactWithContactFieldValueSsCalledByMobileEngage_when_mobileEngageIsEnabled {
    NSString *idToken = @"testIdToken";

    EMSContactClientInternal *mockContactClient = OCMClassMock([EMSContactClientInternal class]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer contactClient]).andReturn(mockContactClient);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];

    [Emarsys setAuthenticatedContactWithContactFieldId:@3
                                           openIdToken:idToken];

    OCMVerify([mockContactClient setAuthenticatedContactWithContactFieldId:@3
                                                              openIdToken:idToken
                                                          completionBlock:nil]);
}

- (void)testSetContact_contactFieldId_mustNotBeNil {
    @try {
        [Emarsys setContactWithContactFieldId:nil
                            contactFieldValue:@"contactFieldValue"];
        XCTFail(@"Expected Exception when contactFieldId is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: contactFieldId"]);
    }
}

- (void)testSetContact_contactFieldValue_mustNotBeNil {
    @try {
        [Emarsys setContactWithContactFieldId:@3
                            contactFieldValue:nil];
        XCTFail(@"Expected Exception when contactFieldValue is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: contactFieldValue"]);
    }
}


- (void)testSetContactWithContactFieldValueIsNotCalledByPredict_when_predictIsDisabled {
    EMSPredictInternal *mockPredict = OCMClassMock([EMSPredictInternal class]);

    OCMReject([mockPredict setContactWithContactFieldId:@3
                                      contactFieldValue:@"contact"]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer predict]).andReturn(mockPredict);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];

    [Emarsys setContactWithContactFieldId:@3
                        contactFieldValue:@"contact"];
}

- (void)testSetContactWithContactFieldValueIsCalledByMobileEngage_when_mobileEngageIsEnabled {
    EMSContactClientInternal *mockContactClient = OCMClassMock([EMSContactClientInternal class]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer contactClient]).andReturn(mockContactClient);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];

    [Emarsys setContactWithContactFieldId:@3
                        contactFieldValue:@"contact"];

    OCMVerify([mockContactClient setContactWithContactFieldId:@3
                                           contactFieldValue:@"contact"
                                             completionBlock:[OCMArg any]]);
}

- (void)testClearContactIsNotCalledByPredict_when_predictIsDisabled {
    EMSPredictInternal *mockPredict = OCMClassMock([EMSPredictInternal class]);

    OCMReject([mockPredict clearContact]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer predict]).andReturn(mockPredict);
            }
              mobileEngageEnabled:NO
                   predictEnabled:NO];

    [Emarsys clearContact];
}

- (void)testClearContactIsCalled_shouldDelegate_toContactClient {
    EMSContactClientInternal *mockContactClient = OCMClassMock([EMSContactClientInternal class]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer contactClient]).andReturn(mockContactClient);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];

    [Emarsys clearContact];

    OCMVerify([mockContactClient clearContactWithCompletionBlock:[OCMArg any]]);
}

- (void)testClearContactIsNotCalledByMobileEngage_when_mobileEngageIsDisabled {
    EMSContactClientInternal *mockContactClient = OCMClassMock([EMSContactClientInternal class]);

    OCMReject([mockContactClient clearContact]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer contactClient]).andReturn(mockContactClient);
            }
              mobileEngageEnabled:NO
                   predictEnabled:YES];

    [Emarsys clearContact];
}

- (void)testV4ShouldBeEnabled {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];

    XCTAssertTrue([MEExperimental isFeatureEnabled:EMSInnerFeature.eventServiceV4]);
}

- (void)testV4ShouldBeDisabledWhenMobileEngageIsDisabled {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:NO
                   predictEnabled:NO];

    XCTAssertFalse([MEExperimental isFeatureEnabled:EMSInnerFeature.eventServiceV4]);
}

- (void)testShouldBeEMSPushV3Internal {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:YES
                   predictEnabled:YES];

    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.push).instanceRouter.instance class], [EMSPushV3Internal class]);
}

- (void)testShouldBeMEInApp {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:YES
                   predictEnabled:YES];

    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.inApp).instanceRouter.instance class], [MEInApp class]);
}

- (void)testShouldBeEMSPredictInternal {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:YES
                   predictEnabled:YES];

    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.predict).instanceRouter.instance class], [EMSPredictInternal class]);
}

- (void)testShouldBeEMSMobileEngageV3Internal {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:YES
                   predictEnabled:YES];

    XCTAssertEqual([((EMSQueueDelegator *) EMSDependencyInjection.dependencyContainer.mobileEngage).instanceRouter.instance class], [EMSMobileEngageV3Internal class]);
}

- (void)testShouldBeEMSDeepLinkInternal {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:YES
                   predictEnabled:YES];

    XCTAssertEqual([((EMSQueueDelegator *) EMSDependencyInjection.dependencyContainer.deepLink).instanceRouter.instance class], [EMSDeepLinkInternal class]);
}

- (void)testShouldBeEMSGeofenceInternal {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:YES
                   predictEnabled:YES];

    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.geofence).instanceRouter.instance class], [EMSGeofenceInternal class]);
}

- (void)testShouldBeEMSInboxV3 {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:YES
                   predictEnabled:YES];

    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.messageInbox).instanceRouter.instance class], [EMSInboxV3 class]);
}

- (void)testShouldBeEMSLoggingPushInternal {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:NO
                   predictEnabled:NO];

    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.push).instanceRouter.instance class], [EMSLoggingPushInternal class]);
}

- (void)testShouldBeEMSLoggingInApp {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:NO
                   predictEnabled:NO];

    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.inApp).instanceRouter.instance class], [EMSLoggingInApp class]);
}

- (void)testShouldBeEMSLoggingPredictInternal {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:NO
                   predictEnabled:NO];

    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.predict).instanceRouter.instance class], [EMSLoggingPredictInternal class]);
}

- (void)testShouldBeEMSLoggingMobileEngageInternal {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:NO
                   predictEnabled:NO];

    XCTAssertEqual([((EMSQueueDelegator *) EMSDependencyInjection.mobileEngage).instanceRouter.instance class], [EMSLoggingMobileEngageInternal class]);
}

- (void)testShouldBeEMSLoggingGeofenceInternal {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:NO
                   predictEnabled:NO];

    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.geofence).instanceRouter.instance class], [EMSLoggingGeofenceInternal class]);
}

- (void)testShouldBeEMSLoggingInboxV3 {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
            }
              mobileEngageEnabled:NO
                   predictEnabled:NO];

    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.messageInbox).instanceRouter.instance class], [EMSLoggingInboxV3 class]);
}

- (void)testShouldResetContextOnReinstall {
    MERequestContext *mockContext = OCMClassMock([MERequestContext class]);
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer requestContext]).andReturn(mockContext);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];
    OCMVerify([mockContext reset]);

}

- (void)testShouldNotResetContextOnReinstallWhenContactFieldValueIsPresent {
    MERequestContext *mockContext = OCMClassMock([MERequestContext class]);
    OCMStub([mockContext contactFieldValue]).andReturn(@"teszt@teszt.kom");
    OCMReject([mockContext reset]);
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer requestContext]).andReturn(mockContext);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];
    
    [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue waitUntilAllOperationsAreFinished];
    [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue cancelAllOperations];
    [EMSDependencyInjection.dependencyContainer.coreOperationQueue waitUntilAllOperationsAreFinished];
    [EMSDependencyInjection.dependencyContainer.coreOperationQueue cancelAllOperations];
    [EMSDependencyInjection tearDown];
}

- (void)testShouldNotResetContextOnSetupWhenItIsNotReinstall {
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [ud setBool:YES
         forKey:@"kSDKAlreadyInstalled"];
    MERequestContext *mockContext = OCMClassMock([MERequestContext class]);
    OCMReject([mockContext reset]);
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
                OCMStub([partialMockContainer requestContext]).andReturn(mockContext);
            }
              mobileEngageEnabled:YES
                   predictEnabled:NO];
    
    [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue waitUntilAllOperationsAreFinished];
    [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue cancelAllOperations];
    [EMSDependencyInjection.dependencyContainer.coreOperationQueue waitUntilAllOperationsAreFinished];
    [EMSDependencyInjection.dependencyContainer.coreOperationQueue cancelAllOperations];
    [EMSDependencyInjection tearDown];
}

- (void)waitForSetup {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForDescription"];
    [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue addOperationWithBlock:^{
        [expectation fulfill];
    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)setupContainerWithMocks:(void (^)(EMSDependencyContainer *partialMockContainer))partialMockContainerBlock
            mobileEngageEnabled:(BOOL)isMobileEngageEnabled
                 predictEnabled:(BOOL)isPredictEnabled {
    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
        if (isPredictEnabled) {
            [builder setMerchantId:@"14C19-A121F"];
        }
        if (isMobileEngageEnabled) {
            [builder setMobileEngageApplicationCode:@"14C19-A121F"];
        }
    }];
    EMSDependencyContainer *container = [[EMSDependencyContainer alloc] initWithConfig:config];

    EMSDependencyContainer *partialMockContainer = OCMPartialMock(container);

    partialMockContainerBlock(partialMockContainer);

    [EmarsysTestUtils setupEmarsysWithConfig:config
                         dependencyContainer:partialMockContainer];

    [self waitForSetup];
}

@end
