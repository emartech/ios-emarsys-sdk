//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSInAppLog.h"
#import "MEInAppMessage.h"
#import "NSDate+EMSCore.h"

@interface EMSInAppLogTests : XCTestCase

@property(nonatomic, strong) EMSInAppLog *inappLog;
@property(nonatomic, strong) MEInAppMessage *inAppMessage;
@property(nonatomic, strong) NSDate *loadingTimeStart;
@property(nonatomic, strong) NSDate *loadingTimeEnd;
@property(nonatomic, strong) NSDate *onScreenTimeStart;
@property(nonatomic, strong) NSDate *onScreenTimeEnd;

@end

@implementation EMSInAppLogTests

- (void)setUp {
    _loadingTimeStart = [NSDate date];
    _loadingTimeEnd = [NSDate dateWithTimeInterval:60.0
                                         sinceDate:self.loadingTimeStart];
    _onScreenTimeStart = [NSDate dateWithTimeInterval:60.0
                                            sinceDate:self.loadingTimeEnd];
    _onScreenTimeEnd = [NSDate dateWithTimeInterval:60.0
                                          sinceDate:self.onScreenTimeStart];

    _inAppMessage = [[MEInAppMessage alloc] initWithCampaignId:@"testCampaignId"
                                                           sid:nil
                                                           url:nil
                                                          html:@"<html></html>"
                                             responseTimestamp:self.loadingTimeStart];

    _inappLog = [[EMSInAppLog alloc] initWithMessage:self.inAppMessage
                                      loadingTimeEnd:self.loadingTimeEnd];
}

- (void)testInit_message_mustNotBeNil {
    @try {
        [[EMSInAppLog alloc] initWithMessage:nil
                              loadingTimeEnd:[NSDate date]];
        XCTFail(@"Expected Exception when message is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: message");
    }
}

- (void)testInit_loadingTimeEnd_mustNotBeNil {
    @try {
        [[EMSInAppLog alloc] initWithMessage:OCMClassMock([MEInAppMessage class])
                              loadingTimeEnd:nil];
        XCTFail(@"Expected Exception when loadingTimeEnd is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: loadingTimeEnd");
    }
}

- (void)testTopic {
    XCTAssertEqualObjects(self.inappLog.topic, @"log_inapp_metrics");
}

- (void)testSetOnScreenTimeStart_mustNotBeNil {

    @try {
        [self.inappLog setOnScreenTimeStart:nil];
        XCTFail(@"Expected Exception when onScreenTimeStart is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: onScreenTimeStart");
    }
}

- (void)testSetOnScreenTimeEnd_mustNotBeNil {

    @try {
        [self.inappLog setOnScreenTimeEnd:nil];
        XCTFail(@"Expected Exception when onScreenTimeEnd is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: onScreenTimeEnd");
    }
}


- (void)testData_onPushTriggeredInAppLog {
    [self.inappLog setOnScreenTimeStart:self.onScreenTimeStart];
    [self.inappLog setOnScreenTimeEnd:self.onScreenTimeEnd];

    XCTAssertNotNil(self.inappLog.data[@"requestId"]);
    XCTAssertEqualObjects(self.inappLog.data[@"loadingTimeStart"], ([NSString stringWithFormat:@"%@", [self.loadingTimeStart numberValueInMillis]]));
    XCTAssertEqualObjects(self.inappLog.data[@"loadingTimeEnd"], ([NSString stringWithFormat:@"%@", [self.loadingTimeEnd numberValueInMillis]]));
    XCTAssertEqualObjects(self.inappLog.data[@"loadingTimeDuration"], ([NSString stringWithFormat:@"%@", [self.loadingTimeEnd numberValueInMillisFromDate:self.loadingTimeStart]]));
    XCTAssertEqualObjects(self.inappLog.data[@"onScreenTimeStart"], ([NSString stringWithFormat:@"%@", [self.onScreenTimeStart numberValueInMillis]]));
    XCTAssertEqualObjects(self.inappLog.data[@"onScreenTimeEnd"], ([NSString stringWithFormat:@"%@", [self.onScreenTimeEnd numberValueInMillis]]));
    XCTAssertEqualObjects(self.inappLog.data[@"onScreenTimeDuration"], ([NSString stringWithFormat:@"%@", [self.onScreenTimeEnd numberValueInMillisFromDate:self.onScreenTimeStart]]));
    XCTAssertEqualObjects(self.inappLog.data[@"campaignId"], self.inAppMessage.campaignId);
}


- (void)testData_onCustomEventTriggeredInAppLog {
    EMSResponseModel *mockResponseModel = OCMClassMock([EMSResponseModel class]);
    EMSRequestModel *mockRequestModel = OCMClassMock([EMSRequestModel class]);

    OCMStub([mockRequestModel requestId]).andReturn(@"testRequestId");
    OCMStub([mockResponseModel requestModel]).andReturn(mockRequestModel);
    OCMStub([mockResponseModel timestamp]).andReturn(self.loadingTimeStart);
    OCMStub([mockResponseModel parsedBody]).andReturn(@{@"message": @{@"campaignId": @"testCampaignId"}});

    MEInAppMessage *customEventTriggeredInAppMessage = [[MEInAppMessage alloc] initWithResponse:mockResponseModel];


    EMSInAppLog *inappLog = [[EMSInAppLog alloc] initWithMessage:customEventTriggeredInAppMessage
                                                  loadingTimeEnd:self.loadingTimeEnd];
    NSDictionary *expectedData = @{
            @"requestId": @"testRequestId",
            @"loadingTimeStart": ([NSString stringWithFormat:@"%@", [self.loadingTimeStart numberValueInMillis]]),
            @"loadingTimeEnd": ([NSString stringWithFormat:@"%@", [self.loadingTimeEnd numberValueInMillis]]),
            @"loadingTimeDuration": ([NSString stringWithFormat:@"%@", [self.loadingTimeEnd numberValueInMillisFromDate:self.loadingTimeStart]]),
            @"onScreenTimeStart": ([NSString stringWithFormat:@"%@", [self.onScreenTimeStart numberValueInMillis]]),
            @"onScreenTimeEnd": ([NSString stringWithFormat:@"%@", [self.onScreenTimeEnd numberValueInMillis]]),
            @"onScreenTimeDuration": ([NSString stringWithFormat:@"%@", [self.onScreenTimeEnd numberValueInMillisFromDate:self.onScreenTimeStart]]),
            @"campaignId": self.inAppMessage.campaignId
    };

    [inappLog setOnScreenTimeStart:self.onScreenTimeStart];
    [inappLog setOnScreenTimeEnd:self.onScreenTimeEnd];

    XCTAssertEqualObjects(inappLog.data, expectedData);
}

@end
