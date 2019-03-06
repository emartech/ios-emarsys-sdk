//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Kiwi.h>
#import "EmarsysTestUtils.h"
#import "EMSDependencyInjection.h"
#import "MEExperimental.h"
#import "MEExperimental+Test.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MEDB.db"]
#define REPOSITORY_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EMSSQLiteQueueDB.db"]
#define kEMSSuiteName @"com.emarsys.mobileengage"
#define kEMSLastAppLoginPayload @"kLastAppLoginPayload"
#define kMEID @"kMEID"
#define kMEID_SIGNATURE @"kMEID_SIGNATURE"
#define TIMEOUT 5

@implementation EmarsysTestUtils

+ (void)setupEmarsysWithFeatures:(NSArray<EMSFlipperFeature> *)features
         withDependencyContainer:(id <EMSDependencyContainerProtocol>)dependencyContainer {
    [[NSFileManager defaultManager] removeItemAtPath:DB_PATH
                                               error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:REPOSITORY_DB_PATH
                                               error:nil];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults removeObjectForKey:kMEID];
    [userDefaults removeObjectForKey:kMEID_SIGNATURE];
    [userDefaults removeObjectForKey:kEMSLastAppLoginPayload];
    [userDefaults synchronize];

    userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.emarsys.core"];
    [userDefaults setObject:@"IntegrationTests" forKey:@"kHardwareIdKey"];
    [userDefaults synchronize];

    [EMSDependencyInjection tearDown];
    if (dependencyContainer) {
        [EMSDependencyInjection setupWithDependencyContainer:dependencyContainer];
    }

    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
        [builder setMobileEngageApplicationCode:@"14C19-A121F"
                            applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
        [builder setMerchantId:@"1428C8EE286EC34B"];
        [builder setContactFieldId:@3];
        [builder setExperimentalFeatures:features];
    }];
    [Emarsys setupWithConfig:config];
}

+ (void)tearDownEmarsys {
    [MEExperimental reset];
    [EMSDependencyInjection.dependencyContainer.operationQueue waitUntilAllOperationsAreFinished];
    [EMSDependencyInjection tearDown];
}

+ (void)waitForSetCustomer {
    __block NSError *returnedErrorForSetCustomer = [NSError mock];

    XCTestExpectation *setCustomerExpectation = [[XCTestExpectation alloc] initWithDescription:@"setCustomer"];
    [Emarsys setContactWithContactFieldValue:@"test@test.com"
                             completionBlock:^(NSError *error) {
                                 returnedErrorForSetCustomer = error;
                                 [setCustomerExpectation fulfill];
                             }];

    XCTWaiterResult setCustomerResult = [XCTWaiter waitForExpectations:@[setCustomerExpectation]
                                                               timeout:TIMEOUT];
    [[returnedErrorForSetCustomer should] beNil];
    [[theValue(setCustomerResult) should] equal:theValue(XCTWaiterResultCompleted)];
}

@end