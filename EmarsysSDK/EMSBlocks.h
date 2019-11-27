//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^EMSCompletion)(void);

typedef void (^EMSCompletionBlock)(NSError* _Nullable error);

typedef void (^EMSSourceHandler)(NSString *source);

NS_ASSUME_NONNULL_END