//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSInstanceRouter.h"

@class EMSDispatchWaiter;

NS_ASSUME_NONNULL_BEGIN

@interface EMSQueueDelegator : NSProxy

@property(nonatomic, strong) EMSInstanceRouter * instanceRouter;

- (void)setupWithQueue:(NSOperationQueue *)queue
           emptyTarget:(id)emptyTarget;

- (void)proxyWithInstanceRouter:(EMSInstanceRouter *)instanceRouter;

@end

NS_ASSUME_NONNULL_END