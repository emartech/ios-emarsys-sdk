//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSEndpoint;
@class MERequestContext;
@class EMSConfig;
@class EMSStorage;


@interface EMSSdkStateLogger : NSObject
@property(nonatomic, strong, readonly) EMSEndpoint *endpoint;
@property(nonatomic, strong, readonly) MERequestContext *meRequestContext;
@property(nonatomic, strong, readonly) EMSConfig *config;
@property(nonatomic, strong, readonly) EMSStorage *storage;

- (instancetype)initWithEndpoint:(EMSEndpoint *)endpoint
                meRequestContext:(MERequestContext *)meRequestContext
                          config:(EMSConfig *)config
                         storage:(EMSStorage *)storage;

- (void)log;
@end