//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "EMSFilterByValuesSpecification.h"

@interface EMSFilterByValuesSpecification()

@property(nonatomic, strong) NSArray<NSString *> *values;
@property(nonatomic, strong) NSString *column;

@end

@implementation EMSFilterByValuesSpecification

- (instancetype)initWithValues:(NSArray<NSString *> *)values
                        column:(NSString *)column {
    NSParameterAssert(values);
    NSParameterAssert(column);
    if (self = [super init]) {
        _values = values;
        _column = column;
    }
    return self;
}

- (NSString *)selection {
    return [NSString stringWithFormat:@"%@%@;", self.column,
            [self generateInStatementWithArgs:[self selectionArgs]]];
}

- (NSArray<NSString *> *)selectionArgs {
    return [self values];
}

@end
