//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSNotificationService.h"
#import "EMSNotificationService+PushToInApp.h"
#import "EMSDictionaryValidator.h"

@implementation EMSNotificationService (PushToInApp)

- (void)createUserInfoWithInAppForContent:(UNMutableNotificationContent *)content
                           withDownloader:(MEDownloader *)downloader
                        completionHandler:(PushToInAppCompletionHandler)completionHandler {
    NSParameterAssert(downloader);
    NSDictionary *pushToInAppDict = [self extractPushToInAppFromContent:content];
    if (pushToInAppDict) {
        [downloader downloadFileFromUrl:[NSURL URLWithString:pushToInAppDict[@"url"]]
                      completionHandler:^(NSURL *destinationUrl, NSError *error) {
                          if (!error) {
                              NSError *dataCreatingError;
                              NSData *pushToInAppData = [NSData dataWithContentsOfURL:destinationUrl
                                                                              options:NSDataReadingMappedIfSafe
                                                                                error:&dataCreatingError];
                              NSDictionary *contentDict = [self extendDictionary:content.userInfo
                                                                   withInAppData:pushToInAppData];
                              if (!dataCreatingError) {
                                  if (completionHandler) {
                                      completionHandler(contentDict);
                                      return;
                                  }
                              }
                          }

                          if (completionHandler) {
                              completionHandler(nil);
                          }
                      }];
    } else {
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

- (NSDictionary *)extendDictionary:(NSDictionary *)userInfo withInAppData:(NSData *)pushToInAppData {
    NSMutableDictionary *contentDict = [userInfo mutableCopy];
    NSMutableDictionary *emsDict = [contentDict[@"ems"] mutableCopy];
    NSMutableDictionary *inappDict = [emsDict[@"inapp"] mutableCopy];
    inappDict[@"inAppData"] = pushToInAppData;
    emsDict[@"inapp"] = inappDict;
    contentDict[@"ems"] = emsDict;
    return [NSDictionary dictionaryWithDictionary:contentDict];
}

- (NSDictionary *)extractPushToInAppFromContent:(UNMutableNotificationContent *)content {
    NSDictionary *result;
    NSArray *emsErrors = [content.userInfo validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"ems"
                           withType:[NSDictionary class]];
    }];
    if ([emsErrors count] == 0) {
        NSDictionary *ems = content.userInfo[@"ems"];
        NSArray *pushToInAppErrors = [ems validate:^(EMSDictionaryValidator *validate) {
            [validate valueExistsForKey:@"inapp"
                               withType:[NSDictionary class]];
        }];
        if ([pushToInAppErrors count] == 0) {
            NSDictionary *inApp = ems[@"inapp"];
            NSArray *inAppErrors = [inApp validate:^(EMSDictionaryValidator *validate) {
                [validate valueExistsForKey:@"campaign_id"
                                   withType:[NSString class]];
                [validate valueExistsForKey:@"url"
                                   withType:[NSString class]];
            }];
            if ([inAppErrors count] == 0) {
                result = inApp;
            }
        }
    }
    return result;
}
@end
