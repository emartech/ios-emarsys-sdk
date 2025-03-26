//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSStatusLog.h"
#import "NSDictionary+EMSCore.h"

@interface EMSStatusLogTests : XCTestCase

@end

@implementation EMSStatusLogTests

- (void)testInit_shouldNotAccept_nilClass {
    @try {
        [[EMSStatusLog alloc] initWithClass:nil
                                        sel:_cmd
                                 parameters:@{@"key": @"value"}
                                     status:@{}];
        XCTFail(@"Expected exception when klass is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: klass");
    }
}

- (void)testInit_shouldNotAccept_nilSel {
    @try {
        [[EMSStatusLog alloc] initWithClass:[NSObject class]
                                        sel:nil
                                 parameters:@{@"key": @"value"}
                                     status:@{}];
        XCTFail(@"Expected exception when sel is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: sel");
    }
}

- (void)testTopic {
    NSString *result = [[[EMSStatusLog alloc] initWithClass:[NSObject class]
                                                        sel:_cmd
                                                 parameters:nil
                                                     status:@{}] topic];
    XCTAssertEqualObjects(result, @"log_status");
}

- (void)testData {
    NSDictionary *expectedDataDictionary = @{
        @"className": @"NSObject",
        @"methodName": @"testData",
        @"parameters": [@{@"param1": @"value1"} asJSONString] ,
        @"status": [@{@"status1": @"statusValue1"} asJSONString]
    };
    EMSStatusLog *statusLog = [[EMSStatusLog alloc] initWithClass:[NSObject class]
                                                              sel:_cmd
                                                       parameters:@{@"param1": @"value1"}
                                                           status:@{@"status1": @"statusValue1"}];
    XCTAssertEqualObjects(expectedDataDictionary, statusLog.data);
}

@end
