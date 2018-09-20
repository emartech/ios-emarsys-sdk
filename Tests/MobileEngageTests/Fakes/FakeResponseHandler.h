//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"

@interface FakeResponseHandler : EMSAbstractResponseHandler

@property (nonatomic, assign) BOOL shouldHandle;
@property (nonatomic, strong) EMSResponseModel *handledResponseModel;

@end