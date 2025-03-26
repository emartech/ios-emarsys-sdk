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
                                                       parsedBody:nil
                                                     requestModel:requestModel
                                                        timestamp:self.responseTimestamp];
    OCMStub(requestModel.requestId).andReturn(@"requestId123");
    OCMStub(requestModel.timestamp).andReturn([NSDate date]);
    NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com"];
    OCMStub(requestModel.url).andReturn(url);

    _requestLog = [[EMSRequestLog alloc] initWithResponseModel:self.responseModel
                                           networkingStartTime:self.timestamp
                                                       headers:nil
                                                       payload:nil];
}

- (void)testInit_responseModel_mustNotBeNil {
    @try {
        [[EMSRequestLog alloc] initWithResponseModel:nil
                                 networkingStartTime:[NSDate date]
                                             headers:nil
                                             payload:nil];
        XCTFail(@"Expected Exception when responseModel is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: responseModel");
    }
}

- (void)testInit_networkingStartTime_mustNotBeNil {
    @try {
        [[EMSRequestLog alloc] initWithResponseModel:OCMClassMock([EMSResponseModel class])
                                 networkingStartTime:nil
                                             headers:nil
                                             payload:nil];
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
        @"statusCode": [NSString stringWithFormat:@"%@", @(self.responseModel.statusCode)],
        @"inDbStart": [NSString stringWithFormat:@"%@", [self.responseModel.requestModel.timestamp numberValueInMillis]],
        @"inDbEnd": [NSString stringWithFormat:@"%@", [self.timestamp numberValueInMillis]],
        @"inDbDuration": [NSString stringWithFormat:@"%@", [self.timestamp numberValueInMillisFromDate:self.responseModel.requestModel.timestamp]],
        @"networkingStart": [NSString stringWithFormat:@"%@", [self.timestamp numberValueInMillis]],
        @"networkingEnd": [NSString stringWithFormat:@"%@", [self.responseModel.timestamp numberValueInMillis]],
        @"networkingDuration": [NSString stringWithFormat:@"%@", [self.responseModel.timestamp numberValueInMillisFromDate:self.timestamp]]
    };

    XCTAssertEqualObjects(self.requestLog.data, expectedData);
}

@end
