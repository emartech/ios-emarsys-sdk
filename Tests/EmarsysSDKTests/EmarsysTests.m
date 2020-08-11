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
#import "MEIAMCleanupResponseHandler.h"
#import "EMSVisitorIdResponseHandler.h"
#import "EMSDependencyInjection.h"
#import "EMSNotificationCenterManager.h"
#import "EMSAppStartBlockProvider.h"
#import "MERequestContext.h"
#import "EMSClientStateResponseHandler.h"
#import "EMSPushV3Internal.h"
#import "MEInbox.h"
#import "MEInApp.h"
#import "MEUserNotificationDelegate.h"
#import "EMSLoggingPushInternal.h"
#import "EMSLoggingInbox.h"
#import "EMSLoggingInApp.h"
#import "EMSLoggingPredictInternal.h"
#import "EMSLoggingUserNotificationDelegate.h"
#import "EMSMobileEngageV3Internal.h"
#import "EMSLoggingMobileEngageInternal.h"
#import "EMSDeepLinkInternal.h"
#import "EMSLoggingDeepLinkInternal.h"
#import "EMSGeofenceInternal.h"
#import "EMSLoggingGeofenceInternal.h"
#import "EMSInboxV3.h"
#import "EMSLoggingInboxV3.h"
#import "EMSDeviceInfoV3ClientInternal.h"
#import "EMSQueueDelegator.h"
#import "EMSUUIDProvider.h"

@interface EmarsysTests: XCTestCase

@end

@implementation EmarsysTests

- (void)tearDown {
    [EmarsysTestUtils tearDownEmarsys];
}

- (void)testShouldInitializeCategoryForPush {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testExpectation"];
    
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];
    
    __block NSSet*categorySet= nil;
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
        categorySet= categories;
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
    
    XCTAssertNotNil((NSObject *) [Emarsys notificationCenterDelegate]);
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
        [builder setContactFieldId:@3];
    }]
                         dependencyContainer:nil];
    
    [self waitForSetup];
    
    NSDictionary *triggers = [[Emarsys sqliteHelper] registeredTriggers];
    
    NSArray *afterInsertTriggers = triggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                                             withEvent:[EMSDBTriggerEvent insertEvent]
                                                                              withType:[EMSDBTriggerType afterType]]];
    
    XCTAssertEqual([afterInsertTriggers count], 2);
    XCTAssertTrue([afterInsertTriggers containsObject:EMSDependencyInjection.dependencyContainer.loggerTrigger]);
    XCTAssertTrue([afterInsertTriggers containsObject:EMSDependencyInjection.dependencyContainer.predictTrigger ]);
}

- (void)testRegisterTriggers {
    [EmarsysTestUtils tearDownEmarsys];
    [EmarsysTestUtils setupEmarsysWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
        [builder setMobileEngageApplicationCode:@"14C19-A121F"];
        [builder setContactFieldId:@3];
    }]
                         dependencyContainer:nil];
    
    [self waitForSetup];
    
    NSDictionary *triggers = [[Emarsys sqliteHelper] registeredTriggers];
    
    NSArray *afterInsertTriggers = triggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                                             withEvent:[EMSDBTriggerEvent insertEvent]
                                                                              withType:[EMSDBTriggerType afterType]]];
    XCTAssertEqual([afterInsertTriggers count], 1);
    XCTAssertTrue([afterInsertTriggers containsObject:EMSDependencyInjection.dependencyContainer.loggerTrigger]);
}

- (void)testSetup_config_mustNotBeNil{
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
        if ([responseHandler isKindOfClass:[MEIAMCleanupResponseHandler class]]) {
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

- (void)testShouldInitializeresponseHandlers {
    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                       withDependencyContainer:nil];
    
    [self waitForSetup];
    
    XCTAssertEqual([EMSDependencyInjection.dependencyContainer.responseHandlers count], 7);
}

- (void)testShouldregisterUIApplicationDidBecomeActiveNotification {
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

- (void)testsetupWithConfigShouldSendDeviceInfoAndLogin {
    EMSMobileEngageV3Internal *mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    EMSDeviceInfoV3ClientInternal *mockDeviceInfoClient = OCMClassMock([EMSDeviceInfoV3ClientInternal class]);
    MERequestContext *mockRequestContext = OCMClassMock([MERequestContext class]);
    OCMStub([mockRequestContext timestampProvider]).andReturn([EMSTimestampProvider new]);
    OCMStub([mockRequestContext uuidProvider]).andReturn([EMSUUIDProvider new]);

    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer mobileEngage]).andReturn(mockMobileEngage);
        OCMStub([partialMockContainer deviceInfoClient]).andReturn(mockDeviceInfoClient);
        OCMStub([partialMockContainer requestContext]).andReturn(mockRequestContext);
    }
              mobileEngageEnabled:YES
                   predictEnabled:NO];
    
    OCMVerify([mockDeviceInfoClient trackDeviceInfoWithCompletionBlock:nil]);
    OCMVerify([mockMobileEngage setContactWithContactFieldValue:nil]);
}

- (void)testsetupWithConfigShouldNotSendDeviceInfoAndLogin_when_contactFieldValueIsAvailable {
    EMSMobileEngageV3Internal *mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    EMSDeviceInfoV3ClientInternal *mockDeviceInfoClient = OCMClassMock([EMSDeviceInfoV3ClientInternal class]);
    MERequestContext *mockRequestContext = OCMClassMock([MERequestContext class]);
    OCMStub([mockRequestContext timestampProvider]).andReturn([EMSTimestampProvider new]);
    OCMStub([mockRequestContext uuidProvider]).andReturn([EMSUUIDProvider new]);
    
    OCMStub([mockRequestContext contactFieldValue]).andReturn(@"testContactFieldValue");
    
    OCMReject([mockMobileEngage setContactWithContactFieldValue:[OCMArg any]]);
    OCMReject([mockDeviceInfoClient trackDeviceInfoWithCompletionBlock:[OCMArg any]]);
    
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer mobileEngage]).andReturn(mockMobileEngage);
        OCMStub([partialMockContainer deviceInfoClient]).andReturn(mockDeviceInfoClient);
        OCMStub([partialMockContainer requestContext]).andReturn(mockRequestContext);
    }
              mobileEngageEnabled:YES
                   predictEnabled:NO];
}

- (void)testsetupWithConfigShouldNotSendDeviceInfoAndLogin_when_contactTokenIsAvailable {
    EMSMobileEngageV3Internal *mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    EMSDeviceInfoV3ClientInternal *mockDeviceInfoClient = OCMClassMock([EMSDeviceInfoV3ClientInternal class]);
    MERequestContext *mockRequestContext = OCMClassMock([MERequestContext class]);
    OCMStub([mockRequestContext timestampProvider]).andReturn([EMSTimestampProvider new]);
    OCMStub([mockRequestContext uuidProvider]).andReturn([EMSUUIDProvider new]);
    
    OCMStub([mockRequestContext contactToken]).andReturn(@"testContactToken");
    
    OCMReject([mockMobileEngage setContactWithContactFieldValue:[OCMArg any]]);
    OCMReject([mockDeviceInfoClient trackDeviceInfoWithCompletionBlock:[OCMArg any]]);
    
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer mobileEngage]).andReturn(mockMobileEngage);
        OCMStub([partialMockContainer deviceInfoClient]).andReturn(mockDeviceInfoClient);
        OCMStub([partialMockContainer requestContext]).andReturn(mockRequestContext);
    }
              mobileEngageEnabled:YES
                   predictEnabled:NO];
}

- (void)testShoulddelegatecallToMobileEngage {
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

- (void)testShouldDelegatecallToMobileEngageWithNilCompletionBlock {
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

- (void)testsetContactWithContactFieldValueIsNotCalledByPredict_when_predictIsDisabled {
    EMSPredictInternal *mockPredict = OCMClassMock([EMSPredictInternal class]);
    
    OCMReject([mockPredict setContactWithContactFieldValue:@"contact"]);
    
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer predict]).andReturn(mockPredict);
    }
              mobileEngageEnabled:YES
                   predictEnabled:NO];
    
    [Emarsys setContactWithContactFieldValue:@"contact"];
}

- (void)testsetContactWithContactFieldValueIsCalledByPredict_when_predictIsEnabled {
    EMSPredictInternal *mockPredict = OCMClassMock([EMSPredictInternal class]);
    
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer predict]).andReturn(mockPredict);
    }
              mobileEngageEnabled:YES
                   predictEnabled:YES];
    
    [Emarsys setContactWithContactFieldValue:@"contact"];
    
    OCMVerify([mockPredict setContactWithContactFieldValue:@"contact"]);
}

- (void)testsetContactWithContactFieldValueIsNotCalledByMobileEngage_when_mobileEngageIsDisabled {
    EMSMobileEngageV3Internal *mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    
    OCMReject([mockMobileEngage setContactWithContactFieldValue:@"contact"
                                                completionBlock:[OCMArg any]]);
    
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer mobileEngage]).andReturn(mockMobileEngage);
    }
              mobileEngageEnabled:NO
                   predictEnabled:YES];
    
    [Emarsys setContactWithContactFieldValue:@"contact"];
}

- (void)testsetContactWithContactFieldValueisCalledByMobileEngage_when_mobileEngageIsEnabled {
    EMSMobileEngageV3Internal *mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer mobileEngage]).andReturn(mockMobileEngage);
    }
              mobileEngageEnabled:YES
                   predictEnabled:YES];
    
    [Emarsys setContactWithContactFieldValue:@"contact"];
    
    OCMVerify([mockMobileEngage setContactWithContactFieldValue:@"contact"
                                                completionBlock:[OCMArg any]]);
}

- (void)testsetContactWithContactFieldValueIsOnlyCalledOnce_when_mobileEngageAndPredictAreDisabled {
    EMSMobileEngageV3Internal *mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    EMSPredictInternal *mockPredict = OCMClassMock([EMSPredictInternal class]);
    
    OCMReject([mockPredict setContactWithContactFieldValue:@"contact"]);
    
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer mobileEngage]).andReturn(mockMobileEngage);
        OCMStub([partialMockContainer predict]).andReturn(mockPredict);
    }
              mobileEngageEnabled:NO
                   predictEnabled:NO];
    
    [Emarsys setContactWithContactFieldValue:@"contact"];
    
    OCMVerify([mockMobileEngage setContactWithContactFieldValue:@"contact"
                                                completionBlock:[OCMArg any]]);
}

- (void)testclearContactIsNotCalledByPredict_when_predictIsDisabled {
    EMSPredictInternal *mockPredict = OCMClassMock([EMSPredictInternal class]);
    
    OCMReject([mockPredict clearContact]);
    
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer predict]).andReturn(mockPredict);
    }
              mobileEngageEnabled:NO
                   predictEnabled:NO];
    
    [Emarsys clearContact];
}

- (void)testclearContactisCalledByPredict_when_predictIsEnabled {
    EMSPredictInternal *mockPredict = OCMClassMock([EMSPredictInternal class]);
    
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer predict]).andReturn(mockPredict);
    }
              mobileEngageEnabled:NO
                   predictEnabled:YES];
    
    [Emarsys clearContact];
    
    OCMVerify([mockPredict clearContact]);
}

- (void)testclearContactIsNotCalledByMobileEngage_when_mobileEngageIsDisabled {
    EMSMobileEngageV3Internal *mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    
    OCMReject([mockMobileEngage clearContact]);
    
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer mobileEngage]).andReturn(mockMobileEngage);
    }
              mobileEngageEnabled:NO
                   predictEnabled:YES];
    
    [Emarsys clearContact];
}

- (void)testclearContactisCalledByMobileEngage_when_mobileEngageIsEnabled {
    EMSMobileEngageV3Internal *mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer mobileEngage]).andReturn(mockMobileEngage);
    }
              mobileEngageEnabled:YES
                   predictEnabled:NO];
    
    [Emarsys clearContact];
    
    OCMVerify([mockMobileEngage clearContactWithCompletionBlock:nil]);
}

- (void)testclearContactisOnlyCalledOnce_when_mobileEngageAndPredictAreDisabled {
    EMSMobileEngageV3Internal *mockMobileEngage = OCMClassMock([EMSMobileEngageV3Internal class]);
    EMSPredictInternal *mockPredict = OCMClassMock([EMSPredictInternal class]);
    
    OCMReject([mockPredict clearContact]);
    
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
        OCMStub([partialMockContainer mobileEngage]).andReturn(mockMobileEngage);
        OCMStub([partialMockContainer predict]).andReturn(mockPredict);
    }
              mobileEngageEnabled:NO
                   predictEnabled:NO];
    
    [Emarsys clearContact];
    
    OCMVerify([mockMobileEngage clearContactWithCompletionBlock:[OCMArg any]]);
}

- (void)testShouldBeEMSPushV3Internal {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
    }
              mobileEngageEnabled:YES
                   predictEnabled:YES];
    
    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.push).instanceRouter.instance class], [EMSPushV3Internal class]);
}

- (void)testShouldBeMEInbox {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
    }
              mobileEngageEnabled:YES
                   predictEnabled:YES];
    
    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.inbox).instanceRouter.instance class], [MEInbox class]);
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

- (void)testShouldBeMEUserNotificationDelegate {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
    }
              mobileEngageEnabled:YES
                   predictEnabled:YES];

    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.notificationCenterDelegate).instanceRouter.instance class], [MEUserNotificationDelegate class]);
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

- (void)testShouldBeEMSLoggingInbox {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
    }
              mobileEngageEnabled:NO
                   predictEnabled:NO];
    
    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.inbox).instanceRouter.instance class], [EMSLoggingInbox class]);
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

- (void)testShouldBeEMSLoggingUserNotificationDelegate {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
    }
              mobileEngageEnabled:NO
                   predictEnabled:NO];
    
    XCTAssertEqual([((EMSQueueDelegator *) Emarsys.notificationCenterDelegate).instanceRouter.instance class], [EMSLoggingUserNotificationDelegate class]);
}

- (void)testShouldBeEMSLoggingMobileEngageInternal {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
    }
              mobileEngageEnabled:NO
                   predictEnabled:NO];
    
    XCTAssertEqual([((EMSQueueDelegator *) EMSDependencyInjection.mobileEngage).instanceRouter.instance class], [EMSLoggingMobileEngageInternal class]);
}

- (void)testShouldBeEMSLoggingDeepLinkInternal {
    [self setupContainerWithMocks:^(EMSDependencyContainer *partialMockContainer) {
    }
              mobileEngageEnabled:NO
                   predictEnabled:NO];
    
    XCTAssertEqual([((EMSQueueDelegator *) EMSDependencyInjection.deepLink).instanceRouter.instance class], [EMSLoggingDeepLinkInternal class]);
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

- (void)waitForSetup {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForDescription"];
    [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue addOperationWithBlock:^{
        [expectation fulfill];
    }];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

- (void)setupContainerWithMocks:(void(^)(EMSDependencyContainer *partialMockContainer))partialMockContainerBlock
            mobileEngageEnabled:(BOOL)isMobileEngageEnabled
                 predictEnabled:(BOOL)isPredictEnabled {
    [EmarsysTestUtils tearDownEmarsys];
    
    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
        if (isPredictEnabled) {
            [builder setMerchantId:@"14C19-A121F"];
        }
        if (isMobileEngageEnabled) {
            [builder setMobileEngageApplicationCode:@"14C19-A121F"];
        }
        [builder setContactFieldId:@3];
    }];
    EMSDependencyContainer *container = [[EMSDependencyContainer alloc] initWithConfig:config];
    
    EMSDependencyContainer *partialMockContainer = OCMPartialMock(container);
    
    partialMockContainerBlock(partialMockContainer);
    
    [EmarsysTestUtils setupEmarsysWithConfig:config
                         dependencyContainer:partialMockContainer];

    [self waitForSetup];
}

@end
