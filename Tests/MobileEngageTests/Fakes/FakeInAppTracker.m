//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "FakeInAppTracker.h"

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


- (void)trackInAppDisplay:(NSString *)campaignId {
    self.campaignId = campaignId;
    [self.displayExpectation fulfill];
}

- (void)trackInAppClick:(NSString *)campaignId
               buttonId:(NSString *)buttonId {
    self.campaignId = campaignId;
    self.buttonId = buttonId;
    [self.clickExpectation fulfill];
}


@end