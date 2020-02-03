//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSDictionaryValidator.h"


@interface EMSDictionaryValidator ()
@property(nonatomic, strong) NSDictionary *dictionary;
@property(nonatomic, strong) NSMutableArray *reasons;
@end

@implementation EMSDictionaryValidator

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _dictionary = dictionary;
        _reasons = [NSMutableArray new];
    }
    return self;
}

- (void)valueExistsForKey:(id)key withType:(Class)type {
    if (key) {
        id value = self.dictionary[key];
        BOOL containsKey = value != nil;
        BOOL typeMatches = YES;
        if (type) {
            typeMatches = [value isKindOfClass:type];
        }

        if (containsKey) {
            if (!typeMatches) {
                [_reasons addObject:[NSString stringWithFormat:@"Type mismatch for key '%@', expected type: %@, but was: %@.",
                                                               key,
                                                               NSStringFromClass(type),
                                                               NSStringFromClass([value class])]];
            }
        } else {
            if (type) {
                [_reasons addObject:[NSString stringWithFormat:@"Missing '%@' key with type: %@.",
                                                               key,
                                                               NSStringFromClass(type)]];
            } else {
                [_reasons addObject:[NSString stringWithFormat:@"Missing '%@' key.", key]];
            }
        }
    }
}

- (NSArray *)failureReasons {
    return [NSArray arrayWithArray:self.reasons];
}

@end

@implementation NSDictionary (Validator)

- (NSArray *)validate:(ValidatorBlock)validator {
    EMSDictionaryValidator *dictionaryValidator = [[EMSDictionaryValidator alloc] initWithDictionary:self];
    validator(dictionaryValidator);
    return [dictionaryValidator failureReasons];
}

@end