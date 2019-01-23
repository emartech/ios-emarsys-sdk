//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"
#import "MEInAppMessage.h"
#import "EMSTimestampProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSInAppLoadingTime : NSObject <EMSLogEntryProtocol>

- (instancetype)initWithInAppMessage:(MEInAppMessage *)message
                   timestampProvider:(EMSTimestampProvider *)timestampProvider;

@end

NS_ASSUME_NONNULL_END