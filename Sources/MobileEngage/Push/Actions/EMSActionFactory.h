//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EMSActionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface EMSActionFactory : NSObject

- (nullable id<EMSActionProtocol>)createActionWithActionDictionary:(NSDictionary<NSString *, id> *)action;

@end

NS_ASSUME_NONNULL_END