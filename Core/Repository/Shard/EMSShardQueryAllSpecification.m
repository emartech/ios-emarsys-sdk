//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSShardQueryAllSpecification.h"

@implementation EMSShardQueryAllSpecification

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToSpecification:other];
}

- (BOOL)isEqualToSpecification:(EMSShardQueryAllSpecification *)specification {
    if (self == specification)
        return YES;
    if (specification == nil)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [super hash];
}


@end