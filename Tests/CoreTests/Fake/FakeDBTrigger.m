//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "FakeDBTrigger.h"

@interface FakeDBTrigger ()
@property(nonatomic, strong) XCTestExpectation *expectation;
@property(nonatomic, strong) TriggerAction triggerAction;
@end

@implementation FakeDBTrigger

- (instancetype)initWithExpectation:(XCTestExpectation *)expectation {
    if (self = [super init]) {
        _expectation = expectation;
    }
    return self;
}

- (instancetype)initWithExpectation:(XCTestExpectation *)expectation
                      triggerAction:(TriggerAction)triggerAction {
    if ([self initWithExpectation:expectation]) {
        _triggerAction = triggerAction;
    }
    return self;
}

- (void)trigger {
    if (self.triggerAction) {
        self.triggerAction();
    }
    [self.expectation fulfill];
}

@end