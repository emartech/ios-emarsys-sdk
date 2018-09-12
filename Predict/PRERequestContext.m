//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "PRERequestContext.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"

@implementation PRERequestContext

- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider {
    NSParameterAssert(timestampProvider);
    NSParameterAssert(uuidProvider);
    if (self = [super init]) {
        _customerId = [[[NSUserDefaults alloc] initWithSuiteName:kEMSPredictSuiteName] objectForKey:kEMSCustomerId];
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
    }
    return self;
}

- (void)setCustomerId:(NSString *)customerId {
    _customerId = customerId;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSPredictSuiteName];
    [userDefaults setObject:customerId
                     forKey:kEMSCustomerId];
    [userDefaults synchronize];
}

@end