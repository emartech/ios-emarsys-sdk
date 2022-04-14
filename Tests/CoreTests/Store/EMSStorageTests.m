//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSStorage.h"
#import "XCTestCase+Helper.h"
#import "EMSStorageProtocol.h"

@interface EMSStorage (Tests)

@property(nonatomic, strong) NSUserDefaults *fallbackUserDefaults;

- (OSStatus)storeInSecureStorageWithQuery:(NSDictionary *)query;

@end

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
    _queue = [self createTestOperationQueue];
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

    _storage = [[EMSStorage alloc] initWithSuiteNames:self.suiteNames
                                          accessGroup:@"7ZFXXDJH82.com.emarsys.SdkHostTestGroup"];
}

- (void)tearDown {
    [self tearDownOperationQueue:self.queue];
    NSDictionary *deleteQuery = @{
            (id) kSecClass: (id) kSecClassGenericPassword,
            (id) kSecAttrAccessible: (id) kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
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

- (void)testInit_suiteNames_mustNotBeNil {
    @try {
        [[EMSStorage alloc] initWithSuiteNames:nil
                                   accessGroup:@"testAccessGroup"];
        XCTFail(@"Expected Exception when suiteNames is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: suiteNames");
    }
}

- (void)testInit_withAccessGroup {
    NSString *accessGroup = @"testAccessGroup";
    EMSStorage *storage = [[EMSStorage alloc] initWithSuiteNames:self.suiteNames
                                                     accessGroup:accessGroup];
    XCTAssertEqualObjects(storage.accessGroup, accessGroup);
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

    NSDictionary *query = @{
            (id) kSecClass: (id) kSecClassGenericPassword,
            (id) kSecAttrAccessible: (id) kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
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

- (void)testSetDataForKey_whenKeyChainIsUnavailable {
    EMSStorage *partialMockStorage = OCMPartialMock(self.storage);

    OCMStub([partialMockStorage storeInSecureStorageWithQuery:[OCMArg any]]).andReturn(errSecItemNotFound);

    [partialMockStorage setData:self.testValue1
                         forKey:kTestKey];

    OCMVerify([partialMockStorage.fallbackUserDefaults setObject:self.testValue1
                                                          forKey:kTestKey]);
}

- (void)testSetDataForKey_should_deleteValue_when_dataIsNil {
    [self.storage setData:self.testValue1
                   forKey:kTestKey];
    [self.storage setData:nil
                   forKey:kTestKey];

    NSData *result = [self.storage dataForKey:kTestKey];

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

    NSString *result = [[NSString alloc] initWithData:[self.storage dataForKey:kTestKey]
                                             encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(result, kTestValue1String);
}

- (void)testDataForKey_should_returnNil {
    NSData *result = [self.storage dataForKey:kTestKey];

    XCTAssertNil(result);
}

- (void)testDataForKey_should_returnAndDeleteUserDefaultsValue_when_missingFromKeychain_withString {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:self.suiteNames[1]];
    EMSStorage *mockStorage = OCMPartialMock(self.storage);

    [userDefaults setObject:kTestValue1String
                     forKey:kTestKey];

    NSData *result = [mockStorage dataForKey:kTestKey];

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

    NSData *userDefaultsResult = [userDefaults dataForKey:kTestKey];

    XCTAssertEqualObjects(result, self.testDictionary);
    XCTAssertNil(userDefaultsResult);
}

- (void)testSetDataForKey_should_UpdateData {
    [self.storage setData:self.testValue1
                   forKey:kTestKey];
    [self.storage setData:self.testValue2
                   forKey:kTestKey];

    NSString *result = [[NSString alloc] initWithData:[self.storage dataForKey:kTestKey]
                                             encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(result, kTestValue2String);
}

- (void)testSetStringForKey {
    [self.storage setString:kTestValue1String
                     forKey:kTestKey];

    NSString *result = [[NSString alloc] initWithData:self.storage[kTestKey]
                                             encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(result, kTestValue1String);
}

- (void)testStringForKey {
    [self.storage setString:kTestValue1String
                     forKey:kTestKey];

    NSString *result = [self.storage stringForKey:kTestKey];

    XCTAssertEqualObjects(result, kTestValue1String);
}

- (void)testStringForKey_should_returnNil {
    NSString *result = [self.storage stringForKey:kTestKey];

    XCTAssertNil(result);
}

- (void)testSetNumberForKey {
    [self.storage setNumber:self.testNumber
                     forKey:kTestKey];

    NSNumber *result = [NSKeyedUnarchiver unarchiveObjectWithData:self.storage[kTestKey]];

    XCTAssertEqualObjects(result, self.testNumber);
}

- (void)testNumberForKey {
    [self.storage setNumber:self.testNumber
                     forKey:kTestKey];

    NSNumber *result = [self.storage numberForKey:kTestKey];

    XCTAssertEqualObjects(result, self.testNumber);
}

- (void)testNumberForKey_should_returnNil {
    NSNumber *result = [self.storage numberForKey:kTestKey];

    XCTAssertNil(result);
}

- (void)testSetDictionaryForKey {
    [self.storage setDictionary:self.testDictionary
                         forKey:kTestKey];

    NSDictionary *result = [NSKeyedUnarchiver unarchiveObjectWithData:self.storage[kTestKey]];

    XCTAssertEqualObjects(result, self.testDictionary);
}

- (void)testDictionaryForKey {
    [self.storage setDictionary:self.testDictionary
                         forKey:kTestKey];

    NSDictionary *result = [self.storage dictionaryForKey:kTestKey];

    XCTAssertEqualObjects(result, self.testDictionary);
}

- (void)testDictionaryForKey_should_returnNil {
    NSDictionary *result = [self.storage dictionaryForKey:kTestKey];

    XCTAssertNil(result);
}

- (void)testSubscriptingValueSet {
    self.storage[kTestKey] = self.testValue1;

    NSString *result = [[NSString alloc] initWithData:[self.storage dataForKey:kTestKey]
                                             encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(result, kTestValue1String);
}

- (void)testSubscriptingValueGet {
    self.storage[kTestKey] = self.testValue1;

    NSData *result = self.storage[kTestKey];
    XCTAssertEqualObjects(result, self.testValue1);
}

- (void)skipped_testSharedDataForKey_dataInShared {
    NSString *key = @"sharedKey20";
    [self.storage setSharedData:self.testValue1
                         forKey:key];

    NSData *returnedData = [self.storage dataForKey:key];
    NSData *returnedSharedData = [self.storage sharedDataForKey:key];

    XCTAssertNil(returnedData);
    XCTAssertEqualObjects(returnedSharedData, self.testValue1);
}

- (void)testSharedDataForKey_dataIsNotInShared {
    NSString *key = @"sharedKey23";
    [self.storage setData:self.testValue1
                   forKey:key];

    NSData *returnedData = [self.storage dataForKey:key];
    NSData *returnedSharedData = [self.storage sharedDataForKey:key];

    XCTAssertEqualObjects(returnedData, self.testValue1);
    XCTAssertEqualObjects(returnedSharedData, self.testValue1);
}

- (void)testSharedDataForKey_simpleKeychainDataIsMigrated {
    EMSStorage *partialMockStorage = OCMPartialMock(self.storage);
    OCMStub([partialMockStorage dataForKey:kTestKey]).andReturn(self.testValue1);

    [partialMockStorage sharedDataForKey:kTestKey];

    OCMVerify([partialMockStorage setSharedData:self.testValue1
                                         forKey:kTestKey]);
}

@end
