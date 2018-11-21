//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "EMSFilterByTypeSpecification.h"

@interface EMSFilterByTypeSpecification()

@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *column;

@end

@implementation EMSFilterByTypeSpecification

- (instancetype)initWitType:(NSString *)type
                     column:(NSString *)column {
    NSParameterAssert(type);
    NSParameterAssert(column);
    if (self = [super init]) {
        _type = type;
        _column = column;
    }
    return self;
}

- (NSString *)selection {
    return [NSString stringWithFormat:@"%@ LIKE ?", self.column];
}

- (NSArray<NSString *> *)selectionArgs {
    return @[self.type];
}

- (NSString *)orderBy {
    return @"ROWID ASC";
}

@end
