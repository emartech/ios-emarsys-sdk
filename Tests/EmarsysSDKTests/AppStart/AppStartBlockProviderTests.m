//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <OCMock/OCMock.h>
#import "Kiwi.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "AppStartBlockProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSDeviceInfo+MEClientPayload.h"
#import "EMSWaiter.h"
#import "EMSRequestFactory.h"

@interface AppStartBlockProviderTests : XCTestCase

@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) AppStartBlockProvider *appStartBlockProvider;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;
@property(nonatomic, strong) MEHandlerBlock handlerBlock;

@end

@implementation AppStartBlockProviderTests


- (void)setUp {
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _requestContext = [[MERequestContext alloc] initWithConfig:[EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
            [builder setMobileEngageApplicationCode:@"14C19-A121F"
                                applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
            [builder setMerchantId:@"testMerchantId"];
            [builder setContactFieldId:@3];
        }]                                        uuidProvider:[EMSUUIDProvider new]
                                             timestampProvider:[EMSTimestampProvider new]
                                                    deviceInfo:[EMSDeviceInfo new]];

    [self.requestContext setMeId:nil];
    [self.requestContext setMeIdSignature:nil];

    _appStartBlockProvider = [AppStartBlockProvider new];
    _handlerBlock = [self.appStartBlockProvider createAppStartBlockWithRequestManager:self.mockRequestManager
                                                                       requestContext:self.requestContext];
}

- (void)tearDown {
    [self.requestContext setMeId:nil];
    [self.requestContext setMeIdSignature:nil];
}

- (void)testCreateAppStartBlockWithRequestManagerRequestContext_shouldSubmitAppStartEvent_whenInvokingHandlerBlock {
    [self.requestContext setMeId:@"testMeId"];
    [self.requestContext setMeIdSignature:@"testMeIdSignature"];

    __block EMSRequestModel *requestModel;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForRequestModel"];
    OCMStub([self.mockRequestManager submitRequestModel:[OCMArg any]
                                    withCompletionBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        [invocation getArgument:&requestModel
                        atIndex:2];
        [expectation fulfill];
    });

    self.handlerBlock();

    [EMSWaiter waitForExpectations:@[expectation]];

    OCMVerify([self.mockRequestManager submitRequestModel:[OCMArg any]
                                      withCompletionBlock:[OCMArg any]]);

    XCTAssertEqualObjects([requestModel.url absoluteString], @"https://mobile-events.eservice.emarsys.net/v3/devices/testMeId/events");
    XCTAssertEqualObjects(requestModel.payload[@"events"][0][@"type"], @"internal");
    XCTAssertEqualObjects(requestModel.payload[@"events"][0][@"name"], @"app:start");
}

- (void)testCreateAppStartBlockWithRequestManagerRequestContext_shouldNotCallSubmit_whenThereIsNoMEid {
    OCMReject([self.mockRequestManager submitRequestModel:[OCMArg any]
                                      withCompletionBlock:[OCMArg any]]);
    self.handlerBlock();
}

- (void)testCreateAppStartBlockWithRequestManagerRequestFactoryDeviceInfo_requestManager_mustNotBeNull {
    @try {
        [self.appStartBlockProvider createAppStartBlockWithRequestManager:nil
                                                           requestFactory:OCMClassMock([EMSRequestFactory class])
                                                               deviceInfo:OCMClassMock([EMSDeviceInfo class])];

        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testCreateAppStartBlockWithRequestManagerRequestFactoryDeviceInfo_requestFactory_mustNotBeNull {
    @try {
        [self.appStartBlockProvider createAppStartBlockWithRequestManager:OCMClassMock([EMSRequestManager class])
                                                           requestFactory:nil
                                                               deviceInfo:OCMClassMock([EMSDeviceInfo class])];

        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testCreateAppStartBlockWithRequestManagerRequestFactoryDeviceInfo_deviceInfo_mustNotBeNull {
    @try {
        [self.appStartBlockProvider createAppStartBlockWithRequestManager:OCMClassMock([EMSRequestManager class])
                                                           requestFactory:OCMClassMock([EMSRequestFactory class])
                                                               deviceInfo:nil];

        XCTFail(@"Expected Exception when deviceInfo is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: deviceInfo");
    }
}

- (void)testCreateAppStartBlockWithRequestManagerRequestFactoryDeviceInfo_submitRequest {
    _handlerBlock = [self.appStartBlockProvider createAppStartBlockWithRequestManager:self.mockRequestManager
                                                                       requestFactory:self.mockRequestFactory
                                                                           deviceInfo:self.mockDeviceInfo];
    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([self.mockRequestFactory createDeviceInfoRequestModel]).andReturn(requestModel);

    self.handlerBlock();

    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:[OCMArg any]]);
}

- (void)testCreateAppStartBlockWithRequestManagerRequestFactoryDeviceInfo_shouldNotSubmit_whenDeviceInfoHasNotChanged {
    EMSDeviceInfo *deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:@"0.0.1"];
    _handlerBlock = [self.appStartBlockProvider createAppStartBlockWithRequestManager:self.mockRequestManager
                                                                       requestFactory:self.mockRequestFactory
                                                                           deviceInfo:deviceInfo];
    OCMReject([self.mockRequestManager submitRequestModel:[OCMArg any]
                                      withCompletionBlock:[OCMArg any]]);

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];

    NSDictionary *deviceInfoDictionary = [deviceInfo clientPayload];
    [userDefaults setObject:deviceInfoDictionary
                     forKey:kDEVICE_INFO];
    [userDefaults synchronize];

    self.handlerBlock();
}

@end

