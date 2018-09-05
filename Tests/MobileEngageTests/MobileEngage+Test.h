//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngage.h"

@class MobileEngageInternal;

NS_ASSUME_NONNULL_BEGIN

@interface MobileEngage (Test)

@property (class, nonatomic, strong) MEInApp *inApp;

+ (void)setupWithMobileEngageInternal:(MobileEngageInternal *)mobileEngageInternal
                               config:(EMSConfig *)config
                        launchOptions:(nullable NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END