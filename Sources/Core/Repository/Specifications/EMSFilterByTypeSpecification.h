//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "EMSCommonSQLSpecification.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSFilterByTypeSpecification : EMSCommonSQLSpecification

- (instancetype)initWitType:(NSString *)type
                     column:(NSString *)column;

@end

NS_ASSUME_NONNULL_END
