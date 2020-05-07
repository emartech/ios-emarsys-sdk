//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import "EMSQueueDelegator.h"
#import "EMSDispatchWaiter.h"

@interface EMSQueueDelegator ()

@property(nonatomic, strong) id object;
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) EMSDispatchWaiter *dispatchWaiter;

@end

@implementation EMSQueueDelegator

- (void)proxyWithTargetObject:(id)object
                        queue:(NSOperationQueue *)queue
               dispatchWaiter:(EMSDispatchWaiter *)dispatchWaiter {
    NSParameterAssert(object);
    NSParameterAssert(queue);
    NSParameterAssert(dispatchWaiter);
    _object = object;
    _queue = queue;
    _dispatchWaiter = dispatchWaiter;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation retainArguments];

    if ([self.object respondsToSelector:[invocation selector]]) {
        BOOL isVoid = strcmp(invocation.methodSignature.methodReturnType, @encode(void)) == 0;
        if (!isVoid) {
            [self.dispatchWaiter enter];
        }
        __weak typeof(self) weakSelf = self;
        [self.queue addOperationWithBlock:^{
            [invocation setTarget:weakSelf.object];

            [invocation invoke];
            if (!isVoid) {
                [weakSelf.dispatchWaiter exit];
            }
        }];
        if (!isVoid) {
            [self.dispatchWaiter waitWithInterval:5];
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.object methodSignatureForSelector:sel];
}

@end
