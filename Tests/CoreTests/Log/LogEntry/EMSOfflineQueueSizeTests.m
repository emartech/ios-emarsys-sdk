//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSOfflineQueueSize.h"

@interface EMSOfflineQueueSizeTests : XCTestCase

@end

@implementation EMSOfflineQueueSizeTests

- (void)testTopic {
    EMSOfflineQueueSize *queueSize = [[EMSOfflineQueueSize alloc] initWithQueueSize:0];
    XCTAssertEqualObjects(queueSize.topic, @"log_offline_queue_size");
}

- (void)testData {
    NSDictionary *expectedData = @{
        @"offline_queue_size": @1,
    };

    EMSOfflineQueueSize *queueSize = [[EMSOfflineQueueSize alloc] initWithQueueSize:1];
    XCTAssertEqualObjects(queueSize.data, expectedData);
}

@end
