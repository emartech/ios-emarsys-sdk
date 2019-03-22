//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <OCMock/OCMock.h>
#import "Kiwi.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "AppStartBlockProvider.h"
#import "EMSDeviceInfo+MEClientPayload.h"
#import "EMSRequestFactory.h"
#import "EMSUUIDProvider.h"

@interface AppStartBlockProviderTests : XCTestCase

@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) AppStartBlockProvider *appStartBlockProvider;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) MEHandlerBlock appStartEventBlock;

@end

@implementation AppStartBlockProviderTests


- (void)setUp {
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _mockRequestContext = OCMClassMock([MERequestContext class]);
    _requestContext = [[MERequestContext alloc] initWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                [builder setMobileEngageApplicationCode:@"14C19-A121F"
                                    applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                [builder setMerchantId:@"testMerchantId"];
                [builder setContactFieldId:@3];
            }]                                    uuidProvider:[EMSUUIDProvider new]
                                             timestampProvider:[EMSTimestampProvider new]
                                                    deviceInfo:[EMSDeviceInfo new]];

    [self.requestContext setMeId:nil];
    [self.requestContext setMeIdSignature:nil];
    [self.requestContext setContactToken:nil];

    _appStartBlockProvider = [[AppStartBlockProvider alloc] initWithRequestManager:self.mockRequestManager
                                                                    requestFactory:self.mockRequestFactory
                                                                    requestContext:self.requestContext
                                                                        deviceInfo:self.mockDeviceInfo];
    _appStartEventBlock = [self.appStartBlockProvider createAppStartEventBlock];
}

- (void)tearDown {
    [self.requestContext setMeId:nil];
    [self.requestContext setMeIdSignature:nil];
    [self.requestContext setContactToken:nil];
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[AppStartBlockProvider alloc] initWithRequestManager:nil
                                               requestFactory:self.mockRequestFactory
                                               requestContext:self.mockRequestContext
                                                   deviceInfo:self.mockDeviceInfo];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[AppStartBlockProvider alloc] initWithRequestManager:self.mockRequestManager
                                               requestFactory:nil
                                               requestContext:self.mockRequestContext
                                                   deviceInfo:self.mockDeviceInfo];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[AppStartBlockProvider alloc] initWithRequestManager:self.mockRequestManager
                                               requestFactory:self.mockRequestFactory
                                               requestContext:nil
                                                   deviceInfo:self.mockDeviceInfo];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testInit_deviceInfor_mustNotBeNil {
    @try {
        [[AppStartBlockProvider alloc] initWithRequestManager:self.mockRequestManager
                                               requestFactory:self.mockRequestFactory
                                               requestContext:self.mockRequestContext
                                                   deviceInfo:nil];
        XCTFail(@"Expected Exception when deviceInfo is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: deviceInfo");
    }
}

- (void)testCreateAppStartBlockWithRequestManagerRequestContext_shouldSubmitAppStartEvent_whenInvokingHandlerBlock {
    [self.requestContext setContactToken:@"testContactToken"];

    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:@"app:start"
                                                          eventAttributes:[OCMArg any]
                                                                eventType:EventTypeInternal]).andReturn(requestModel);

    self.appStartEventBlock();

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:@"app:start"
                                                            eventAttributes:[OCMArg any]
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
}

- (void)testCreateAppStartBlockWithRequestManagerRequestContext_shouldNotCallSubmit_whenThereIsNoContactToken {
    OCMReject([self.mockRequestManager submitRequestModel:[OCMArg any]
                                      withCompletionBlock:[OCMArg any]]);
    self.appStartEventBlock();
}

- (void)testCreateAppStartBlockWithRequestManagerRequestFactoryDeviceInfo_submitRequest {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults setObject:@{@"testStoredPayloadKey": @"testStoredPayloadValue"}
                     forKey:kDEVICE_INFO];
    [userDefaults synchronize];

    NSDictionary *expectedDeviceInfoDict = @{
            @"testPayloadKey": @"testPayloadValue",
            @"testPayloadKey2": @"testPayloadValue2"
    };
    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockDeviceInfo clientPayload]).andReturn(expectedDeviceInfoDict);
    OCMStub([self.mockRequestFactory createDeviceInfoRequestModel]).andReturn(requestModel);

    MEHandlerBlock handlerBlock = [self.appStartBlockProvider createDeviceInfoEventBlock];
    handlerBlock();

    NSDictionary *storedDeviceInfoDict = [userDefaults dictionaryForKey:kDEVICE_INFO];

    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
    XCTAssertEqualObjects(storedDeviceInfoDict, expectedDeviceInfoDict);
}

- (void)testCreateAppStartBlockWithRequestManagerRequestFactoryDeviceInfo_shouldNotSubmit_whenDeviceInfoHasNotChanged {
    EMSDeviceInfo *deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:@"0.0.1"];
    _appStartBlockProvider = [[AppStartBlockProvider alloc] initWithRequestManager:self.mockRequestManager
                                                                    requestFactory:self.mockRequestFactory
                                                                    requestContext:self.requestContext
                                                                        deviceInfo:deviceInfo];
    MEHandlerBlock handlerBlock = [self.appStartBlockProvider createDeviceInfoEventBlock];
    OCMReject([self.mockRequestManager submitRequestModel:[OCMArg any]
                                      withCompletionBlock:[OCMArg any]]);

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];

    NSDictionary *deviceInfoDictionary = [deviceInfo clientPayload];
    [userDefaults setObject:deviceInfoDictionary
                     forKey:kDEVICE_INFO];
    [userDefaults synchronize];

    handlerBlock();
}

@end