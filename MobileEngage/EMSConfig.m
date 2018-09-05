//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSConfig.h"
#import "EMSConfigBuilder.h"

@implementation EMSConfig

+ (nonnull EMSConfig *)makeWithBuilder:(MEConfigBuilderBlock)builderBlock {
    NSParameterAssert(builderBlock);
    EMSConfigBuilder *builder = [EMSConfigBuilder new];
    builderBlock(builder);

    NSParameterAssert(builder.applicationCode);
    NSParameterAssert(builder.applicationPassword);

    return [[EMSConfig alloc] initWithBuilder:builder];
}

- (id)initWithBuilder:(EMSConfigBuilder *)builder {
    if (self = [super init]) {
        _applicationCode = builder.applicationCode;
        _applicationPassword = builder.applicationPassword;
        _experimentalFeatures = builder.experimentalFeatures;
    }

    return self;
}

@end