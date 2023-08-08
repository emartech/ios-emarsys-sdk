//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSRequestModel;
@class EMSShard;

@protocol EMSRequestFromShardsMapperProtocol <NSObject>

- (EMSRequestModel *)requestFromShards:(NSArray<EMSShard *> *)shards;

@end