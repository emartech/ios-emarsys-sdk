//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEAppLoginParameters.h"


@implementation MEAppLoginParameters {

}

- (instancetype)initWithContactFieldId:(NSNumber *)contactFieldId contactFieldValue:(NSString *)contactFieldValue {
    self = [super init];
    if (self) {
        self.contactFieldId = contactFieldId;
        self.contactFieldValue = contactFieldValue;
    }

    return self;
}

+ (instancetype)parametersWithContactFieldId:(NSNumber *)contactFieldId contactFieldValue:(NSString *)contactFieldValue {
    return [[self alloc] initWithContactFieldId:contactFieldId contactFieldValue:contactFieldValue];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToParameters:other];
}

- (BOOL)isEqualToParameters:(MEAppLoginParameters *)parameters {
    if (self == parameters)
        return YES;
    if (parameters == nil)
        return NO;
    if (self.contactFieldId != parameters.contactFieldId && ![self.contactFieldId isEqualToNumber:parameters.contactFieldId])
        return NO;
    if (self.contactFieldValue != parameters.contactFieldValue && ![self.contactFieldValue isEqualToString:parameters.contactFieldValue])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.contactFieldId hash];
    hash = hash * 31u + [self.contactFieldValue hash];
    return hash;
}


@end