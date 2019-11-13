//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface EMSServiceDictionaryValidator : NSObject

@property(nonatomic, readonly) NSDictionary *dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)valueExistsForKey:(id)key withType:(Class)type;

- (NSArray *)failureReasons;

@end


typedef void (^ValidatorBlock)(EMSServiceDictionaryValidator *validate);

@interface NSDictionary (Validator)

- (NSArray *)validate:(ValidatorBlock)validator;

@end