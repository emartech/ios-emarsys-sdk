//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngageInternal.h"

@class EMSRequestManager;

NS_ASSUME_NONNULL_BEGIN
@interface MobileEngageInternal (Private)

- (void)setupWithRequestManager:(EMSRequestManager *)requestManager
                         config:(nonnull MEConfig *)config
                  launchOptions:(NSDictionary *)launchOptions
                 requestContext:(MERequestContext *)requestContext;

@end

NS_ASSUME_NONNULL_END