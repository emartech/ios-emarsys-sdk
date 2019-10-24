//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSInAppOnScreenTime.h"
#import "NSDate+EMSCore.h"

@interface EMSInAppOnScreenTimeTests : XCTestCase

@property(nonatomic, strong) EMSInAppOnScreenTime *onScreenTime;
@property(nonatomic, strong) NSDate *showTimestamp;
@property(nonatomic, strong) NSDate *timestamp;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;

@end

@implementation EMSInAppOnScreenTimeTests

- (void)setUp {
    _showTimestamp = [NSDate date];
    _timestamp = [NSDate dateWithTimeInterval:123.0
                                    sinceDate:self.showTimestamp];

    EMSTimestampProvider *timestampProvider = OCMClassMock([EMSTimestampProvider class]);
    OCMStub(timestampProvider.provideTimestamp).andReturn(self.timestamp);

    [[MEInAppMessage alloc] initWithCampaignId:@"campaignId456"
                                           sid:nil
                                           url:nil
                                          html:@"<HTML></HTML>"
                             responseTimestamp:[NSDate date]];

    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"campaignId": @"campaignId456", @"html": @"<html></html>"}}
                                                   options:0
                                                     error:nil];
    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                 requestModel:requestModel
                                                                    timestamp:[NSDate date]];
    _timestampProvider = OCMClassMock([EMSTimestampProvider class]);
    OCMStub(self.timestampProvider.provideTimestamp).andReturn(self.timestamp);
    OCMStub(requestModel.requestId).andReturn(@"requestId456");

    _onScreenTime = [[EMSInAppOnScreenTime alloc] initWithInAppMessage:[[MEInAppMessage alloc] initWithResponse:response]
                                                         showTimestamp:self.showTimestamp
                                                     timestampProvider:timestampProvider];
}

- (void)testInit_shouldNotAccept_nilMessage {
    @try {
        [[EMSInAppOnScreenTime alloc] initWithInAppMessage:nil
                                             showTimestamp:OCMClassMock([NSDate class])
                                         timestampProvider:OCMClassMock([EMSTimestampProvider class])];
        XCTFail(@"Expected Exception when threshold is less then message!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: message");
    }
}

- (void)testInit_shouldNotAccept_nilShowTimestamp {
    @try {
        [[EMSInAppOnScreenTime alloc] initWithInAppMessage:OCMClassMock([NSString class])
                                             showTimestamp:nil
                                         timestampProvider:OCMClassMock([EMSTimestampProvider class])];
        XCTFail(@"Expected Exception when threshold is less then showTimestamp!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: showTimestamp");
    }
}

- (void)testInit_shouldNotAccept_nilTimestampProvider {
    @try {
        [[EMSInAppOnScreenTime alloc] initWithInAppMessage:OCMClassMock([NSString class])
                                             showTimestamp:OCMClassMock([NSDate class])
                                         timestampProvider:nil];
        XCTFail(@"Expected Exception when threshold is less then timestampProvider!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: timestampProvider");
    }
}

- (void)testTopic {
    XCTAssertEqualObjects(self.onScreenTime.topic, @"log_inapp_on_screen_time");
}

- (void)testData_when_requestIdAvailable {
    NSDictionary *expectedData = @{
            @"request_id": @"requestId456",
            @"campaign_id": @"campaignId456",
            @"start": [self.showTimestamp numberValueInMillis],
            @"end": [self.timestamp numberValueInMillis],
            @"duration": @123000,
            @"source": @"customEvent"
    };
    XCTAssertEqualObjects(self.onScreenTime.data, expectedData);
}

- (void)testData_when_requestIdNotAvailable {
    _onScreenTime = [[EMSInAppOnScreenTime alloc] initWithInAppMessage:[[MEInAppMessage alloc] initWithCampaignId:@"campaignId456"
                                                                                                              sid:nil
                                                                                                              url:nil
                                                                                                             html:@"<HTML></HTML>"
                                                                                                responseTimestamp:[NSDate date]]
                                                         showTimestamp:self.showTimestamp
                                                     timestampProvider:self.timestampProvider];

    NSDictionary *expectedData = @{
            @"campaign_id": @"campaignId456",
            @"start": [self.showTimestamp numberValueInMillis],
            @"end": [self.timestamp numberValueInMillis],
            @"duration": @123000,
            @"source": @"push"
    };
    XCTAssertEqualObjects(self.onScreenTime.data, expectedData);
}

@end
