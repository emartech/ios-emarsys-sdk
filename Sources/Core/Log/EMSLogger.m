//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "EMSLogger.h"
#import "EMSLogEntryProtocol.h"
#import "EMSShard.h"
#import "EMSLogEndpoints.h"

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

- (void)log:(id <EMSLogEntryProtocol>)entry
      level:(LogLevel)level {
    id url = entry.data[@"url"];
    if (!([entry.topic isEqualToString:@"log_request"] && url && [url isEqualToString:EMSLogEndpoint])) {
        [self.operationQueue addOperationWithBlock:^{
            [self.shardRepository add:[EMSShard makeWithBuilder:^(EMSShardBuilder *builder) {
                    [builder setType:[entry topic]];
                    NSMutableDictionary *mutableData = [entry.data mutableCopy];
                    if (level == LogLevelDebug) {
                        mutableData[@"level"] = @"DEBUG";
                    } else if (level == LogLevelInfo) {
                        mutableData[@"level"] = @"INFO";
                    } else if (level == LogLevelError) {
                        mutableData[@"level"] = @"ERROR";
                    }
                    [builder addPayloadEntries:[NSDictionary dictionaryWithDictionary:mutableData]];
                }
                                              timestampProvider:self.timestampProvider
                                                   uuidProvider:self.uuidProvider]];

        }];
    } else {
        return;
    }
}

@end
