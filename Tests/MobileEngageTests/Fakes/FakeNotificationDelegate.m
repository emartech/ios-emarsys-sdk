//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "FakeNotificationDelegate.h"


@implementation FakeNotificationDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    if (self.willPresentBlock) {
        self.willPresentBlock([NSOperationQueue currentQueue]);
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    if (self.didReceiveBlock) {
        self.didReceiveBlock([NSOperationQueue currentQueue]);
    }
}
@end