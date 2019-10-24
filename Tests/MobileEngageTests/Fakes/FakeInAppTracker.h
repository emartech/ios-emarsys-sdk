//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MEInAppTrackingProtocol.h"
#import <XCTest/XCTest.h>

@interface FakeInAppTracker : NSObject <MEInAppTrackingProtocol>

@property(nonatomic, strong) MEInAppMessage *inAppMessage;
@property(nonatomic, strong) NSString *buttonId;

- (instancetype)initWithDisplayExpectation:(XCTestExpectation *)displayExpectation
                          clickExpectation:(XCTestExpectation *)clickExpectation;

@end