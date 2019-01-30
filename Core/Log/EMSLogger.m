//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "EMSLogger.h"
#import "EMSLogEntryProtocol.h"
#import "EMSShard.h"

@interface EMSLogger ()

@property(nonatomic, strong) EMSShardRepository *shardRepository;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;

@end

@implementation EMSLogger

#pragma mark - Public methods

- (instancetype)initWithShardRepository:(id <EMSShardRepositoryProtocol>)shardRepository
                         opertaionQueue:(NSOperationQueue *)operationQueue
                      timestampProvider:(EMSTimestampProvider *)timestampProvider
                           uuidProvider:(EMSUUIDProvider *)uuidProvider {
    NSParameterAssert(shardRepository);
    NSParameterAssert(operationQueue);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(uuidProvider);
    if (self = [super init]) {
        _shardRepository = shardRepository;
        _operationQueue = operationQueue;
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
    }
    return self;
}

- (void)log:(id <EMSLogEntryProtocol>)entry {
    [self.operationQueue addOperationWithBlock:^{
        [self.shardRepository add:[EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                [builder setType:[entry topic]];
                [builder addPayloadEntries:[entry data]];
            }
                                          timestampProvider:self.timestampProvider
                                               uuidProvider:self.uuidProvider]];

    }];
}

@end
