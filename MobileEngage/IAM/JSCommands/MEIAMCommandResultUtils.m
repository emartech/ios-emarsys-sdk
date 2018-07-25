//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MEIAMCommandResultUtils.h"


@implementation MEIAMCommandResultUtils

+ (NSDictionary<NSString *, NSObject *> *)createSuccessResultWith:(NSString *)jsCommandId {
    return @{@"success": @YES,
            @"id": jsCommandId
    };
}

+ (NSDictionary<NSString *, NSObject *> *)createErrorResultWith:(NSString *)jsCommandId
                                                   errorMessage:(NSString *)errorMessage {
    return @{@"success": @NO,
            @"id": jsCommandId,
            @"errors": @[errorMessage]
    };
}

+ (NSDictionary<NSString *, NSObject *> *)createErrorResultWith:(NSString *)jsCommandId
                                                     errorArray:(NSArray<NSString *> *)errorMessages {
    return @{@"success": @NO,
            @"id": jsCommandId,
            @"errors": errorMessages
    };
}

+ (NSDictionary<NSString *, NSObject *> *)createMissingParameterErrorResultWith:(NSString *)jsCommandId
                                                               missingParameter:(NSString *)missingParameter {
    return [MEIAMCommandResultUtils createErrorResultWith:jsCommandId
                                              errorMessage:[NSString stringWithFormat:@"Missing %@!", missingParameter]];
}

+ (NSDictionary<NSString *, NSObject *> *)createParameterIsWrongTypeErrorResultWith:(NSString *)jsCommandId
                                                                          parameter:(NSString *)parameter
                                                                       expectedType:(NSString *)expectedType {
    return [MEIAMCommandResultUtils createErrorResultWith:jsCommandId
                                              errorMessage:[NSString stringWithFormat:@"%@ parameter is wrong type, it should be %@!", parameter, expectedType]];
}

@end