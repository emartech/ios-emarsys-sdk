//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSLoggerSettings.h"
#import "EMSLogger.h"

@implementation EMSLoggerSettings

static NSMutableSet<NSString *> *_topics;
static BOOL _allEnabled;

+ (void)enableLogging:(NSArray<id <EMSLogTopicProtocol>> *)topics {
    if (!_topics) {
        _topics = [NSMutableSet new];
    }
    for (id <EMSLogTopicProtocol> topic in topics) {
        [_topics addObject:topic.topicTag];
    }
}

+ (void)enableLoggingForAllTopics {
    _allEnabled = YES;
}

+ (BOOL)isEnabled:(id <EMSLogTopicProtocol>)topic {
    return _allEnabled || [_topics containsObject:topic.topicTag];
}

@end
