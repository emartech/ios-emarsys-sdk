//
//  Copyright © 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSSQLiteHelper.h"
#import "EMSSQLSpecificationProtocol.h"
#import "MEButtonClick.h"
#import "EMSRepositoryProtocol.h"

@interface MEButtonClickRepository : NSObject <EMSRepositoryProtocol>

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)sqliteHelper;
- (void)add:(MEButtonClick *)item;
- (void)remove:(id<EMSSQLSpecificationProtocol>)sqlSpecification;
- (NSArray<MEButtonClick *> *)query:(id<EMSSQLSpecificationProtocol>)sqlSpecification;

@end
