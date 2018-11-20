//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSCommonSQLSpecification.h"

@implementation EMSCommonSQLSpecification

- (NSString *)selection {
    return nil;
}

- (NSArray<NSString *> *)selectionArgs {
    return nil;
}

- (NSString *)orderBy {
    return nil;
}

- (NSString *)limit {
    return nil;
}

- (NSString *)generateInStatementWithArgs:(NSArray<NSString *> *)args {
    NSString *result;
    if (args && args.count > 0) {
        NSMutableString *inStatement = [@" IN (?" mutableCopy];
        for (int i = 1; i < args.count; ++i) {
            [inStatement appendString:@", ?"];
        }
        [inStatement appendString:@")"];
        result = [NSString stringWithString:inStatement];
    }
    return result;
}


@end