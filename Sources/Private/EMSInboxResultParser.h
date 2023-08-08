//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSResponseModel;
@class EMSInboxResult;

@interface EMSInboxResultParser : NSObject

- (EMSInboxResult *)parseFromResponse:(EMSResponseModel *)response;

@end