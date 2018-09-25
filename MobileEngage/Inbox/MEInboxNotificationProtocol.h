//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInboxProtocol.h"
#import "EMSInboxProtocol.h"

@protocol MEInboxNotificationProtocol <EMSInboxProtocol>

- (void)addNotification:(EMSNotification *)notification;

@end
