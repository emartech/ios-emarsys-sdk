//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSRequestModelDeleteByIdsSpecification.h"
#import "EMSSchemaContract.h"
#import "EMSCompositeRequestModel.h"

@implementation EMSRequestModelDeleteByIdsSpecification

- (instancetype)initWithRequestModel:(EMSRequestModel *)requestModel {
    if (self = [super init]) {
        _requestModel = requestModel;
    }
    return self;
}

- (NSString *)sql {
    NSString *ids = [NSString stringWithFormat:@"'%@'", [self idListAsString]];
    return SQL_DELETE_MULTIPLE_ITEM(ids);
}

- (void)bindStatement:(sqlite3_stmt *)statement {

}

- (NSString *)idListAsString {
    if ([self.requestModel isKindOfClass:[EMSCompositeRequestModel class]]) {
        EMSCompositeRequestModel *compositeModel = (EMSCompositeRequestModel *) self.requestModel;
        NSMutableArray<NSString *> *originalRequestIds = [NSMutableArray array];
        for (EMSRequestModel *emsRequestModel in compositeModel.originalRequests) {
            [originalRequestIds addObject:emsRequestModel.requestId];
        }
        return [originalRequestIds componentsJoinedByString:@"', '"];
    }

    return self.requestModel.requestId;
}

@end