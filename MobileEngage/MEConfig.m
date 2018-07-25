//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEConfig.h"
#import "MEConfigBuilder.h"

@implementation MEConfig

+ (nonnull MEConfig *)makeWithBuilder:(MEConfigBuilderBlock)builderBlock {
    NSParameterAssert(builderBlock);
    MEConfigBuilder *builder = [MEConfigBuilder new];
    builderBlock(builder);

    NSParameterAssert(builder.applicationCode);
    NSParameterAssert(builder.applicationPassword);

    return [[MEConfig alloc] initWithBuilder:builder];
}

- (id)initWithBuilder:(MEConfigBuilder *)builder {
    if (self = [super init]) {
        _applicationCode = builder.applicationCode;
        _applicationPassword = builder.applicationPassword;
        _experimentalFeatures = builder.experimentalFeatures;
    }

    return self;
}

@end