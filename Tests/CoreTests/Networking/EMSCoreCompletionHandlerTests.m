//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSCoreCompletionHandler.h"

@interface EMSCoreCompletionHandlerTests : XCTestCase

@end

@implementation EMSCoreCompletionHandlerTests

- (void)setUp {
}

- (void)testInit_successBlock_mustNotBeNull {
    @try {
        [[EMSCoreCompletionHandler alloc] initWithSuccessBlock:nil
                                                    errorBlock:^(NSString *requestId, NSError *error) {
                                                    }];
        XCTFail(@"Expected Exception when successBlock is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: successBlock");
    }
}

- (void)testInit_errorBlock_mustNotBeNull {
    @try {
        [[EMSCoreCompletionHandler alloc] initWithSuccessBlock:^(NSString *requestId, EMSResponseModel *response) {
            }
                                                    errorBlock:nil];
        XCTFail(@"Expected Exception when errorBlock is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: errorBlock");
    }
}

@end
