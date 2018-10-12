//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSDependencyInjection.h"


@implementation EMSDependencyInjection

static EMSDependencyContainer *_dependencyContainer;

+ (void)setupWithDependencyContainer:(id <EMSDependencyContainerProtocol>)dependencyContainer {
    if (!_dependencyContainer) {
        [EMSDependencyInjection setDependencyContainer:dependencyContainer];
    }
}

+ (void)tearDown {
    [EMSDependencyInjection setDependencyContainer:nil];
}

+ (EMSDependencyContainer *)dependencyContainer {
    return _dependencyContainer;
}

+ (void)setDependencyContainer:(EMSDependencyContainer *)dependencyContainer {
    _dependencyContainer = dependencyContainer;
}

@end