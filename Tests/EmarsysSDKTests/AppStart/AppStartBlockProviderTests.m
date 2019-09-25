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
#import "EMSDeviceInfoClientProtocol.h"

@interface AppStartBlockProviderTests : XCTestCase

@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) AppStartBlockProvider *appStartBlockProvider;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) id mockDeviceInfoClient;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) MEHandlerBlock appStartEventBlock;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSNumber *contactFieldId;

@end

@implementation AppStartBlockProviderTests


- (void)setUp {
    _applicationCode = @"testApplicationCode";
    _contactFieldId = @3;
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockDeviceInfoClient = OCMProtocolMock(@protocol(EMSDeviceInfoClientProtocol));
    _mockRequestContext = OCMClassMock([MERequestContext class]);
    _requestContext = [[MERequestContext alloc] initWithApplicationCode:self.applicationCode
                                                         contactFieldId:self.contactFieldId
                                                           uuidProvider:[EMSUUIDProvider new]
                                                      timestampProvider:[EMSTimestampProvider new]
                                                             deviceInfo:[EMSDeviceInfo new]];

    [self.requestContext setContactToken:nil];

    _appStartBlockProvider = [[AppStartBlockProvider alloc] initWithRequestManager:self.mockRequestManager
                                                                    requestFactory:self.mockRequestFactory
                                                                    requestContext:self.requestContext
                                                                  deviceInfoClient:self.mockDeviceInfoClient];
    _appStartEventBlock = [self.appStartBlockProvider createAppStartEventBlock];
}

- (void)tearDown {
    [self.requestContext setContactToken:nil];
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[AppStartBlockProvider alloc] initWithRequestManager:nil
                                               requestFactory:self.mockRequestFactory
                                               requestContext:self.mockRequestContext
                                             deviceInfoClient:self.mockDeviceInfoClient];
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
                                             deviceInfoClient:self.mockDeviceInfoClient];
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
                                             deviceInfoClient:self.mockDeviceInfoClient];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testInit_deviceInfoClient_mustNotBeNil {
    @try {
        [[AppStartBlockProvider alloc] initWithRequestManager:self.mockRequestManager
                                               requestFactory:self.mockRequestFactory
                                               requestContext:self.mockRequestContext
                                             deviceInfoClient:nil];
        XCTFail(@"Expected Exception when deviceInfoClient is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: deviceInfoClient");
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

- (void)testCreateDeviceInfoEventBlock {
    _appStartEventBlock = [self.appStartBlockProvider createDeviceInfoEventBlock];

    self.appStartEventBlock();

    OCMVerify([self.mockDeviceInfoClient sendDeviceInfoWithCompletionBlock:nil];);
}


@end