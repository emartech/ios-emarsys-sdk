//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol EMSActionProtocol;
@protocol EMSMobileEngageProtocol;
@protocol EMSEventHandler;

NS_ASSUME_NONNULL_BEGIN

@interface EMSActionFactory : NSObject

@property(nonatomic, weak) id<EMSEventHandler> eventHandler;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithApplication:(UIApplication *)application
                       mobileEngage:(id <EMSMobileEngageProtocol>)mobileEngage;

- (nullable id <EMSActionProtocol>)createActionWithActionDictionary:(NSDictionary<NSString *, id> *)action;

@end

NS_ASSUME_NONNULL_END