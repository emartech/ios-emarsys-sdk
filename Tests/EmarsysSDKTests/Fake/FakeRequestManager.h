//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRequestManager.h"

@interface FakeRequestManager : EMSRequestManager

- (instancetype)initWithSubmitNowCompletionBlock:(EMSCompletion)completionBlock;

@property(nonatomic, strong) EMSRequestModel *submitNowRequestModel;
@property(nonatomic) CoreSuccessBlock successBlock;
@property(nonatomic) CoreErrorBlock errorBlock;

@end