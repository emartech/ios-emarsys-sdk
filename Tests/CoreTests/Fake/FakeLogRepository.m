//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "FakeLogRepository.h"

@implementation FakeLogRepository

- (instancetype)init {
    self = [super init];
    if (self) {
        _loggedElements = [NSMutableArray new];
    }

    return self;
}

- (void)add:(NSDictionary<NSString *, id> *)item {
    [self.loggedElements addObject:item];
}

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification {

}

- (NSArray<NSDictionary<NSString *, id> *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    return nil;
}

- (BOOL)isEmpty {
    return NO;
}

@end