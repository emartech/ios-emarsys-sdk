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
#import "EMSStorageProtocol.h"

@interface MERequestContext()

@property(nonatomic, strong, nullable) NSNumber *previousContactFieldId;
@property(nonatomic, strong, nullable) NSString *previousContactFieldValue;
@property(nonatomic, strong, nullable) NSString *previousOpenIdToken;

@end

@implementation MERequestContext

- (instancetype)initWithApplicationCode:(NSString *)applicationCode
                           uuidProvider:(EMSUUIDProvider *)uuidProvider
                      timestampProvider:(EMSTimestampProvider *)timestampProvider
                             deviceInfo:(EMSDeviceInfo *)deviceInfo
                                storage:(id<EMSStorageProtocol>)storage {
    NSParameterAssert(uuidProvider);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(deviceInfo);
    NSParameterAssert(storage);
    if (self = [super init]) {
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
        _deviceInfo = deviceInfo;
        _applicationCode = applicationCode;
        _storage = storage;
        _clientState = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kCLIENT_STATE];
        _contactToken = [storage stringForKey:kCONTACT_TOKEN];
        _refreshToken = [storage stringForKey:kREFRESH_TOKEN];
        _contactFieldValue = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:kCONTACT_FIELD_VALUE];
        _previousContactFieldId = _contactFieldId;
        _previousContactFieldValue = _contactFieldValue;
        _previousOpenIdToken = _openIdToken;
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
    _previousContactFieldValue = _contactFieldValue;
    _contactFieldValue = contactFieldValue;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults setObject:contactFieldValue
                     forKey:kCONTACT_FIELD_VALUE];
    [userDefaults synchronize];
}

-(void)setContactFieldId:(NSNumber *)contactFieldId {
    _previousContactFieldId = _contactFieldId;
    _contactFieldId = contactFieldId;
}

-(void)setOpenIdToken:(NSString *)openIdToken {
    _previousOpenIdToken = _openIdToken;
    _openIdToken = openIdToken;
}

- (void)setApplicationCode:(NSString *)applicationCode {
    _applicationCode = applicationCode;
    if (applicationCode) {
        [MEExperimental enableFeature:EMSInnerFeature.mobileEngage];
        [MEExperimental enableFeature:EMSInnerFeature.eventServiceV4];
    } else {
        [MEExperimental disableFeature:EMSInnerFeature.mobileEngage];
    }
}

- (BOOL)hasContactIdentification {
    return self.openIdToken || self.contactFieldValue;
}

- (void)reset {
    self.contactFieldId = nil;
    self.contactFieldValue = nil;
    self.contactToken = nil;
    self.refreshToken = nil;
    self.openIdToken = nil;
}

- (void)resetPreviousContactValues {
    self.contactFieldId = _previousContactFieldId;
    self.contactFieldValue = _previousContactFieldValue;
    self.openIdToken = _previousOpenIdToken;
}

@end
