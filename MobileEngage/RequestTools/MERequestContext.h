//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEAppLoginParameters.h"
#import "MEConfig.h"
#import "EMSTimestampProvider.h"

@class EMSUUIDProvider;

#define kSuiteName @"com.emarsys.mobileengage"
#define kLastAppLoginPayload @"kLastAppLoginPayload"
#define kMEID @"kMEID"
#define kMEID_SIGNATURE @"kMEID_SIGNATURE"

@interface MERequestContext : NSObject

@property(nonatomic, strong, nullable) NSDictionary *lastAppLoginPayload;
@property(nonatomic, strong, nullable) NSString *meId;
@property(nonatomic, strong, nullable) NSString *meIdSignature;
@property(nonatomic, strong, nullable) MEAppLoginParameters *appLoginParameters;
@property(nonatomic, strong, nullable) MEConfig *config;
@property(nonatomic, strong, nullable) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong, nullable) EMSUUIDProvider *uuidProvider;

- (instancetype)initWithConfig:(MEConfig *)config;
- (void)reset;

@end