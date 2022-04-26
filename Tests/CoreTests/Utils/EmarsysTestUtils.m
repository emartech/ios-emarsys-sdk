//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "EmarsysTestUtils.h"
#import "EMSDependencyInjection.h"
#import "MEExperimental.h"
#import "MEExperimental+Test.h"
#import "MERequestContext.h"
#import "EMSEndpoint.h"
#import "NSError+EMSCore.h"
#import "EMSSQLiteHelper.h"
#import "EMSNotificationCenterManager.h"

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

+ (void)setupEmarsysWithFeatures:(NSArray <EMSFlipperFeature> *)features
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

+ (void)setupEmarsysWithFeatures:(NSArray <EMSFlipperFeature> *)features
         withDependencyContainer:(id <EMSDependencyContainerProtocol>)dependencyContainer
                          config:(EMSConfig *)config {
    [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue waitUntilAllOperationsAreFinished];
    [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue cancelAllOperations];
    [EMSDependencyInjection.dependencyContainer.coreOperationQueue waitUntilAllOperationsAreFinished];
    [EMSDependencyInjection.dependencyContainer.coreOperationQueue cancelAllOperations];
    [EMSDependencyInjection.dependencyContainer.dbHelper close];
    [self purge];

    [EMSDependencyInjection tearDown];
    if (dependencyContainer) {
        [EMSDependencyInjection setupWithDependencyContainer:dependencyContainer];
    }

    if (features) {
        EMSConfig *configWithFeatures = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
            [builder setMobileEngageApplicationCode:@"14C19-A121F"];
            [builder setExperimentalFeatures:features];
        }];

        [Emarsys setupWithConfig:configWithFeatures];
    } else {
        [Emarsys setupWithConfig:config];
    }
}

+ (void)purge {
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
    [userDefaults setObject:@"IntegrationTests"
                     forKey:@"kHardwareIdKey"];
    [userDefaults synchronize];
}

+ (void)tearDownEmarsys {
    [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue waitUntilAllOperationsAreFinished];
    [EMSDependencyInjection.dependencyContainer.publicApiOperationQueue cancelAllOperations];
    [EMSDependencyInjection.dependencyContainer.coreOperationQueue waitUntilAllOperationsAreFinished];
    [EMSDependencyInjection.dependencyContainer.coreOperationQueue cancelAllOperations];
    [EMSDependencyInjection.dependencyContainer.dbHelper close];
    [self purge];
    [EMSDependencyInjection.dependencyContainer.endpoint reset];
    [MEExperimental reset];
    [EMSDependencyInjection.dependencyContainer.requestContext reset];
    [EMSDependencyInjection.dependencyContainer.notificationCenterManager removeHandlers];
    [EMSDependencyInjection tearDown];
}

+ (void)waitForSetCustomer {
    __block NSError *returnedErrorForSetCustomer = [NSError errorWithCode:-1400
                                                     localizedDescription:@"testErrorForSetCustomer"];

    XCTestExpectation *setCustomerExpectation = [[XCTestExpectation alloc] initWithDescription:@"setCustomer"];
    [Emarsys setContactWithContactFieldId:@2575
                        contactFieldValue:@"test2@test.com"
                          completionBlock:^(NSError *error) {
                              returnedErrorForSetCustomer = error;
                              [setCustomerExpectation fulfill];
                          }];

    XCTWaiterResult setCustomerResult = [XCTWaiter waitForExpectations:@[setCustomerExpectation]
                                                               timeout:TIMEOUT];
    XCTAssertEqual(setCustomerResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedErrorForSetCustomer);
}

+ (void)waitForSetPushToken {
    NSData *deviceToken = [@"<1234abcd 1234abcd 1234abcd 1234abcd 1234abcd 1234abcd 1234abcd 1234abcd>" dataUsingEncoding:NSUTF8StringEncoding];

    __block NSError *returnedError = [NSError errorWithCode:-1400
                                       localizedDescription:@"testErrorForSetPushtoken"];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForCompletion"];
    [Emarsys.push setPushToken:deviceToken
               completionBlock:^(NSError *error) {
                   returnedError = error;
                   [expectation fulfill];
               }];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertNil(returnedError);
}

@end
