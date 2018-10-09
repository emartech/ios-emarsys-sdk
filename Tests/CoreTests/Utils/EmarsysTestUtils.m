//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EmarsysTestUtils.h"

#import "MEExperimental.h"
#import "MEExperimental+Test.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MEDB.db"]
#define kEMSSuiteName @"com.emarsys.mobileengage"
#define kEMSLastAppLoginPayload @"kLastAppLoginPayload"
#define kMEID @"kMEID"
#define kMEID_SIGNATURE @"kMEID_SIGNATURE"

@implementation EmarsysTestUtils

+ (void)setUpEmarsysWithFeatures:(NSArray<MEFlipperFeature> *)features {
    [[NSFileManager defaultManager] removeItemAtPath:DB_PATH
                                               error:nil];

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults removeObjectForKey:kMEID];
    [userDefaults removeObjectForKey:kMEID_SIGNATURE];
    [userDefaults removeObjectForKey:kEMSLastAppLoginPayload];
    [userDefaults synchronize];

    userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.emarsys.core"];
    [userDefaults setObject:@"IntegrationTests" forKey:@"kEMSHardwareIdKey"];
    [userDefaults synchronize];

    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
        [builder setMobileEngageApplicationCode:@"14C19-A121F"
                            applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
        [builder setMerchantId:@"dummyMerchantId"];
        [builder setContactFieldId:@3];
        [builder setExperimentalFeatures:features];
    }];
    [Emarsys setupWithConfig:config];
}

+ (void)tearDownEmarsys {
    [MEExperimental reset];
    [[Emarsys dependencyContainer].operationQueue waitUntilAllOperationsAreFinished];
    [Emarsys setDependencyContainer:nil];
}


@end