//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"
#import "EMSRequestModelRepositoryProtocol.h"
#import "EMSShardRepositoryProtocol.h"
#import "EMSLogRepositoryProtocol.h"

@class EMSRequestModel;

NS_ASSUME_NONNULL_BEGIN

@interface EMSRequestManager : NSObject

@property(nonatomic, readonly) id <EMSRequestModelRepositoryProtocol> repository;
@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *additionalHeaders;

+ (instancetype)managerWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                             errorBlock:(nullable CoreErrorBlock)errorBlock
                      requestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                        shardRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                          logRepository:(id <EMSLogRepositoryProtocol> _Nullable)logRepository;

- (void)submit:(EMSRequestModel *)model;

@end

NS_ASSUME_NONNULL_END