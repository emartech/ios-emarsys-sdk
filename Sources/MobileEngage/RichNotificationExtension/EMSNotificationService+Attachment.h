//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSNotificationService.h"
#import "MEDownloader.h"

typedef void(^AttachmentsCompletionHandler)(NSArray<UNNotificationAttachment *> *attachments);

@interface EMSNotificationService (Attachment)

- (void)createAttachmentForContent:(UNNotificationContent *)content
                    withDownloader:(MEDownloader *)downloader
                 completionHandler:(AttachmentsCompletionHandler)completionHandler;

@end