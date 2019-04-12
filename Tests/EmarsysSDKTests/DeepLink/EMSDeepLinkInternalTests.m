//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSDeepLinkInternal.h"
#import "EMSWaiter.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"

@interface EMSDeepLinkInternalTests : XCTestCase

@property(nonatomic, strong) EMSDeepLinkInternal *deepLink;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;

@end

@implementation EMSDeepLinkInternalTests

- (void)setUp {
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);

    _deepLink = [[EMSDeepLinkInternal alloc] initWithRequestManager:self.mockRequestManager
                                                     requestFactory:self.mockRequestFactory];
}


- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSDeepLinkInternal alloc] initWithRequestManager:nil
                                             requestFactory:self.mockRequestFactory];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: requestManager"]);
    }
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSDeepLinkInternal alloc] initWithRequestManager:self.mockRequestManager
                                             requestFactory:nil];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: requestFactory"]);
    }
}

- (void)testTrackDeepLinkWithSourceHandler {
    EMSDeepLinkInternal *partialMockDeepLinkInternal = OCMPartialMock(self.deepLink);
    NSUserActivity *userActivity = OCMClassMock([NSUserActivity class]);
    EMSSourceHandler sourceHandler = ^(NSString *source) {
    };

    [partialMockDeepLinkInternal trackDeepLinkWith:userActivity
                                     sourceHandler:sourceHandler];

    OCMVerify([partialMockDeepLinkInternal trackDeepLinkWith:userActivity
                                               sourceHandler:sourceHandler
                                         withCompletionBlock:nil]);
}

- (void)testTrackDeepLinkWithSourceHandler_shouldReturnYes {
    NSString *activityType = [NSString stringWithFormat:@"%@", NSUserActivityTypeBrowsingWeb];
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.google.com/something?fancy_url=1&ems_dl=1_2_3_4_5"];
    NSUserActivity *userActivity = OCMClassMock([NSUserActivity class]);

    OCMStub([userActivity activityType]).andReturn(activityType);
    OCMStub([userActivity webpageURL]).andReturn(url);

    BOOL returnValue = [self.deepLink trackDeepLinkWith:userActivity
                                          sourceHandler:nil];

    XCTAssertTrue(returnValue);
}

- (void)testTrackDeepLinkWithSourceHandler_shouldReturnNo {
    NSString *activityType = @"NotNSUserActivityTypeBrowsingWeb";
    NSUserActivity *userActivity = OCMClassMock([NSUserActivity class]);

    OCMStub([userActivity activityType]).andReturn(activityType);

    BOOL returnValue = [self.deepLink trackDeepLinkWith:userActivity
                                          sourceHandler:nil];

    XCTAssertFalse(returnValue);
}

- (void)testTrackDeepLinkWithSourceHandler_shouldCallSourceBlock {
    NSString *expectedSource = @"http://www.google.com/something?fancy_url=1&ems_dl=1_2_3_4_5";

    NSString *activityType = [NSString stringWithFormat:@"%@", NSUserActivityTypeBrowsingWeb];
    NSURL *url = [[NSURL alloc] initWithString:expectedSource];
    NSUserActivity *userActivity = OCMClassMock([NSUserActivity class]);

    OCMStub([userActivity activityType]).andReturn(activityType);
    OCMStub([userActivity webpageURL]).andReturn(url);

    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];

    __block NSString *resultSource;
    [self.deepLink trackDeepLinkWith:userActivity
                       sourceHandler:^(NSString *source) {
                           resultSource = source;
                           [exp fulfill];
                       }];
    [EMSWaiter waitForExpectations:@[exp]
                           timeout:10];

    XCTAssertEqualObjects(resultSource, expectedSource);
}

- (void)testTrackDeepLinkWithSourceHandler_shouldSubmitDeepLinkTrackingRequestModel {
    EMSCompletionBlock completionBlock = ^(NSError *error) {
    };
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);
    NSString *expectedSource = @"http://www.google.com/something?fancy_url=1&ems_dl=1_2_3_4_5";

    NSString *activityType = [NSString stringWithFormat:@"%@", NSUserActivityTypeBrowsingWeb];
    NSURL *url = [[NSURL alloc] initWithString:expectedSource];
    NSUserActivity *userActivity = OCMClassMock([NSUserActivity class]);

    OCMStub([userActivity activityType]).andReturn(activityType);
    OCMStub([userActivity webpageURL]).andReturn(url);
    OCMStub([self.mockRequestFactory createDeepLinkRequestModelWithTrackingId:[OCMArg any]]).andReturn(mockRequestModel);

    [self.deepLink trackDeepLinkWith:userActivity
                       sourceHandler:nil
                 withCompletionBlock:completionBlock];

    OCMVerify([self.mockRequestFactory createDeepLinkRequestModelWithTrackingId:@"1_2_3_4_5"]);
    OCMVerify([self.mockRequestManager submitRequestModel:mockRequestModel
                                      withCompletionBlock:completionBlock]);
}


@end
