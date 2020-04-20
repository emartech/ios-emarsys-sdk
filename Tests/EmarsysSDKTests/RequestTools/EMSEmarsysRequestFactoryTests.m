//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSEmarsysRequestFactory.h"
#import "EMSUUIDProvider.h"
#import "EMSTimestampProvider.h"
#import "EMSRequestModel.h"
#import "EMSEndpoint.h"
#import "MERequestContext.h"

@interface EMSEmarsysRequestFactoryTests : XCTestCase

@property(nonatomic, strong) EMSUUIDProvider *mockUUIDProvider;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSEndpoint *mockEndpoint;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) EMSEmarsysRequestFactory *requestFactory;

@end

@implementation EMSEmarsysRequestFactoryTests

- (void)setUp {
    _mockUUIDProvider = OCMClassMock([EMSUUIDProvider class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _mockEndpoint = OCMClassMock([EMSEndpoint class]);
    _mockRequestContext = OCMClassMock([MERequestContext class]);

    _requestFactory = [[EMSEmarsysRequestFactory alloc] initWithTimestampProvider:self.mockTimestampProvider
                                                                     uuidProvider:self.mockUUIDProvider
                                                                         endpoint:self.mockEndpoint
                                                                   requestContext:self.mockRequestContext];
}

- (void)testInit_timestampProvider_mustNotBeNil {
    @try {
        [[EMSEmarsysRequestFactory alloc] initWithTimestampProvider:nil
                                                       uuidProvider:self.mockUUIDProvider
                                                           endpoint:self.mockEndpoint
                                                     requestContext:self.mockRequestContext];
        XCTFail(@"Expected Exception when timestampProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: timestampProvider");
    }
}

- (void)testInit_uuidProvider_mustNotBeNil {
    @try {
        [[EMSEmarsysRequestFactory alloc] initWithTimestampProvider:self.mockTimestampProvider
                                                       uuidProvider:nil
                                                           endpoint:self.mockEndpoint
                                                     requestContext:self.mockRequestContext];
        XCTFail(@"Expected Exception when uuidProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: uuidProvider");
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSEmarsysRequestFactory alloc] initWithTimestampProvider:self.mockTimestampProvider
                                                       uuidProvider:self.mockUUIDProvider
                                                           endpoint:nil
                                                     requestContext:self.mockRequestContext];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSEmarsysRequestFactory alloc] initWithTimestampProvider:self.mockTimestampProvider
                                                       uuidProvider:self.mockUUIDProvider
                                                           endpoint:self.mockEndpoint
                                                     requestContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testCreateRemoteConfigRequestModel {
    OCMStub([self.mockRequestContext applicationCode]).andReturn(@"testApplicationCode");
    OCMStub([self.mockEndpoint remoteConfigUrl:[OCMArg any]]).andReturn(@"https://test.url");

    EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodGET];
                [builder setUrl:@"https://test.url"];
            }
                                                           timestampProvider:self.mockTimestampProvider
                                                                uuidProvider:self.mockUUIDProvider];

    EMSRequestModel *returnedRequestModel = [self.requestFactory createRemoteConfigRequestModel];

    OCMVerify([self.mockEndpoint remoteConfigUrl:@"testApplicationCode"]);

    XCTAssertEqualObjects(returnedRequestModel, expectedRequestModel);
}

- (void)testCreateRemoteConfigSignatureRequestModel {
    OCMStub([self.mockRequestContext applicationCode]).andReturn(@"testApplicationCode");
    OCMStub([self.mockEndpoint remoteConfigSignatureUrl:[OCMArg any]]).andReturn(@"https://test.sig.url");

    EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodGET];
                [builder setUrl:@"https://test.sig.url"];
            }
                                                           timestampProvider:self.mockTimestampProvider
                                                                uuidProvider:self.mockUUIDProvider];

    EMSRequestModel *returnedRequestModel = [self.requestFactory createRemoteConfigSignatureRequestModel];

    OCMVerify([self.mockEndpoint remoteConfigSignatureUrl:@"testApplicationCode"]);

    XCTAssertEqualObjects(returnedRequestModel, expectedRequestModel);
}

@end
