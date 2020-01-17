//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSStorage.h"

static NSString *const kTestKey = @"testKeyForValue";
static NSString *const kTestValue1String = @"testValue1";
static NSString *const kTestValue2String = @"testValue2";

@interface EMSStorageTests : XCTestCase

@property(nonatomic, strong) NSData *testValue1;
@property(nonatomic, strong) NSData *testValue2;
@property(nonatomic, strong) NSNumber *testNumber;
@property(nonatomic, strong) NSDictionary *testDictionary;
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) NSOperationQueue *mockQueue;
@property(nonatomic, strong) EMSStorage *storage;
@property(nonatomic, strong) NSArray <NSString *> *suiteNames;

@end

@implementation EMSStorageTests

- (void)setUp {
    [super setUp];
    _queue = [NSOperationQueue new];
    [self.queue setMaxConcurrentOperationCount:1];
    _mockQueue = OCMPartialMock(self.queue);

    _testValue1 = [kTestValue1String dataUsingEncoding:NSUTF8StringEncoding];
    _testValue2 = [kTestValue2String dataUsingEncoding:NSUTF8StringEncoding];
    _testNumber = @42;
    _suiteNames = @[@"com.emarsys.core", @"com.emarsys.predict", @"com.emarsys.mobileengage"];
    _testDictionary = @{
            @"testKey1": @"testValue1",
            @"testKey2":
            @{
                    @"testKey3": @"testValue3",
                    @"testKey4": @42
            },
            @"testKey5": @YES
    };

    _storage = [[EMSStorage alloc] initWithOperationQueue:self.mockQueue
                                               suiteNames:self.suiteNames];
}

- (void)tearDown {
    [super tearDown];
    NSDictionary *deleteQuery = @{
            (id) kSecClass: (id) kSecClassGenericPassword,
            (id) kSecAttrAccessible: (id) kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            (id) kSecAttrAccount: kTestKey,
            (id) kSecReturnData: (id) kCFBooleanTrue,
            (id) kSecReturnAttributes: (id) kCFBooleanTrue
    };

    SecItemDelete((__bridge CFDictionaryRef) deleteQuery);

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.suiteNames[0]];
    [userDefaults removeObjectForKey:kTestKey];
    userDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.suiteNames[1]];
    [userDefaults removeObjectForKey:kTestKey];
    userDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.suiteNames[2]];
    [userDefaults removeObjectForKey:kTestKey];
}

- (void)testInit_operationQueue_mustNotBeNil {
    @try {
        [[EMSStorage alloc] initWithOperationQueue:nil
                                        suiteNames:self.suiteNames];
        XCTFail(@"Expected Exception when operationQueue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: operationQueue");
    }
}

- (void)testInit_suiteNames_mustNotBeNil {
    @try {
        [[EMSStorage alloc] initWithOperationQueue:self.mockQueue
                                        suiteNames:nil];
        XCTFail(@"Expected Exception when suiteNames is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: suiteNames");
    }
}

- (void)testSetDataForKey_key_mustNotBeNil {
    @try {
        [self.storage setData:self.testValue1
                       forKey:nil];
        XCTFail(@"Expected Exception when key is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: key");
    }
}

- (void)testSetDataForKey {
    NSString *result = nil;

    [self.storage setData:self.testValue1
                   forKey:kTestKey];

    [self waitForOperation];

    NSDictionary *query = @{
            (id) kSecClass: (id) kSecClassGenericPassword,
            (id) kSecAttrAccessible: (id) kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            (id) kSecAttrAccount: kTestKey,
            (id) kSecReturnData: (id) kCFBooleanTrue,
            (id) kSecReturnAttributes: (id) kCFBooleanTrue
    };

    CFTypeRef resultRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) query, &resultRef);
    if (status == errSecSuccess) {
        NSDictionary *resultDict = (__bridge NSDictionary *) resultRef;
        result = [[NSString alloc] initWithData:resultDict[(id) kSecValueData]
                                       encoding:NSUTF8StringEncoding];
    }
    if (resultRef) {
        CFRelease(resultRef);
    }

    XCTAssertEqualObjects(result, kTestValue1String);
}

- (void)testSetDataForKey_should_deleteValue_when_dataIsNil {
    [self.storage setData:self.testValue1
                   forKey:kTestKey];
    [self.storage setData:nil
                   forKey:kTestKey];

    NSData *result = [self.storage dataForKey:kTestKey];

    [self waitForOperation];

    XCTAssertNil(result);
}


- (void)testDataForKey_key_mustNotBeNil {
    @try {
        [self.storage dataForKey:nil];
        XCTFail(@"Expected Exception when key is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: key");
    }
}

- (void)testDataForKey {
    [self.storage setData:self.testValue1
                   forKey:kTestKey];

    [self waitForOperation];

    NSString *result = [[NSString alloc] initWithData:[self.storage dataForKey:kTestKey]
                                             encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(result, kTestValue1String);
}

- (void)testDataForKey_should_returnNil {
    NSData *result = [self.storage dataForKey:kTestKey];

    [self waitForOperation];

    XCTAssertNil(result);
}

- (void)testDataForKey_should_returnAndDeleteUserDefaultsValue_when_missingFromKeychain_withString {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.suiteNames[1]];
    EMSStorage *mockStorage = OCMPartialMock(self.storage);

    [userDefaults setObject:kTestValue1String
                     forKey:kTestKey];

    NSData *result = [mockStorage dataForKey:kTestKey];

    [self waitForOperation];

    NSData *userDefaultsResult = [userDefaults dataForKey:kTestKey];

    OCMVerify([mockStorage setData:self.testValue1
                            forKey:kTestKey];);
    XCTAssertEqualObjects(result, self.testValue1);
    XCTAssertNil(userDefaultsResult);
}

- (void)testDataForKey_should_returnAndDeleteUserDefaultsValue_when_missingFromKeychain_withNumber {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.suiteNames[1]];
    EMSStorage *mockStorage = OCMPartialMock(self.storage);
    NSData *numberData = [NSKeyedArchiver archivedDataWithRootObject:self.testNumber];

    [userDefaults setObject:self.testNumber
                     forKey:kTestKey];

    NSData *result = [mockStorage dataForKey:kTestKey];

    [self waitForOperation];

    NSData *userDefaultsResult = [userDefaults dataForKey:kTestKey];

    OCMVerify([mockStorage setData:numberData
                            forKey:kTestKey];);
    XCTAssertEqualObjects(result, numberData);
    XCTAssertNil(userDefaultsResult);
}

- (void)testDataForKey_should_returnAndDeleteUserDefaultsValue_when_missingFromKeychain_withDictionary {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.suiteNames[1]];
    EMSStorage *mockStorage = OCMPartialMock(self.storage);

    [userDefaults setObject:self.testDictionary
                     forKey:kTestKey];

    NSDictionary *result = [mockStorage dictionaryForKey:kTestKey];

    [self waitForOperation];

    NSData *userDefaultsResult = [userDefaults dataForKey:kTestKey];

    XCTAssertEqualObjects(result, self.testDictionary);
    XCTAssertNil(userDefaultsResult);
}

- (void)testSetDataForKey_should_UpdateData {
    [self.storage setData:self.testValue1
                   forKey:kTestKey];
    [self.storage setData:self.testValue2
                   forKey:kTestKey];

    [self waitForOperation];

    NSString *result = [[NSString alloc] initWithData:[self.storage dataForKey:kTestKey]
                                             encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(result, kTestValue2String);
}

- (void)testSetStringForKey {
    [self.storage setString:kTestValue1String
                     forKey:kTestKey];

    [self waitForOperation];

    NSString *result = [[NSString alloc] initWithData:self.storage[kTestKey]
                                             encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(result, kTestValue1String);
}

- (void)testStringForKey {
    [self.storage setString:kTestValue1String
                     forKey:kTestKey];

    [self waitForOperation];

    NSString *result = [self.storage stringForKey:kTestKey];

    XCTAssertEqualObjects(result, kTestValue1String);
}

- (void)testStringForKey_should_returnNil {
    NSString *result = [self.storage stringForKey:kTestKey];

    [self waitForOperation];

    XCTAssertNil(result);
}

- (void)testSetNumberForKey {
    [self.storage setNumber:self.testNumber
                     forKey:kTestKey];

    [self waitForOperation];

    NSNumber *result = [NSKeyedUnarchiver unarchiveObjectWithData:self.storage[kTestKey]];

    XCTAssertEqualObjects(result, self.testNumber);
}

- (void)testNumberForKey {
    [self.storage setNumber:self.testNumber
                     forKey:kTestKey];

    [self waitForOperation];

    NSNumber *result = [self.storage numberForKey:kTestKey];

    XCTAssertEqualObjects(result, self.testNumber);
}

- (void)testNumberForKey_should_returnNil {
    NSNumber *result = [self.storage numberForKey:kTestKey];

    [self waitForOperation];

    XCTAssertNil(result);
}

- (void)testSetDictionaryForKey {
    [self.storage setDictionary:self.testDictionary
                         forKey:kTestKey];

    [self waitForOperation];

    NSDictionary *result = [NSKeyedUnarchiver unarchiveObjectWithData:self.storage[kTestKey]];

    XCTAssertEqualObjects(result, self.testDictionary);
}

- (void)testDictionaryForKey {
    [self.storage setDictionary:self.testDictionary
                         forKey:kTestKey];

    [self waitForOperation];

    NSDictionary *result = [self.storage dictionaryForKey:kTestKey];

    XCTAssertEqualObjects(result, self.testDictionary);
}

- (void)testDictionaryForKey_should_returnNil {
    NSDictionary *result = [self.storage dictionaryForKey:kTestKey];

    [self waitForOperation];

    XCTAssertNil(result);
}

- (void)testSubscriptingValueSet {
    self.storage[kTestKey] = self.testValue1;

    [self waitForOperation];

    NSString *result = [[NSString alloc] initWithData:[self.storage dataForKey:kTestKey]
                                             encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(result, kTestValue1String);
}

- (void)testSubscriptingValueGet {
    self.storage[kTestKey] = self.testValue1;

    [self waitForOperation];

    NSData *result = self.storage[kTestKey];

    XCTAssertEqualObjects(result, self.testValue1);
}

- (void)testSetDataForKey_when_queueIsNotInvokingBlock {
    OCMStub([self.mockQueue addOperationWithBlock:[OCMArg any]]);

    [self.storage setData:self.testValue1
                   forKey:kTestKey];

    [self waitForOperation];

    XCTAssertNil(self.storage[kTestKey]);
}

- (void)testSetDataForKey_when_queueIsInvokingBlock {
    OCMStub([self.mockQueue addOperationWithBlock:[OCMArg invokeBlock]]);

    [self.storage setData:self.testValue1
                   forKey:kTestKey];

    [self waitForOperation];

    NSData *result = self.storage[kTestKey];
    XCTAssertEqualObjects(result, self.testValue1);
}

- (void)waitForOperation {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForBlock"];
    [self.queue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        [expectation fulfill];
    }]];

    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:@[expectation]
                                                          timeout:5];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
}

@end