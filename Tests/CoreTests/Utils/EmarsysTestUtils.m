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
#import "EMSWrapperChecker.h"
#import "EMSSession+Tests.h"

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
    [self purge];
    [EmarsysTestUtils tearDownOperationQueue:EMSDependencyInjection.dependencyContainer.publicApiOperationQueue];
    [EmarsysTestUtils tearDownOperationQueue:EMSDependencyInjection.dependencyContainer.coreOperationQueue];

    [EMSDependencyInjection tearDown];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults setObject:@"none"
                     forKey:kInnerWrapperKey];
    [userDefaults synchronize];
    
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
    [EMSDependencyInjection.dependencyContainer.coreOperationQueue addOperationWithBlock:^{
        [EmarsysTestUtils clearDb:EMSDependencyInjection.dependencyContainer.dbHelper];
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
        [userDefaults removeObjectForKey:kMEID];
        [userDefaults removeObjectForKey:kMEID_SIGNATURE];
        [userDefaults removeObjectForKey:kEMSLastAppLoginPayload];
        [userDefaults removeObjectForKey:kCLIENT_STATE];
        [userDefaults removeObjectForKey:kCONTACT_TOKEN];
        [userDefaults removeObjectForKey:@"kSDKAlreadyInstalled"];
        [userDefaults removeObjectForKey:@"CLIENT_SERVICE_URL"];
        [userDefaults removeObjectForKey:@"EVENT_SERVICE_URL"];
        [userDefaults removeObjectForKey:@"PREDICT_URL"];
        [userDefaults removeObjectForKey:@"DEEPLINK_URL"];
        [userDefaults removeObjectForKey:@"V3_MESSAGE_INBOX_URL"];
        [userDefaults synchronize];

        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.emarsys.core"];
        [userDefaults setObject:@"IntegrationTests"
                         forKey:@"kHardwareIdKey"];
        [userDefaults synchronize];
        
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.emarsys.predict"];
        [userDefaults removeObjectForKey:@"contactFieldValue"];
        [userDefaults removeObjectForKey:@"visitorId"];
        [userDefaults synchronize];
    }];
}

+ (void)tearDownEmarsys {
    for (id observer in EMSDependencyInjection.dependencyContainer.session.observers) {
        [NSNotificationCenter.defaultCenter removeObserver:observer];
    }
    [EMSDependencyInjection.dependencyContainer.urlSession invalidateAndCancel];
    [EMSDependencyInjection.dependencyContainer.endpoint reset];
    [MEExperimental reset];
    [EMSDependencyInjection.dependencyContainer.requestContext reset];
    [EMSDependencyInjection.dependencyContainer.notificationCenterManager removeHandlers];
    [self purge];
    [EmarsysTestUtils tearDownOperationQueue:EMSDependencyInjection.dependencyContainer.publicApiOperationQueue];
    [EmarsysTestUtils tearDownOperationQueue:EMSDependencyInjection.dependencyContainer.coreOperationQueue];
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

+ (void)tearDownOperationQueue:(NSOperationQueue *)operationQueue {
    [operationQueue waitUntilAllOperationsAreFinished];
    [operationQueue setSuspended:YES];
    [operationQueue cancelAllOperations];
}

+ (void)clearDb:(EMSSQLiteHelper *)dbHelper {
    [dbHelper executeCommand:@"DELETE FROM request;"];
    [dbHelper executeCommand:@"DELETE FROM shard;"];
    [dbHelper executeCommand:@"DELETE FROM displayed_iam;"];
    [dbHelper executeCommand:@"DELETE FROM button_click;"];
}

@end
