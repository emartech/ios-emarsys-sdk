//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSConfig.h"
#import "EMSTimestampProvider.h"

@class EMSUUIDProvider;
@class EMSDeviceInfo;

#define kEMSSuiteName @"com.emarsys.mobileengage"
#define kMEID @"kMEID"
#define kMEID_SIGNATURE @"kMEID_SIGNATURE"
#define kCLIENT_STATE @"kCLIENT_STATE"
#define kCONTACT_TOKEN @"kCONTACT_TOKEN"
#define kREFRESH_TOKEN @"kREFRESH_TOKEN"
#define kCONTACT_FIELD_VALUE @"kCONTACT_FIELD_VALUE"

@interface MERequestContext : NSObject

NS_ASSUME_NONNULL_BEGIN

@property(nonatomic, strong, nullable) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong, nullable) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong, nullable) EMSDeviceInfo *deviceInfo;
@property(nonatomic, strong, nullable) NSNumber *contactFieldId;
@property(nonatomic, strong, nullable) NSString *contactFieldValue;
@property(nonatomic, strong, nullable) NSString *clientState;
@property(nonatomic, strong, nullable) NSString *contactToken;
@property(nonatomic, strong, nullable) NSString *refreshToken;
@property(nonatomic, strong, nullable) NSString *applicationCode;

- (instancetype)initWithApplicationCode:(NSString *)applicationCode
                         contactFieldId:(NSNumber *)contactFieldId
                           uuidProvider:(EMSUUIDProvider *)uuidProvider
                      timestampProvider:(EMSTimestampProvider *)timestampProvider
                             deviceInfo:(EMSDeviceInfo *)deviceInfo;

- (void)reset;

NS_ASSUME_NONNULL_END

@end