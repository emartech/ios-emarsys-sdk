//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSTimestampProvider.h"


@interface FakeTimestampProvider : EMSTimestampProvider

@property (nonatomic, strong) NSDate *currentDate;

-(instancetype)initWithTimestamps:(NSArray<NSDate *> *) timestamps;

@end