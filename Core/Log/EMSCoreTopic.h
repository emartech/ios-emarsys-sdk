//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogger.h"


@interface EMSCoreTopic : NSObject <EMSLogTopicProtocol>

@property(nonatomic, readonly, class) id <EMSLogTopicProtocol> networkingTopic;
@property(nonatomic, readonly, class) id <EMSLogTopicProtocol> connectivityTopic;
@property(nonatomic, readonly, class) id <EMSLogTopicProtocol> offlineTopic;

@end