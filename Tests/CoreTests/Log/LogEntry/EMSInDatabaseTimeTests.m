//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSInDatabaseTime.h"

@interface EMSInDatabaseTimeTests : XCTestCase
@end

@implementation EMSInDatabaseTimeTests

- (void)testTopic {
    EMSInDatabaseTime *inDatabaseTime = [EMSInDatabaseTime new];

    XCTAssertEqualObjects(inDatabaseTime.topic, @"log_in_database_time");
}

- (void)testData {
    NSString *requestId = @"0123";
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

    EMSInDatabaseTime *inDatabaseTime = [[EMSInDatabaseTime alloc] initWithRequestModel:requestModel
                                                                                endDate:[NSDate dateWithTimeIntervalSince1970:endTime]];

    NSDictionary *expectedData = @{
            @"request_id": requestId,
            @"start": @((int) startTime * 1000),
            @"end": @((int) endTime * 1000),
            @"duration": @9000,
            @"url": url
    };

    XCTAssertEqualObjects(inDatabaseTime.data, expectedData);
}

@end
