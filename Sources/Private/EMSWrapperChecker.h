//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSDispatchWaiter;
@protocol EMSStorageProtocol;

NS_ASSUME_NONNULL_BEGIN

#define kInnerWrapperKey @"kInnerWrapperKey"

@interface EMSWrapperChecker : NSObject

@property(nonatomic, readonly) NSString *wrapper;

- (instancetype)initWithOperationQueue:(NSOperationQueue *)queue
                                waiter:(EMSDispatchWaiter *)waiter
                               storage:(id<EMSStorageProtocol>)storage;
@end

NS_ASSUME_NONNULL_END
