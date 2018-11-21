//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "EMSRequestModel+RequestIds.h"
#import "EMSCompositeRequestModel.h"

@implementation EMSRequestModel (RequestIds)

- (NSArray<NSString *> *)requestIds {
    if ([self isKindOfClass:[EMSCompositeRequestModel class]]) {
        EMSCompositeRequestModel *compositeModel = (EMSCompositeRequestModel *) self;
        NSMutableArray<NSString *> *originalRequestIds = [NSMutableArray array];
        for (EMSRequestModel *emsRequestModel in compositeModel.originalRequests) {
            [originalRequestIds addObject:emsRequestModel.requestId];
        }
        return [NSArray arrayWithArray:originalRequestIds];
    }
    
    return @[self.requestId];
}

@end
