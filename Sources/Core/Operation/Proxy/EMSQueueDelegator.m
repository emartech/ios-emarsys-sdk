//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import "EMSQueueDelegator.h"

@interface EMSQueueDelegator ()

@property(nonatomic, strong) id emptyTarget;
@property(nonatomic, strong) NSOperationQueue *queue;

@end

@implementation EMSQueueDelegator

- (void)setupWithQueue:(NSOperationQueue *)queue
           emptyTarget:(id)emptyTarget {
    NSParameterAssert(queue);
    NSParameterAssert(emptyTarget);
    _queue = queue;
    _emptyTarget = emptyTarget;
}

- (void)proxyWithInstanceRouter:(EMSInstanceRouter *)instanceRouter {
    NSParameterAssert(instanceRouter);
    _instanceRouter = instanceRouter;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation retainArguments];
    if ([self.emptyTarget respondsToSelector:[invocation selector]]) {
        BOOL isVoid = strcmp(invocation.methodSignature.methodReturnType, @encode(void)) == 0;
        __weak typeof(self) weakSelf = self;
        if (isVoid) {
            [self.queue addOperationWithBlock:^{
                [invocation setTarget:weakSelf.instanceRouter.instance];
                [invocation invoke];
            }];
        } else {
            if ([self.queue isEqual:[NSOperationQueue currentQueue]]) {
                [invocation setTarget:weakSelf.instanceRouter.instance];
                [invocation invoke];
            } else {
                NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                    [invocation setTarget:weakSelf.instanceRouter.instance];
                    [invocation invoke];
                }];
                [self.queue addOperations:@[operation]
                        waitUntilFinished:YES];
            }
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.emptyTarget methodSignatureForSelector:sel];
}

@end
