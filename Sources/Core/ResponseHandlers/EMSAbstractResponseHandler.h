//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSResponseModel.h"

@interface EMSAbstractResponseHandler : NSObject

- (void)processResponse:(EMSResponseModel *)response;

@end