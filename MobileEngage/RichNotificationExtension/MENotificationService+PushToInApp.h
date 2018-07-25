//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MENotificationService.h"
#import "MEDownloader.h"

typedef void(^PushToInAppCompletionHandler)(NSDictionary *userInfo);

@interface MENotificationService (PushToInApp)

- (void)createUserInfoWithInAppForContent:(UNMutableNotificationContent *)content
                           withDownloader:(MEDownloader *)downloader
                        completionHandler:(PushToInAppCompletionHandler)completionHandler;

@end