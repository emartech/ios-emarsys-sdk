//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import "EMSWrapperChecker.h"
#import "EMSDispatchWaiter.h"
#import "EMSStorageProtocol.h"

@interface EMSWrapperChecker ()

@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) EMSDispatchWaiter *waiter;
@property(nonatomic, strong) NSString *innerWrapper;
@property(nonatomic, strong) id<EMSStorageProtocol>storage;

@end

@implementation EMSWrapperChecker

- (instancetype)initWithOperationQueue:(NSOperationQueue *)queue
                                waiter:(EMSDispatchWaiter *)waiter
                               storage:(id<EMSStorageProtocol>)storage {
    NSParameterAssert(queue);
    NSParameterAssert(waiter);
    NSParameterAssert(storage);
    if (self = [super init]) {
        _storage = storage;
        _queue = queue;
        _waiter = waiter;
        _innerWrapper = [self.storage stringForKey:kInnerWrapperKey];
    }
    return self;
}

- (void)setInnerWrapper:(NSString *)innerWrapper {
    _innerWrapper = innerWrapper;
    [self.storage setString:innerWrapper
                     forKey:kInnerWrapperKey];
}

- (NSString *)wrapper {
    if (!self.innerWrapper) {
        self.innerWrapper = @"none";
        [self.waiter enter];
        __weak typeof(self) weakSelf = self;
        __weak __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"EmarsysSDKWrapperExist"
                                                                        object:nil
                                                                         queue:nil
                                                                    usingBlock:^(NSNotification *note) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
            [weakSelf.queue addOperationWithBlock:^{
                weakSelf.innerWrapper = note.object;
                [weakSelf.waiter exit];
            }];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EmarsysSDKWrapperCheckerNotification"
                                                                object:nil];
        });
        [self.waiter waitWithInterval:1];
    }
    return self.innerWrapper;
}

@end
