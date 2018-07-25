//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "MELogRepositoryProxy.h"

@interface MELogRepositoryProxy()

@property(nonatomic, strong) id<EMSLogRepositoryProtocol> logRepository;
@property(nonatomic, strong) NSArray<id<EMSLogHandlerProtocol>> *handlers;

@end

@implementation MELogRepositoryProxy

- (instancetype)initWithLogRepository:(id <EMSLogRepositoryProtocol>)logRepository
                             handlers:(NSArray<id <EMSLogHandlerProtocol>> *)handlers {
    NSParameterAssert(logRepository);
    NSParameterAssert(handlers);
    NSAssert(handlers.count > 0, @"Handlers must not be empty.");
    if (self = [super init]) {
        _logRepository = logRepository;
        _handlers = handlers;
    }
    return self;
}

- (void)add:(NSDictionary<NSString *, id> *)item {
    NSMutableDictionary<NSString *, NSObject *> *result = [NSMutableDictionary dictionary];
    for (id<EMSLogHandlerProtocol> handler in self.handlers) {
        [result addEntriesFromDictionary:[handler handle:item]];
    }
    if (result.count > 0) {
        [self.logRepository add:result];
    }
}

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    [self.logRepository remove:sqlSpecification];
}

- (NSArray<NSDictionary<NSString *, id> *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    return [self.logRepository query:sqlSpecification];
}

- (BOOL)isEmpty {
    return [self.logRepository isEmpty];
}

@end