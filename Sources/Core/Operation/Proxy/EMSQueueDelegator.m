//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import "EMSQueueDelegator.h"
#import "EMSDispatchWaiter.h"

@interface EMSQueueDelegator ()

@property(nonatomic, strong) id emptyTarget;
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) EMSDispatchWaiter *dispatchWaiter;

@end

@implementation EMSQueueDelegator

- (void)setupWithQueue:(NSOperationQueue *)queue
           emptyTarget:(id)emptyTarget
        dispatchWaiter:(EMSDispatchWaiter *)dispatchWaiter {
    NSParameterAssert(queue);
    NSParameterAssert(emptyTarget);
    NSParameterAssert(dispatchWaiter);
    _queue = queue;
    _emptyTarget = emptyTarget;
    _dispatchWaiter = dispatchWaiter;
}

- (void)proxyWithTargetObject:(id)object {
    NSParameterAssert(object);
    _object = object;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation retainArguments];
    if ([self.emptyTarget respondsToSelector:[invocation selector]]) {
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
    return [self.emptyTarget methodSignatureForSelector:sel];
}

@end
