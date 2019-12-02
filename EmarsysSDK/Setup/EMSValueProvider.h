//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface EMSValueProvider : NSObject

- (instancetype)initWithDefaultValue:(NSString *)defaultValue
                            valueKey:(NSString *)valueKey;

- (NSString *)provideValue;

- (void)updateValue:(NSString *)newValue;

@end