//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSLogEntryProtocol.h"

@class EMSResponseModel;

@interface EMSNetworkingTime: NSObject<EMSLogEntryProtocol>

-(instancetype)initWithResponseModel:(EMSResponseModel *)responseModel
                           startDate:(NSDate *)startDate;

@end