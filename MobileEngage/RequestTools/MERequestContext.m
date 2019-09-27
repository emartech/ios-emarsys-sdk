//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "MERequestContext.h"
#import "EMSDeviceInfo.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"

@implementation MERequestContext

- (instancetype)initWithApplicationCode:(NSString *)applicationCode
                         contactFieldId:(NSNumber *)contactFieldId
                           uuidProvider:(EMSUUIDProvider *)uuidProvider
                      timestampProvider:(EMSTimestampProvider *)timestampProvider
                             deviceInfo:(EMSDeviceInfo *)deviceInfo {
    NSParameterAssert(uuidProvider);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(deviceInfo);
    if (self = [super init]) {
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
        _deviceInfo = deviceInfo;
        _contactFieldId = contactFieldId;
        _applicationCode = applicationCode;
        _clientState = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kCLIENT_STATE];
        _contactToken = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kCONTACT_TOKEN];
        _refreshToken = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kREFRESH_TOKEN];
        _contactFieldValue = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kCONTACT_FIELD_VALUE];
    }
    return self;
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

- (void)setApplicationCode:(NSString *)applicationCode {
    _applicationCode = applicationCode;
    if (applicationCode) {
        [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
    } else {
        [MEExperimental disableFeature:EMSInnerFeature.mobileEngage];
    }
}

- (void)reset {
    self.contactFieldValue = nil;
    self.contactToken = nil;
    self.refreshToken = nil;
}

@end