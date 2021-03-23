//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSNotificationInformationDelegate.h"

typedef void (^CallerQueueBlock)(NSOperationQueue *callerQueue);

@interface FakeNotificationInformationDelegate : NSObject <EMSNotificationInformationDelegate>

- (instancetype)initWithCallerQueueBlock:(CallerQueueBlock)callerQueueBlock;

@end