//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSDispatchWaiter;

NS_ASSUME_NONNULL_BEGIN

@interface EMSQueueDelegator : NSProxy

- (void)proxyWithTargetObject:(id)object
                        queue:(NSOperationQueue *)queue
               dispatchWaiter:(EMSDispatchWaiter *)dispatchWaiter;

@end

NS_ASSUME_NONNULL_END
