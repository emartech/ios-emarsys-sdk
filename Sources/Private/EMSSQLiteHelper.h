//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSDBTrigger.h"
#import "EMSSQLiteHelperProtocol.h"

@class EMSSQLiteHelper;
@protocol EMSModelMapperProtocol;
@protocol EMSDBTriggerProtocol;
@protocol EMSSQLiteHelperSchemaHandlerProtocol;

@interface EMSSQLiteHelper: NSObject<EMSSQLiteHelperProtocol>

@property(nonatomic, strong) id <EMSSQLiteHelperSchemaHandlerProtocol> schemaHandler;
@property(nonatomic, readonly) NSDictionary *registeredTriggers;

- (instancetype)initWithDatabasePath:(NSString *)path
                      schemaDelegate:(id <EMSSQLiteHelperSchemaHandlerProtocol>)schemaDelegate;

@end