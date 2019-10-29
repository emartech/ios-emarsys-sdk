//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSTimestampProvider;
@class EMSUUIDProvider;
@class EMSDeviceInfo;

#define kEMSPredictSuiteName @"com.emarsys.predict"
#define kEMSCustomerId @"customerId"
#define kEMSVisitorId @"visitorId"
#define kEMSXp @"xp"

@interface PRERequestContext : NSObject

@property(nonatomic, strong) NSString *customerId;
@property(nonatomic, strong) NSString *visitorId;
@property(nonatomic, strong) NSString *xp;
@property(nonatomic, strong) NSString *merchantId;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) EMSDeviceInfo *deviceInfo;

- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider
                               merchantId:(NSString *)merchantId
                               deviceInfo:(EMSDeviceInfo *)deviceInfo;


@end