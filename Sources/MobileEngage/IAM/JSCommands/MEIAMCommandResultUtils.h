//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface MEIAMCommandResultUtils : NSObject

+ (NSDictionary<NSString *, NSObject *> *)createSuccessResultWith:(NSString *)jsCommandId;

+ (NSDictionary<NSString *, NSObject *> *)createErrorResultWith:(NSString *)jsCommandId
                                                   errorMessage:(NSString *)errorMessage;

+ (NSDictionary<NSString *, NSObject *> *)createErrorResultWith:(NSString *)jsCommandId
                                                     errorArray:(NSArray<NSString *> *)errorMessages;

+ (NSDictionary<NSString *, NSObject *> *)createMissingParameterErrorResultWith:(NSString *)jsCommandId
                                                               missingParameter:(NSString *)missingParameter;

@end