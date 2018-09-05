//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "PRERequestContext.h"
#import "EMSConfig.h"


@implementation PRERequestContext
- (instancetype)initWithConfig:(EMSConfig *)config {
    self = [super init];
    if (self) {
        self.customerId = [[[NSUserDefaults alloc] initWithSuiteName:kEMSPredictSuiteName] objectForKey:kEMSCustomerId];
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