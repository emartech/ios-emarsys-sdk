//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSEmarsysRequestFactory.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSRequestModel.h"

@interface EMSEmarsysRequestFactory ()

@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;

@end

@implementation EMSEmarsysRequestFactory

- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider {
    NSParameterAssert(timestampProvider);
    NSParameterAssert(uuidProvider);
    if (self = [super init]) {
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
    }
    return self;
}

- (EMSRequestModel *)createRemoteConfigRequestModel {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setMethod:HTTPMethodGET];
            [builder setUrl:@"https://api.myjson.com/bins/1bk0ie"];
        }
                          timestampProvider:self.timestampProvider
                               uuidProvider:self.uuidProvider];
}

@end