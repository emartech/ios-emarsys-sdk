//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Kiwi.h>
#import "EmarsysTestUtils.h"
#import "EMSDependencyInjection.h"
#import "MEExperimental.h"
#import "MEExperimental+Test.h"
#import "MERequestContext.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MEDB.db"]
#define REPOSITORY_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EMSSQLiteQueueDB.db"]
#define kEMSSuiteName @"com.emarsys.mobileengage"
#define kEMSLastAppLoginPayload @"kLastAppLoginPayload"
#define kMEID @"kMEID"
#define kMEID_SIGNATURE @"kMEID_SIGNATURE"
#define kCLIENT_STATE @"kCLIENT_STATE"
#define kCONTACT_TOKEN @"kCONTACT_TOKEN"
#define TIMEOUT 5

@implementation EmarsysTestUtils

+ (void)setupEmarsysWithFeatures:(NSArray<EMSFlipperFeature> *)features
         withDependencyContainer:(id <EMSDependencyContainerProtocol>)dependencyContainer {
    [EmarsysTestUtils setupEmarsysWithFeatures:features
                       withDependencyContainer:dependencyContainer
                                        config:nil];
}

+ (void)setupEmarsysWithConfig:(EMSConfig *)config
           dependencyContainer:(id <EMSDependencyContainerProtocol>)dependencyContainer {
    [EmarsysTestUtils setupEmarsysWithFeatures:nil
                       withDependencyContainer:dependencyContainer
                                        config:config];
}

+ (void)setupEmarsysWithFeatures:(NSArray<EMSFlipperFeature> *)features
         withDependencyContainer:(id <EMSDependencyContainerProtocol>)dependencyContainer
                          config:(EMSConfig *)config {
    [[NSFileManager defaultManager] removeItemAtPath:DB_PATH
                                               error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:REPOSITORY_DB_PATH
                                               error:nil];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults removeObjectForKey:kMEID];
    [userDefaults removeObjectForKey:kMEID_SIGNATURE];
    [userDefaults removeObjectForKey:kEMSLastAppLoginPayload];
    [userDefaults removeObjectForKey:kCLIENT_STATE];
    [userDefaults removeObjectForKey:kCONTACT_TOKEN];
    [userDefaults synchronize];

    userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.emarsys.core"];
    [userDefaults setObject:@"IntegrationTests" forKey:@"kHardwareIdKey"];
    [userDefaults synchronize];

    [EMSDependencyInjection tearDown];
    if (dependencyContainer) {
        [EMSDependencyInjection setupWithDependencyContainer:dependencyContainer];
    }

    if (features) {
        EMSConfig *configWithFeatures = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
            [builder setMobileEngageApplicationCode:@"14C19-A121F"];
            [builder setContactFieldId:@3];
            [builder setExperimentalFeatures:features];
        }];

        [Emarsys setupWithConfig:configWithFeatures];
    } else {
        [Emarsys setupWithConfig:config];
    }
}

+ (void)tearDownEmarsys {
    [MEExperimental reset];
    [EMSDependencyInjection.dependencyContainer.operationQueue waitUntilAllOperationsAreFinished];
    [EMSDependencyInjection.dependencyContainer.requestContext reset];
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

+ (void)waitForSetPushToken {
    NSData *mockDeviceToken = [NSData mock];

    [mockDeviceToken stub:@selector(deviceTokenString)
                andReturn:@"test_pushToken_for_iOS_integrationTest"];

    __block NSError *returnedError = [NSError new];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [Emarsys.push setPushToken:mockDeviceToken
               completionBlock:^(NSError *error) {
                   returnedError = error;
                   [expectation fulfill];
               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    [[theValue(waiterResult) should] equal:theValue(XCTWaiterResultCompleted)];
    [returnedError shouldBeNil];
}

@end