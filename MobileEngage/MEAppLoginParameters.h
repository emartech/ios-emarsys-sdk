//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEAppLoginParameters : NSObject

@property(nonatomic, strong) NSNumber *contactFieldId;
@property(nonatomic, strong) NSString *contactFieldValue;

- (instancetype)initWithContactFieldId:(NSNumber *)contactFieldId contactFieldValue:(NSString *)contactFieldValue;

+ (instancetype)parametersWithContactFieldId:(NSNumber *)contactFieldId contactFieldValue:(NSString *)contactFieldValue;


@end