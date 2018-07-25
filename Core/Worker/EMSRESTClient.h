//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"
#import "EMSRequestModel.h"
#import "EMSLogRepositoryProtocol.h"

@class EMSTimestampProvider;

NS_ASSUME_NONNULL_BEGIN

typedef void (^EMSRestClientCompletionBlock)(BOOL shouldContinue);

@interface EMSRESTClient : NSObject

@property(nonatomic, strong, nullable) id <EMSLogRepositoryProtocol> logRepository;

+ (EMSRESTClient *)clientWithSession:(NSURLSession *)session;

+ (EMSRESTClient *)clientWithSuccessBlock:(CoreSuccessBlock)successBlock
                               errorBlock:(CoreErrorBlock)errorBlock
                            logRepository:(id <EMSLogRepositoryProtocol>)logRepository;

+ (EMSRESTClient *)clientWithSuccessBlock:(CoreSuccessBlock)successBlock
                               errorBlock:(CoreErrorBlock)errorBlock
                                  session:(nullable NSURLSession *)session
                            logRepository:(nullable id <EMSLogRepositoryProtocol>)logRepository
                        timestampProvider:(EMSTimestampProvider *)timestampProvider;

- (void)executeTaskWithRequestModel:(EMSRequestModel *)requestModel
                       successBlock:(CoreSuccessBlock)successBlock
                         errorBlock:(CoreErrorBlock)errorBlock;

- (void)executeTaskWithOfflineCallbackStrategyWithRequestModel:(EMSRequestModel *)requestModel
                                                    onComplete:(EMSRestClientCompletionBlock)onComplete;


@end

NS_ASSUME_NONNULL_END
