//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSConfig;

#define kEMSPredictSuiteName @"com.emarsys.predict"
#define kEMSCustomerId @"customerId"

@interface PRERequestContext : NSObject

@property(nonatomic, strong) NSString *customerId;

- (instancetype)initWithConfig:(EMSConfig *)config;


@end