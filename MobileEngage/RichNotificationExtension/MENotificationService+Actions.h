//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MENotificationService.h"

typedef void(^ActionsCompletionHandler)(UNNotificationCategory *category);

@interface MENotificationService (Actions)

- (void)createCategoryForContent:(UNMutableNotificationContent *)content
               completionHandler:(ActionsCompletionHandler)completionHandler;

@end