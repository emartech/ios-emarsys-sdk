//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSResponseBodyParserProtocol.h"
#import "EMSEndpoint.h"

@class EMSEndpoint;


@interface EMSMobileEngageNullSafeBodyParser : NSObject<EMSResponseBodyParserProtocol>

@property(nonatomic, readonly) EMSEndpoint *endpoint;

- (instancetype)initWithEndpoint:(EMSEndpoint *)endpoint;

@end