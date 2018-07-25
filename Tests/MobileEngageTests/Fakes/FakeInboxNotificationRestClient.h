//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRESTClient.h"

typedef enum {
    ResultTypeSuccess,
    ResultTypeFailure
} ResultType;

@interface FakeInboxNotificationRestClient : EMSRESTClient

@property (nonatomic, strong) NSMutableArray *submittedRequests;

- (instancetype)initWithResultType:(ResultType)resultType;
- (instancetype)initWithSuccessResults:(NSArray<NSArray<NSDictionary *> *> *)results;

@end