//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Social/Social.h>
#import "EMSOfflineQueueSize.h"

@interface EMSOfflineQueueSize ()

@property(nonatomic, strong) NSDictionary<NSString *, id> *data;

@end

@implementation EMSOfflineQueueSize

- (instancetype)initWithQueueSize:(NSUInteger)queueSize {
    if (self = [super init]) {
        _data = @{
            @"offline_queue_size": @(queueSize)
        };
    }
    return self;
}

- (NSString *)topic {
    return @"log_offline_queue_size";
}

@end