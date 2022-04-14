//
//  Copyright © 2022 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSInMemoryStorage.h"

@interface EMSInMemoryStorageTests : XCTestCase

@property(nonatomic, strong) EMSInMemoryStorage *inMemoryStorage;
@property(nonatomic, strong) id <EMSStorageProtocol> mockStorage;
@property(nonatomic, copy) NSString *testDataKey;
@property(nonatomic, strong) NSData *testData;
@property(nonatomic, copy) NSString *testString;
@property(nonatomic, copy) NSString *testStringKey;
@property(nonatomic, copy) NSString *testNumberKey;
@property(nonatomic, copy) NSNumber *testNumber;
@property(nonatomic, copy) NSDictionary<NSString *, id> *testDictionary;
@property(nonatomic, copy) NSString *testDictionaryKey;
@end

@implementation EMSInMemoryStorageTests

- (void)setUp {
    _testDataKey = @"testDataKey";
    _testData = [@"testData" dataUsingEncoding:NSUTF8StringEncoding];
    _testString = @"testStringValue";
    _testStringKey = @"testStringKey";
    _testNumberKey = @"testNumberKey";
    _testNumber = @1;
    _testDictionary = [NSDictionary new];
    _testDictionaryKey = @"testDictionaryKey";
    _mockStorage = OCMProtocolMock(@protocol(EMSStorageProtocol));
    _inMemoryStorage = [[EMSInMemoryStorage alloc] initWithStorage:self.mockStorage];
}

- (void)tearDown {
}

- (void)testInit_storage_mustNotBeNil {
    @try {
        [[EMSInMemoryStorage alloc] initWithStorage:nil];
        XCTFail(@"Expected Exception when storage is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: storage");
    }
}

- (void)testInit_inMemoryStore_mustNotBeNil {
    XCTAssertNotNil(self.inMemoryStorage.inMemoryStore);
}


- (void)testSetData_should_saveData_and_delegate_to_storage {
    [self.inMemoryStorage setData:self.testData
                           forKey:self.testDataKey];

    OCMVerify([self.mockStorage setData:self.testData
                                 forKey:self.testDataKey]);
    XCTAssertEqualObjects(self.inMemoryStorage.inMemoryStore[self.testDataKey], self.testData);
}

- (void)testDataForKey_should_return_inMemoryData {
    [self.inMemoryStorage setData:self.testData
                           forKey:self.testDataKey];

    OCMReject([self.mockStorage dataForKey:self.testDataKey]);

    NSData *result = [self.inMemoryStorage dataForKey:self.testDataKey];

    XCTAssertEqualObjects(result, self.testData);
}

- (void)testDataForKey_should_return_storedValue {
    OCMStub([self.mockStorage dataForKey:self.testDataKey]).andReturn(self.testData);

    NSData *result = [self.inMemoryStorage dataForKey:self.testDataKey];

    XCTAssertEqualObjects(result, self.testData);
    XCTAssertEqualObjects(self.inMemoryStorage.inMemoryStore[self.testDataKey], self.testData);
}

- (void)testSetString_should_saveString_and_delegate_to_storage {
    [self.inMemoryStorage setString:self.testString
                             forKey:self.testStringKey];

    OCMVerify([self.mockStorage setString:self.testString
                                   forKey:self.testStringKey]);
    XCTAssertEqualObjects(self.inMemoryStorage.inMemoryStore[self.testStringKey], self.testString);

}

- (void)testStringForKey_should_return_inMemoryString {
    [self.inMemoryStorage setString:self.testString
                             forKey:self.testStringKey];

    OCMReject([self.mockStorage stringForKey:self.testStringKey]);

    NSString *result = [self.inMemoryStorage stringForKey:self.testStringKey];

    XCTAssertEqualObjects(result, self.testString);
}

- (void)testStringForKey_should_return_storedValue {
    OCMStub([self.mockStorage stringForKey:self.testStringKey]).andReturn(self.testString);

    NSString *result = [self.inMemoryStorage stringForKey:self.testStringKey];

    XCTAssertEqualObjects(result, self.testString);
    XCTAssertEqualObjects(self.inMemoryStorage.inMemoryStore[self.testStringKey], self.testString);
}

- (void)testSetNumberForKey_should_saveNumber_and_delegate_to_storage {
    [self.inMemoryStorage setNumber:self.testNumber
                             forKey:self.testNumberKey];

    OCMVerify([self.mockStorage setNumber:self.testNumber
                                   forKey:self.testNumberKey]);
    XCTAssertEqualObjects(self.inMemoryStorage.inMemoryStore[self.testNumberKey], self.testNumber);
}

- (void)testNumberForKey_should_return_inMemoryNumber {
    [self.inMemoryStorage setNumber:self.testNumber
                             forKey:self.testNumberKey];

    OCMReject([self.mockStorage numberForKey:self.testNumberKey]);

    NSNumber *result = [self.inMemoryStorage numberForKey:self.testNumberKey];

    XCTAssertEqualObjects(result, self.testNumber);
}

- (void)testNumberForKey_should_return_storedValue {
    OCMStub([self.mockStorage numberForKey:self.testNumberKey]).andReturn(self.testNumber);

    NSNumber *result = [self.inMemoryStorage numberForKey:self.testNumberKey];

    XCTAssertEqualObjects(result, self.testNumber);
    XCTAssertEqualObjects(self.inMemoryStorage.inMemoryStore[self.testNumberKey], self.testNumber);
}

- (void)testSetDictionaryForKey_should_saveDictionary_and_delegate_to_storage {
    [self.inMemoryStorage setDictionary:self.testDictionary
                                 forKey:self.testDictionaryKey];

    OCMVerify([self.mockStorage setDictionary:self.testDictionary
                                       forKey:self.testDictionaryKey]);
    XCTAssertEqualObjects(self.inMemoryStorage.inMemoryStore[self.testDictionaryKey], self.testDictionary);
}

- (void)testDictionaryForKey_should_return_inMemoryDictionary {
    [self.inMemoryStorage setDictionary:self.testDictionary
                                 forKey:self.testDictionaryKey];

    OCMReject([self.mockStorage dictionaryForKey:self.testDictionaryKey]);

    NSDictionary *result = [self.inMemoryStorage dictionaryForKey:self.testDictionaryKey];

    XCTAssertEqualObjects(result, self.testDictionary);
}

- (void)testDictionaryForKey_should_return_storedValue {
    OCMStub([self.mockStorage dictionaryForKey:self.testDictionaryKey]).andReturn(self.testDictionary);

    NSDictionary *result = [self.inMemoryStorage dictionaryForKey:self.testDictionaryKey];

    XCTAssertEqualObjects(result, self.testDictionary);
    XCTAssertEqualObjects(self.inMemoryStorage.inMemoryStore[self.testDictionaryKey], self.testDictionary);
}

- (void)testSetObjectForKeyedSubscript_should_saveObject_and_delegate_to_storage {
    self.inMemoryStorage[self.testDataKey] = self.testData;

    OCMVerify([self.mockStorage setData:self.testData
                                       forKey:self.testDataKey]);
    XCTAssertEqualObjects(self.inMemoryStorage.inMemoryStore[self.testDataKey], self.testData);
}

- (void)testObjectForKeyedSubscript_should_return_inMemoryData {
    self.inMemoryStorage[self.testDataKey] = self.testData;

    OCMReject([self.mockStorage dataForKey:self.testDataKey]);

    NSData *result = self.inMemoryStorage[self.testDataKey];

    XCTAssertEqualObjects(result, self.testData);
}

- (void)testMultipleStoredObjects {
    self.inMemoryStorage[self.testDataKey] = self.testData;
    [self.inMemoryStorage setString:self.testString
                             forKey:self.testStringKey];

    OCMReject([self.mockStorage dataForKey:self.testDataKey]);
    OCMReject([self.mockStorage stringForKey:self.testStringKey]);

    NSData *resultData = self.inMemoryStorage[self.testDataKey];
    NSString *resultString = [self.inMemoryStorage stringForKey:self.testStringKey];

    XCTAssertEqualObjects(resultData, self.testData);
    XCTAssertEqualObjects(resultString, self.testString);
}

@end
