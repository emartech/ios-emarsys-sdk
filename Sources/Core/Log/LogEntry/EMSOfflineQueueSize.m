//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSOfflineQueueSize.h"

@interface EMSOfflineQueueSize ()

@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *data;

@end

@implementation EMSOfflineQueueSize

- (instancetype)initWithQueueSize:(NSUInteger)queueSize {
    if (self = [super init]) {
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];
        mutableData[@"offlineQueueSize"] = [NSString stringWithFormat:@"%@", @(queueSize)];
        _data = [NSDictionary dictionaryWithDictionary:mutableData];
    }
    return self;
}

- (NSString *)topic {
    return @"log_offline_queue_size";
}

@end
