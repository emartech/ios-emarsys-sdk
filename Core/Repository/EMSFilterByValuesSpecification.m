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

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToSpecification:other];
}

- (BOOL)isEqualToSpecification:(EMSFilterByValuesSpecification *)specification {
    if (self == specification)
        return YES;
    if (specification == nil)
        return NO;
    if (self.values != specification.values && ![self.values isEqualToArray:specification.values])
        return NO;
    if (self.column != specification.column && ![self.column isEqualToString:specification.column])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.values hash];
    hash = hash * 31u + [self.column hash];
    return hash;
}


@end
