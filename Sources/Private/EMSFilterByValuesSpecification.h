//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "EMSCommonSQLSpecification.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSFilterByValuesSpecification : EMSCommonSQLSpecification

- (instancetype)initWithValues:(NSArray<NSString *> *)values
                        column:(NSString *)column;

@end

NS_ASSUME_NONNULL_END
