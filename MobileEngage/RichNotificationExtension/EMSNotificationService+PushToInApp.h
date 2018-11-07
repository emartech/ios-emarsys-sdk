//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSNotificationService.h"
#import "MEDownloader.h"

typedef void(^PushToInAppCompletionHandler)(NSDictionary *userInfo);

@interface EMSNotificationService (PushToInApp)

- (void)createUserInfoWithInAppForContent:(UNMutableNotificationContent *)content
                           withDownloader:(MEDownloader *)downloader
                        completionHandler:(PushToInAppCompletionHandler)completionHandler;

@end