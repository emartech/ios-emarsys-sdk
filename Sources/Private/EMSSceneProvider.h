//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMSSceneProvider : NSObject

- (instancetype)initWithApplication:(UIApplication *)application;

- (nullable UIScene *)provideScene API_AVAILABLE(ios(13.0));

@end

NS_ASSUME_NONNULL_END