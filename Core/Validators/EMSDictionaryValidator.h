//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMSDictionaryValidator : NSObject

@property(nonatomic, readonly) NSDictionary *dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)valueExistsForKey:(id)key withType:(Class)type;
- (NSArray *)failureReasons;

@end


typedef void (^ValidatorBlock)(EMSDictionaryValidator *validate);

@interface NSDictionary (Validator)

- (NSArray *)validate:(ValidatorBlock)validator;

@end
