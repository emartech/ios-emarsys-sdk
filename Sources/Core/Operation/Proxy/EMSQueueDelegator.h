//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSDispatchWaiter;

NS_ASSUME_NONNULL_BEGIN

@interface EMSQueueDelegator : NSProxy

@property(nonatomic, strong) id object;

- (void)setupWithQueue:(NSOperationQueue *)queue
           emptyTarget:(id)emptyTarget;

- (void)proxyWithTargetObject:(id)object;

@end

NS_ASSUME_NONNULL_END