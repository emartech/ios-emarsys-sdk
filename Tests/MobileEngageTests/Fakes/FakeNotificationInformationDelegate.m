//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "FakeNotificationInformationDelegate.h"

@interface FakeNotificationInformationDelegate()

@property(nonatomic, strong) CallerQueueBlock callerQueueBlock;

@end

@implementation FakeNotificationInformationDelegate

- (instancetype)initWithCallerQueueBlock:(CallerQueueBlock)callerQueueBlock {
    if (self = [super init]) {
        _callerQueueBlock = callerQueueBlock;
    }
    return self;
}

- (void)didReceiveNotificationInformation:(EMSNotificationInformation *)notificationInformation {
    if (self.callerQueueBlock) {
        self.callerQueueBlock([NSOperationQueue currentQueue]);
    }
}

@end