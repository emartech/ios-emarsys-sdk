//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSConfig.h"

@implementation EMSConfig

+ (nonnull EMSConfig *)makeWithBuilder:(MEConfigBuilderBlock)builderBlock {
    NSParameterAssert(builderBlock);
    EMSConfigBuilder *builder = [EMSConfigBuilder new];
    builderBlock(builder);

    return [[EMSConfig alloc] initWithBuilder:builder];
}

- (id)initWithBuilder:(EMSConfigBuilder *)builder {
    if (self = [super init]) {
        _applicationCode = builder.applicationCode;
        _experimentalFeatures = builder.experimentalFeatures;
        _merchantId = builder.merchantId;
        _contactFieldId = builder.contactFieldId;
    }

    return self;
}

@end