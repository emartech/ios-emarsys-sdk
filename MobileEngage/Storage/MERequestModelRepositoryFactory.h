//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EMSRequestModelRepositoryProtocol;
@class MEInApp;
@class MERequestContext;

@interface MERequestModelRepositoryFactory : NSObject

@property (nonatomic, readonly) MEInApp *inApp;
@property (nonatomic, readonly) MERequestContext *requestContext;

- (instancetype)initWithInApp:(MEInApp *)inApp
               requestContext:(MERequestContext *)requestContext;

- (id <EMSRequestModelRepositoryProtocol>)createWithBatchCustomEventProcessing:(BOOL)batchProcessing;

@end