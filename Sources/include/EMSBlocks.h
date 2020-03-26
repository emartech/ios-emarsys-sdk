//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSInboxResult.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^EMSCompletion)(void);

typedef void (^EMSCompletionBlock)(NSError *_Nullable error);

typedef void (^EMSSourceHandler)(NSString *source);

typedef void (^EMSInboxMessageResultBlock)(EMSInboxResult *_Nullable inboxResult, NSError *_Nullable error);

NS_ASSUME_NONNULL_END