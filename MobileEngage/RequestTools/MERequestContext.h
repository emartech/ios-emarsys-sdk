//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEAppLoginParameters.h"
#import "EMSConfig.h"
#import "EMSTimestampProvider.h"

@class EMSUUIDProvider;

#define kSuiteName @"com.emarsys.mobileengage"
#define kLastAppLoginPayload @"kLastAppLoginPayload"
#define kMEID @"kMEID"
#define kMEID_SIGNATURE @"kMEID_SIGNATURE"

@interface MERequestContext : NSObject

NS_ASSUME_NONNULL_BEGIN

@property(nonatomic, strong, nullable) NSDictionary *lastAppLoginPayload;
@property(nonatomic, strong, nullable) NSString *meId;
@property(nonatomic, strong, nullable) NSString *meIdSignature;
@property(nonatomic, strong, nullable) MEAppLoginParameters *appLoginParameters;
@property(nonatomic, strong, nullable) EMSConfig *config;
@property(nonatomic, strong, nullable) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong, nullable) EMSUUIDProvider *uuidProvider;

- (instancetype)initWithConfig:(EMSConfig *)config;

- (void)reset;

NS_ASSUME_NONNULL_END

@end