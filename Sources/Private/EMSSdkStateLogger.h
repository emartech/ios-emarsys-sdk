//
// Copyright (c) 2021 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSEndpoint;
@class MERequestContext;
@class EMSConfig;
@protocol EMSStorageProtocol;


@interface EMSSdkStateLogger : NSObject
@property(nonatomic, readonly) EMSEndpoint *endpoint;
@property(nonatomic, readonly) MERequestContext *meRequestContext;
@property(nonatomic, readonly) EMSConfig *config;
@property(nonatomic, readonly) id<EMSStorageProtocol> storage;

- (instancetype)initWithEndpoint:(EMSEndpoint *)endpoint
                meRequestContext:(MERequestContext *)meRequestContext
                          config:(EMSConfig *)config
                         storage:(id<EMSStorageProtocol>)storage;

- (void)log;
@end