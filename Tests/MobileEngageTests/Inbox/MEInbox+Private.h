//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInbox.h"
#import "EMSRESTClient.h"

@class MERequestContext;

@interface MEInbox (Private)

- (instancetype)initWithRestClient:(EMSRESTClient *)restClient
                            config:(EMSConfig *)config
                    requestContext:(MERequestContext *)requestContext;

- (NSMutableArray *)notifications;

- (MERequestContext *)requestContext;

@end