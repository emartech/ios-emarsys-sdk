//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSNotificationService.h"

typedef void(^ActionsCompletionHandler)(UNNotificationCategory *category);

@interface EMSNotificationService (Actions)

- (void)createCategoryForContent:(UNMutableNotificationContent *)content
               completionHandler:(ActionsCompletionHandler)completionHandler;

@end