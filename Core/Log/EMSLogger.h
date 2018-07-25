//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol EMSLogTopicProtocol <NSObject>

- (NSString *)topicTag;

@end

@interface EMSLogger : NSObject

+ (void)logWithTopic:(id <EMSLogTopicProtocol>)topic
             message:(NSString *)message;

@end