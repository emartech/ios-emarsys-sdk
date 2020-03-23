//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSInboxResult.h"

@implementation EMSInboxResult

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToResult:other];
}

- (BOOL)isEqualToResult:(EMSInboxResult *)result {
    if (self == result)
        return YES;
    if (result == nil)
        return NO;
    if (self.messages != result.messages && ![self.messages isEqualToArray:result.messages])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.messages hash];
}

@end