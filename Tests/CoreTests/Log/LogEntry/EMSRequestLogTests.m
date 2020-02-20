//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSRequestLog.h"
#import "EMSResponseModel.h"
#import "NSDate+EMSCore.h"

@interface EMSRequestLogTests : XCTestCase

@property(nonatomic, strong) NSDate *responseTimestamp;
@property(nonatomic, strong) NSDate *timestamp;
@property(nonatomic, strong) EMSResponseModel *responseModel;
@property(nonatomic, strong) EMSRequestLog *requestLog;

@end

@implementation EMSRequestLogTests

- (void)setUp {
    _responseTimestamp = [NSDate date];
    _timestamp = [NSDate dateWithTimeInterval:60.0
                                    sinceDate:self.responseTimestamp];
    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"message": @{@"campaignId": @"campaignId123", @"html": @"<html></html>"}}
                                                   options:0
                                                     error:nil];
    EMSRequestModel *requestModel = OCMClassMock([EMSRequestModel class]);
    _responseModel = [[EMSResponseModel alloc] initWithStatusCode:200
                                                          headers:@{}
                                                             body:body
                                                     requestModel:requestModel
                                                        timestamp:self.responseTimestamp];
    OCMStub(requestModel.requestId).andReturn(@"requestId123");
    OCMStub(requestModel.timestamp).andReturn([NSDate date]);
    NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com"];
    OCMStub(requestModel.url).andReturn(url);

    _requestLog = [[EMSRequestLog alloc] initWithResponseModel:self.responseModel
                                           networkingStartTime:self.timestamp];
}

- (void)testInit_responseModel_mustNotBeNil {
    @try {
        [[EMSRequestLog alloc] initWithResponseModel:nil
                                 networkingStartTime:[NSDate date]];
        XCTFail(@"Expected Exception when responseModel is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: responseModel");
    }
}

- (void)testInit_networkingStartTime_mustNotBeNil {
    @try {
        [[EMSRequestLog alloc] initWithResponseModel:OCMClassMock([EMSResponseModel class])
                                 networkingStartTime:nil];
        XCTFail(@"Expected Exception when networkingStartTime is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: networkingStartTime");
    }
}

- (void)testTopic {
    XCTAssertEqualObjects(self.requestLog.topic, @"log_request");
}

- (void)testData {
    NSDictionary *expectedData = @{
        @"requestId": self.responseModel.requestModel.requestId,
        @"url": [self.responseModel.requestModel.url absoluteString],
        @"statusCode": @(self.responseModel.statusCode),
        @"inDbStart": [self.responseModel.requestModel.timestamp numberValueInMillis],
        @"inDbEnd": [self.timestamp numberValueInMillis],
        @"inDbDuration": [self.timestamp numberValueInMillisFromDate:self.responseModel.requestModel.timestamp],
        @"networkingStart": [self.timestamp numberValueInMillis],
        @"networkingEnd": [self.responseModel.timestamp numberValueInMillis],
        @"networkingDuration": [self.responseModel.timestamp numberValueInMillisFromDate:self.timestamp]
    };

    XCTAssertEqualObjects(self.requestLog.data, expectedData);
}

@end
