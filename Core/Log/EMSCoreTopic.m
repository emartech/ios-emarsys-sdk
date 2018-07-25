//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSCoreTopic.h"

@interface EMSCoreTopic ()

@property(nonatomic, strong) NSString *topicTag;

- (instancetype)initWithTag:(NSString *)tag;

@end

@implementation EMSCoreTopic

- (instancetype)initWithTag:(NSString *)tag {
    if (self = [super init]) {
        _topicTag = tag;
    }
    return self;
}

+ (id <EMSLogTopicProtocol>)networkingTopic {
    return [[EMSCoreTopic alloc] initWithTag:@"ems_networking"];
}

+ (id <EMSLogTopicProtocol>)connectivityTopic {
    return [[EMSCoreTopic alloc] initWithTag:@"ems_connectivity"];
}

+ (id <EMSLogTopicProtocol>)offlineTopic {
    return [[EMSCoreTopic alloc] initWithTag:@"ems_offline"];
}

@end