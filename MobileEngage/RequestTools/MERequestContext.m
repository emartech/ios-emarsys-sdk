//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "MERequestContext.h"

@implementation MERequestContext

- (instancetype)initWithConfig:(EMSConfig *)config {
    if (self = [super init]) {
        _lastAppLoginPayload = [[[NSUserDefaults alloc] initWithSuiteName:kSuiteName] dictionaryForKey:kLastAppLoginPayload];
        _meId = [[[NSUserDefaults alloc] initWithSuiteName:kSuiteName] stringForKey:kMEID];
        _meIdSignature = [[[NSUserDefaults alloc] initWithSuiteName:kSuiteName] stringForKey:kMEID_SIGNATURE];
        _config = config;
        _timestampProvider = [EMSTimestampProvider new];
        _uuidProvider = [EMSUUIDProvider new];
    }
    return self;
}

- (void)setLastAppLoginPayload:(NSDictionary *)lastAppLoginPayload {
    _lastAppLoginPayload = lastAppLoginPayload;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    [userDefaults setObject:lastAppLoginPayload
                     forKey:kLastAppLoginPayload];
    [userDefaults synchronize];
}

- (void)setMeId:(NSString *)meId {
    _meId = meId;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    [userDefaults setObject:meId
                     forKey:kMEID];
    [userDefaults synchronize];
}

- (void)setMeIdSignature:(NSString *)meIdSignature {
    _meIdSignature = meIdSignature;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSuiteName];
    [userDefaults setObject:meIdSignature
                     forKey:kMEID_SIGNATURE];
    [userDefaults synchronize];
}

- (void)reset {
    self.appLoginParameters = nil;
    self.lastAppLoginPayload = nil;
    self.meId = nil;
    self.meIdSignature = nil;
}

@end