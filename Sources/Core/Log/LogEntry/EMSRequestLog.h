//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"

@class EMSResponseModel;

@interface EMSRequestLog : NSObject <EMSLogEntryProtocol>

- (instancetype)initWithResponseModel:(EMSResponseModel *)responseModel
                  networkingStartTime:(NSDate *)networkingStartTime;

@end