//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MEIAMJSResultBlock)(NSDictionary<NSString *, NSObject *> *result);

@protocol MEIAMJSCommandProtocol <NSObject>

+ (NSString *)commandName;

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock;

@end