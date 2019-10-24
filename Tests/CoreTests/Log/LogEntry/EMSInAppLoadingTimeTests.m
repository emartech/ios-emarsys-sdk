//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSInAppLoadingTime.h"
#import "NSDate+EMSCore.h"

@interface EMSInAppLoadingTimeTests : XCTestCase

@property(nonatomic, strong) MEInAppMessage *message;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSInAppLoadingTime *loadingTime;
@property(nonatomic, strong) NSDate *responseTimestamp;
@property(nonatomic, strong) NSDate *timestamp;

@end

@implementation EMSInAppLoadingTimeTests

- (void)setUp {
    _responseTimestamp = [NSDate date];
    _timestamp = [NSDate dateWithTimeInterval:60.0
                                    sinceDate:self.responseTimestamp];
    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"campaignId": @"campaignId123", @"html": @"<html></html>"}}
                                                   options:0
                                                     error:nil];
    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);
    EMSResponseModel *response = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                      headers:@{}
                                                                         body:body
                                                                 requestModel:requestModel
                                                                    timestamp:self.responseTimestamp];
    _timestampProvider = OCMClassMock([EMSTimestampProvider class]);
    OCMStub(self.timestampProvider.provideTimestamp).andReturn(self.timestamp);
    OCMStub(requestModel.requestId).andReturn(@"requestId123");

    _message = [[MEInAppMessage alloc] initWithResponse:response];
    _loadingTime = [[EMSInAppLoadingTime alloc] initWithInAppMessage:self.message
                                                   timestampProvider:self.timestampProvider];
}

- (void)testInit_shouldNotAccept_nilMessage {
    @try {
        [[EMSInAppLoadingTime alloc] initWithInAppMessage:nil
                                        timestampProvider:OCMClassMock([EMSTimestampProvider class])];
        XCTFail(@"Expected Exception when message is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: message");
    }
}

- (void)testInit_shouldNotAccept_nilTimestampProvider {
    @try {
        [[EMSInAppLoadingTime alloc] initWithInAppMessage:OCMClassMock([MEInAppMessage class])
                                        timestampProvider:nil];
        XCTFail(@"Expected Exception when timestampProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: timestampProvider");
    }
}

- (void)testTopic {
    XCTAssertEqualObjects(self.loadingTime.topic, @"log_inapp_loading_time");
}

- (void)testData_when_requestIdAvailable {
    NSDictionary *expectedData = @{
            @"request_id": @"requestId123",
            @"campaign_id": @"campaignId123",
            @"duration": @60000,
            @"start": [self.responseTimestamp numberValueInMillis],
            @"end": [self.timestamp numberValueInMillis],
            @"source": @"customEvent"
    };
    XCTAssertEqualObjects(self.loadingTime.data, expectedData);
}

- (void)testData_when_requestIdNotAvailable {
    _loadingTime = [[EMSInAppLoadingTime alloc] initWithInAppMessage:[[MEInAppMessage alloc] initWithCampaignId:@"campaignId456"
                                                                                                            sid:nil
                                                                                                            url:nil
                                                                                                           html:@"<HTML></HTML>"
                                                                                              responseTimestamp:self.responseTimestamp]
                                                   timestampProvider:self.timestampProvider];

    NSDictionary *expectedData = @{
            @"campaign_id": @"campaignId456",
            @"duration": @60000,
            @"start": [self.responseTimestamp numberValueInMillis],
            @"end": [self.timestamp numberValueInMillis],
            @"source": @"push"
    };
    XCTAssertEqualObjects(self.loadingTime.data, expectedData);
}

@end
