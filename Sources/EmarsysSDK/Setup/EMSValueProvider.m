//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSValueProvider.h"

#define kEMSSuiteName @"com.emarsys.mobileengage"

@interface EMSValueProvider ()

@property(nonatomic, strong) NSString *defaultValue;
@property(nonatomic, strong) NSString *value;
@property(nonatomic, strong) NSString *valueKey;

@end

@implementation EMSValueProvider

- (instancetype)initWithDefaultValue:(NSString *)defaultValue
                            valueKey:(NSString *)valueKey {
    NSParameterAssert(defaultValue);
    NSParameterAssert(valueKey);

    if (self = [super init]) {
        _defaultValue = defaultValue;
        _value = [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] stringForKey:valueKey];
        _valueKey = valueKey;
    }
    return self;
}

- (NSString *)provideValue {
    return self.value ? self.value : self.defaultValue;
}

- (void)updateValue:(NSString *)newValue {
    self.value = newValue;
    [[[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName] setObject:newValue
                                                                 forKey:self.valueKey];
}

@end