//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSDispatchWaiter;

NS_ASSUME_NONNULL_BEGIN

@interface EMSWrapperChecker : NSObject

@property(nonatomic, readonly) NSString *wrapper;

- (instancetype)initWithOperationQueue:(NSOperationQueue *)queue
                                waiter:(EMSDispatchWaiter *)waiter;
@end

NS_ASSUME_NONNULL_END