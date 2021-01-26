//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSStorage.h"
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
                             deviceInfo:(EMSDeviceInfo *)deviceInfo
                                storage:(EMSStorage *)storage {
    NSParameterAssert(uuidProvider);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(deviceInfo);
    NSParameterAssert(storage);
    if (self = [super init]) {
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
        _deviceInfo = deviceInfo;
        _contactFieldId = contactFieldId;
        _applicationCode = applicationCode;
        _storage = storage;
        _clientState = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kCLIENT_STATE];
        _contactToken = [storage stringForKey:kCONTACT_TOKEN];
        _refreshToken = [storage stringForKey:kREFRESH_TOKEN];
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
    [self.storage setString:contactToken
                     forKey:kCONTACT_TOKEN];
}

- (void)setRefreshToken:(NSString *)refreshToken {
    _refreshToken = refreshToken;
    [self.storage setString:refreshToken
                     forKey:kREFRESH_TOKEN];
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