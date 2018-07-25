//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MENotificationService.h"
#import "MEDownloader.h"

typedef void(^AttachmentsCompletionHandler)(NSArray<UNNotificationAttachment *> *attachments);

@interface MENotificationService (Attachment)

- (void)createAttachmentForContent:(UNNotificationContent *)content
                    withDownloader:(MEDownloader *)downloader
                 completionHandler:(AttachmentsCompletionHandler)completionHandler;

@end