//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"

@class EMSRequestModel;
@class EMSResponseModel;

typedef void(^EMSRESTClientCompletionBlock)(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error);

@protocol EMSRESTClientCompletionProxyProtocol <NSObject>

- (EMSRESTClientCompletionBlock)completionBlock;

@end