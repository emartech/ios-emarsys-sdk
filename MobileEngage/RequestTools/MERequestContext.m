//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "MERequestContext.h"
#import "EMSDeviceInfo.h"

@implementation MERequestContext

- (instancetype)initWithConfig:(EMSConfig *)config
                  uuidProvider:(EMSUUIDProvider *)uuidProvider
             timestampProvider:(EMSTimestampProvider *)timestampProvider
                    deviceInfo:(EMSDeviceInfo *)deviceInfo {
    NSParameterAssert(uuidProvider);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(deviceInfo);
    if (self = [super init]) {
        _meId = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kMEID];
        _meIdSignature = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kMEID_SIGNATURE];
        _config = config;
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
        _deviceInfo = deviceInfo;
        _contactFieldId = config.contactFieldId;
        _clientState = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kCLIENT_STATE];
        _contactToken = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kCONTACT_TOKEN];
        _refreshToken = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kREFRESH_TOKEN];
        _contactFieldValue = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kCONTACT_FIELD_VALUE];
    }
    return self;
}

- (void)setMeId:(NSString *)meId {
    _meId = meId;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults setObject:meId
                     forKey:kMEID];
    [userDefaults synchronize];
}

- (void)setMeIdSignature:(NSString *)meIdSignature {
    _meIdSignature = meIdSignature;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults setObject:meIdSignature
                     forKey:kMEID_SIGNATURE];
    [userDefaults synchronize];
}

- (void)setClientState:(NSString *)clientState {
    _clientState = clientState;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults setObject:clientState
                     forKey:kCLIENT_STATE];
    [userDefaults synchronize];
}

- (void)setContactToken:(NSString *)contactToken {
    _contactToken = contactToken;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults setObject:contactToken
                     forKey:kCONTACT_TOKEN];
    [userDefaults synchronize];
}

- (void)setRefreshToken:(NSString *)refreshToken {
    _refreshToken = refreshToken;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults setObject:refreshToken
                     forKey:kREFRESH_TOKEN];
    [userDefaults synchronize];
}

- (void)setContactFieldValue:(NSString *)contactFieldValue {
    _contactFieldValue = contactFieldValue;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults setObject:contactFieldValue
                     forKey:kCONTACT_FIELD_VALUE];
    [userDefaults synchronize];
}

- (void)reset {
    self.meId = nil;
    self.meIdSignature = nil;
}

@end