////
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSModelMapperProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSTestColumnInfoMapper: NSObject <EMSModelMapperProtocol>

- (instancetype)initWithTableName:(NSString *)tableName;

@end

NS_ASSUME_NONNULL_END
