//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "FakeSQLSpecification.h"


@implementation FakeSQLSpecification

- (instancetype)initWithSelection:(NSString *)selection
                    selectionArgs:(NSArray<NSString *> *)selectionArgs
                          orderBy:(NSString *)orderBy
                            limit:(NSString *)limit {
    if (self = [super init]) {
        self.selection = selection;
        self.selectionArgs = selectionArgs;
        self.orderBy = orderBy;
        self.limit = limit;
    }

    return self;
}

- (NSString *)sql {
    return nil;
}

- (void)bindStatement:(sqlite3_stmt *)statement {

}


@end