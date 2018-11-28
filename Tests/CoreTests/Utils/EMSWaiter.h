//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTWaiter.h>


@interface EMSWaiter : NSObject

+ (void)waitForExpectations:(NSArray<XCTestExpectation *> *)expectations;
+ (void)waitForExpectations:(NSArray<XCTestExpectation *> *)expectations timeout:(NSTimeInterval)seconds;

+ (void)waitForTimeout:(NSArray<XCTestExpectation *> *)expectations timeout:(NSTimeInterval)seconds;

@end