//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSNetworkingTime.h"
#import "EMSRequestModel.h"
#import "EMSResponseModel.h"

@interface EMSNetworkingTimeTests : XCTestCase
@end

@implementation EMSNetworkingTimeTests

- (void)testTopic {
    EMSNetworkingTime *networkingTime = [EMSNetworkingTime new];

    XCTAssertEqualObjects(networkingTime.topic, @"log_networking_time");
}

- (void)testData {
    int statusCode = 203;
    NSString *requestId = @"ID";
    double startTime = 1;
    double endTime = 10;
    NSString *url = @"https://emarsys.com";

    EMSRequestModel *requestModel = [[EMSRequestModel alloc] initWithRequestId:requestId
                                                                     timestamp:[NSDate dateWithTimeIntervalSince1970:startTime]
                                                                        expiry:FLT_MAX
                                                                           url:[NSURL URLWithString:url]
                                                                        method:@"GET"
                                                                       payload:nil
                                                                       headers:@{}
                                                                        extras:nil];

    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithStatusCode:statusCode
                                                                           headers:@{} body:nil requestModel:requestModel timestamp:[NSDate dateWithTimeIntervalSince1970:endTime]];
    
    EMSNetworkingTime *networkingTime = [[EMSNetworkingTime alloc] initWithResponseModel:responseModel
                                                                               startDate:[NSDate dateWithTimeIntervalSince1970:startTime]];
    NSDictionary *expectedData = @{
            @"request_id": requestId,
            @"start": @((int) startTime * 1000),
            @"end": @((int) endTime * 1000),
            @"duration": @9000,
            @"url": url,
            @"status_code": @(statusCode)
    };

    XCTAssertEqualObjects(networkingTime.data, expectedData);
}

@end
