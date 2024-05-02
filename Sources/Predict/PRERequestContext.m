//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "PRERequestContext.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSDeviceInfo.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"

@implementation PRERequestContext

- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider
                               merchantId:(NSString *)merchantId
                               deviceInfo:(EMSDeviceInfo *)deviceInfo {
    NSParameterAssert(timestampProvider);
    NSParameterAssert(uuidProvider);
    NSParameterAssert(deviceInfo);
    if (self = [super init]) {
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSPredictSuiteName];
        _contactFieldValue = [defaults objectForKey:kEMSCustomerId];
        _contactFieldId = [defaults objectForKey:kEMSContactFieldId];
        _visitorId = [defaults objectForKey:kEMSVisitorId];
        _xp = [defaults objectForKey:kEMSXp];
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
        _deviceInfo = deviceInfo;
        _merchantId = merchantId;
    }
    return self;
}

- (void)setContactFieldId:(NSNumber *)contactFieldId {
    _contactFieldId = contactFieldId;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSPredictSuiteName];
    [userDefaults setObject:contactFieldId
                     forKey:kEMSContactFieldId];
    [userDefaults synchronize];
}

- (void)setContactFieldValue:(NSString *)contactFieldValue {
    _contactFieldValue = contactFieldValue;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSPredictSuiteName];
    [userDefaults setObject:contactFieldValue
                     forKey:kEMSCustomerId];
    [userDefaults synchronize];
}

- (void)setVisitorId:(NSString *)visitorId {
    _visitorId = visitorId;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSPredictSuiteName];
    [userDefaults setObject:visitorId
                     forKey:kEMSVisitorId];
    [userDefaults synchronize];
}

- (void)setXp:(NSString *)xp {
    _xp = xp;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSPredictSuiteName];
    [userDefaults setObject:xp
                     forKey:kEMSXp];
    [userDefaults synchronize];
}

- (void)setMerchantId:(NSString *)merchantId {
    _merchantId = merchantId;
    if (merchantId) {
        [MEExperimental enableFeature:EMSInnerFeature.predict];
    } else {
        [MEExperimental disableFeature:EMSInnerFeature.predict];
    }
}

- (void)reset {
    self.contactFieldId = nil;
    self.contactFieldValue = nil;
}

@end
