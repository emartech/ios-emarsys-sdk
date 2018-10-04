//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobileEngage.h"
#import "EMSSQLiteHelper.h"
#import "EMSNotification.h"

NS_ASSUME_NONNULL_BEGIN

@interface MobileEngage (Private)

+ (NSString *)trackMessageOpenWithInboxMessage:(EMSNotification *)inboxMessage;
+ (EMSSQLiteHelper *)dbHelper;
+ (void)setDbHelper:(EMSSQLiteHelper *)dbHelper;

@end

NS_ASSUME_NONNULL_END