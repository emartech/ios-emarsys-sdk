//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSValueProvider.h"

#define kEMSSuiteName @"com.emarsys.mobileengage"

@interface EMSValueProviderTests : XCTestCase

@property(nonatomic, strong) EMSValueProvider *valueProvider;
@property(nonatomic, readonly) NSString *defaultValue;
@property(nonatomic, readonly) NSString *value;
@property(nonatomic, readonly) NSString *valueKey;

@end

@implementation EMSValueProviderTests

- (void)setUp {
    _defaultValue = @"testDefaultValue";
    _value = @"testNewValue";
    _valueKey = @"testValueKey";
    _valueProvider = [[EMSValueProvider alloc] initWithDefaultValue:self.defaultValue
                                                           valueKey:self.valueKey];
}

- (void)tearDown {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults removeObjectForKey:self.valueKey];
}

- (void)testInit_defaultValue_mustNotBeNil {
    @try {
        [[EMSValueProvider alloc] initWithDefaultValue:nil
                                              valueKey:@"valueKey"];
        XCTFail(@"Expected Exception when defaultValue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: defaultValue");
    }
}

- (void)testInit_valueKey_mustNotBeNil {
    @try {
        [[EMSValueProvider alloc] initWithDefaultValue:@"defaultKey"
                                              valueKey:nil];
        XCTFail(@"Expected Exception when valueKey is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: valueKey");
    }
}

- (void)testProvideValue {
    NSString *result = [self.valueProvider provideValue];

    XCTAssertEqualObjects(result, self.defaultValue);
}

- (void)testUpdateValue {
    [self.valueProvider updateValue:self.value];

    NSString *result = [self.valueProvider provideValue];

    XCTAssertEqualObjects(result, self.value);
}

- (void)testUpdateValue_should_returnDefaultValue_after_newValueWasSetToNil {
    [self.valueProvider updateValue:nil];

    NSString *result = [self.valueProvider provideValue];

    XCTAssertEqualObjects(result, self.defaultValue);
}

- (void)testUpdateValue_should_returnDefaultValue_after_newValueWasSetAndResetToNil {
    [self.valueProvider updateValue:self.value];
    [self.valueProvider updateValue:nil];

    NSString *result = [self.valueProvider provideValue];

    XCTAssertEqualObjects(result, self.defaultValue);
}

- (void)testProvideValue_should_returnNewValue_whenItWasStored {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    [userDefaults setObject:self.value
                     forKey:self.valueKey];

    _valueProvider = [[EMSValueProvider alloc] initWithDefaultValue:self.defaultValue
                                                           valueKey:self.valueKey];

    NSString *result = [self.valueProvider provideValue];

    XCTAssertEqualObjects(result, self.value);
}

- (void)testUpdateValue_should_storeNewValue {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];

    [self.valueProvider updateValue:self.value];
    NSString *result = [userDefaults stringForKey:self.valueKey];

    XCTAssertEqualObjects(result, self.value);
}

@end
