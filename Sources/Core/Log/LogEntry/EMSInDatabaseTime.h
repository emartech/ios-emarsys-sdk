//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"
#import "EMSRequestModel.h"


@interface EMSInDatabaseTime : NSObject <EMSLogEntryProtocol>

- (instancetype)initWithRequestModel:(EMSRequestModel *)requestModel
                             endDate:(NSDate *)endDate;

@end