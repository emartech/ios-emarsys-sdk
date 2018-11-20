//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "FakeRequestRepository.h"


@implementation FakeRequestRepository

- (void)add:(EMSRequestModel *)item {
}

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
}

- (NSArray<EMSRequestModel *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    return self.queryResponseMapping[NSStringFromClass([((NSObject *) sqlSpecification) class])];
}

@end