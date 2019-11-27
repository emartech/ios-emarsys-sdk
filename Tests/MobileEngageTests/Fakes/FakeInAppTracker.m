//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "FakeInAppTracker.h"
#import "MEInAppMessage.h"

@interface FakeInAppTracker ()

@property(nonatomic, strong) XCTestExpectation *displayExpectation;
@property(nonatomic, strong) XCTestExpectation *clickExpectation;

@end

@implementation FakeInAppTracker

- (instancetype)initWithDisplayExpectation:(XCTestExpectation *)displayExpectation
                          clickExpectation:(XCTestExpectation *)clickExpectation {
    if (self = [super init]) {
        _displayExpectation = displayExpectation;
        _clickExpectation = clickExpectation;
    }
    return self;
}

- (void)trackInAppDisplay:(MEInAppMessage *)inAppMessage {
    self.inAppMessage = inAppMessage;
    self.displayOperationQueue = [NSOperationQueue currentQueue];
    [self.displayExpectation fulfill];
}

- (void)trackInAppClick:(MEInAppMessage *)inAppMessage
               buttonId:(NSString *)buttonId {
    self.inAppMessage = inAppMessage;
    self.buttonId = buttonId;
    [self.clickExpectation fulfill];
}

@end