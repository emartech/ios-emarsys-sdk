//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import "EMSQueueDelegator.h"
#import "EMSDispatchWaiter.h"

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

- (void)proxyWithTargetObject:(id)object {
    NSParameterAssert(object);
    _object = object;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation retainArguments];
    if ([self.emptyTarget respondsToSelector:[invocation selector]]) {
        BOOL isVoid = strcmp(invocation.methodSignature.methodReturnType, @encode(void)) == 0;
        __weak typeof(self) weakSelf = self;
        if (isVoid) {
            [self.queue addOperationWithBlock:^{
                [invocation setTarget:weakSelf.object];
                [invocation invoke];
            }];
        } else {
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                [invocation setTarget:weakSelf.object];
                [invocation invoke];
            }];
            [self.queue addOperations:@[operation]
                    waitUntilFinished:YES];
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.emptyTarget methodSignatureForSelector:sel];
}

@end
