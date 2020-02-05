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


- (void)testData {
    NSDictionary *expectedData = @{
        @"loadingTimeStart": [self.loadingTimeStart numberValueInMillis],
        @"loadingTimeEnd": [self.loadingTimeEnd numberValueInMillis],
        @"loadingTimeDuration": [self.loadingTimeEnd numberValueInMillisFromDate:self.loadingTimeStart],
        @"onScreenTimeStart": [self.onScreenTimeStart numberValueInMillis],
        @"onScreenTimeEnd": [self.onScreenTimeEnd numberValueInMillis],
        @"onScreenTimeDuration": [self.onScreenTimeEnd numberValueInMillisFromDate:self.onScreenTimeStart],
        @"campaignId": self.inAppMessage.campaignId
    };

    [self.inappLog setOnScreenTimeStart:self.onScreenTimeStart];
    [self.inappLog setOnScreenTimeEnd:self.onScreenTimeEnd];

    XCTAssertEqualObjects(self.inappLog.data, expectedData);
}

@end
