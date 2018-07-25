//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol EMSLogTopicProtocol;

@interface EMSLoggerSettings : NSObject

+ (void)enableLogging:(NSArray<id <EMSLogTopicProtocol>> *)topics;

+ (void)enableLoggingForAllTopics;

+ (BOOL)isEnabled:(id <EMSLogTopicProtocol>)topic;

@end