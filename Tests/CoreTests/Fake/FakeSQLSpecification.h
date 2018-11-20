//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"

@interface FakeSQLSpecification : NSObject <EMSSQLSpecificationProtocol>

@property(nonatomic, strong) NSString *selection;
@property(nonatomic, strong) NSArray<NSString *> *selectionArgs;
@property(nonatomic, strong) NSString *orderBy;
@property(nonatomic, strong) NSString *limit;

- (instancetype)initWithSelection:(NSString *)selection
                    selectionArgs:(NSArray<NSString *> *)selectionArgs
                          orderBy:(NSString *)orderBy
                            limit:(NSString *)limit;


@end