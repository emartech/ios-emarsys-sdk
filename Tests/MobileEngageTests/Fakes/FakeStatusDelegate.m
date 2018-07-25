//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "FakeStatusDelegate.h"
#import <XCTest/XCTest.h>

@implementation FakeStatusDelegate {
    XCTestExpectation *_nextExpectation;
}

- (instancetype)init {
    if (self = [super init]) {
        _errors = [NSMutableArray array];
        _successLogs = [NSMutableArray array];
    }
    return self;
}


- (void)mobileEngageErrorHappenedWithEventId:(NSString *)eventId
                                       error:(NSError *)error {
    if ([NSThread isMainThread]) {
        self.errorCount++;
        [self.errors addObject:error];
    }

    if (self.printErrors) {
        NSLog(@"%@", error);
    }
}

- (void)mobileEngageLogReceivedWithEventId:(NSString *)eventId
                                       log:(NSString *)log {
    if ([NSThread isMainThread]) {
        self.successCount++;
        [self.successLogs addObject:log];

        [_nextExpectation fulfill];
    }
}


- (void)waitForNextSuccess {
    _nextExpectation = [[XCTestExpectation alloc] initWithDescription:@"wait"];
    [XCTWaiter waitForExpectations:@[_nextExpectation] timeout:30.0];
}

@end