//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSConfig.h"
#import "EMSLogLevelProtocol.h"

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
        _enabledConsoleLogLevels = builder.enabledConsoleLogLevels;
        _merchantId = builder.merchantId;
        _contactFieldId = builder.contactFieldId;
        _sharedKeychainAccessGroup = builder.sharedKeychainAccessGroup;
    }
    return self;
}

@end