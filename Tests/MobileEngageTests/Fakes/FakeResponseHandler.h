//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractResponseHandler.h"

@interface FakeResponseHandler : AbstractResponseHandler

@property (nonatomic, assign) BOOL shouldHandle;
@property (nonatomic, strong) EMSResponseModel *handledResponseModel;

@end