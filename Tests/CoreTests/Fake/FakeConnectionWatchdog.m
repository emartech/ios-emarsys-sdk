//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "FakeConnectionWatchdog.h"

@interface FakeConnectionWatchdog ()

@property(nonatomic, strong) NSMutableArray<NSNumber *> *connectionResponses;
@property(nonatomic, strong) XCTestExpectation *expectation;

@end

@implementation FakeConnectionWatchdog

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
                   connectionResponses:(NSArray *)connectionResponses
                           expectation:(XCTestExpectation *)expectation {
    if (self = [super initWithOperationQueue:operationQueue]) {
        _isConnectedCallCount = @0;
        _connectionResponses = [connectionResponses mutableCopy];
        _expectation = expectation;
    }
    return self;
}

- (BOOL)isConnected {
    _isConnectedCallCount = @([_isConnectedCallCount intValue] + 1);
    BOOL result = [super isConnected];
    if (self.connectionResponses.count > 0) {
        result = [self.connectionResponses[0] boolValue];
        [self.connectionResponses removeObjectAtIndex:0];
    }
    [self.expectation fulfill];
    return result;
}


@end