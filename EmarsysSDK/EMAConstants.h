//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class MENotificationInboxStatus;

typedef void(^EMAResultBlock)(NSError *error);
typedef void(^EMASourceHandler)(NSString *source);
typedef void (^MEInboxSuccessBlock)(void);
typedef void (^MEInboxResultBlock)(MENotificationInboxStatus *inboxStatus);
typedef void (^MEInboxResultErrorBlock)(NSError *error);

@interface EMAConstants : NSObject
@end