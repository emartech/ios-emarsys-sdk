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
        _lastAppLoginPayload = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] dictionaryForKey:kEMSLastAppLoginPayload];
        _meId = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kMEID];
        _meIdSignature = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kMEID_SIGNATURE];
        _config = config;
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
        _deviceInfo = deviceInfo;
        _contactFieldId = config.contactFieldId;
        _clientState = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kCLIENT_STATE];
    }
    return self;
}

- (void)setLastAppLoginPayload:(NSDictionary *)lastAppLoginPayload {
    _lastAppLoginPayload = lastAppLoginPayload;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults setObject:lastAppLoginPayload
                     forKey:kEMSLastAppLoginPayload];
    [userDefaults synchronize];
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

- (void)reset {
    self.appLoginParameters = nil;
    self.lastAppLoginPayload = nil;
    self.meId = nil;
    self.meIdSignature = nil;
}

@end