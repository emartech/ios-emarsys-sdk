//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <XCTest/XCTestExpectation.h>
#import "EMSDBTriggerProtocol.h"

typedef void (^TriggerAction)(void);

@interface FakeDBTrigger : NSObject <EMSDBTriggerProtocol>

- (instancetype)initWithExpectation:(XCTestExpectation *)expectation;

- (instancetype)initWithExpectation:(XCTestExpectation *)expectation triggerAction:(TriggerAction)triggerAction;
@end