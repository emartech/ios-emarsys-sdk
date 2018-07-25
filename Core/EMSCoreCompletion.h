//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSResponseModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^CoreErrorBlock)(NSString *requestId, NSError *error);

typedef void (^CoreSuccessBlock)(NSString *requestId, EMSResponseModel *response);

NS_ASSUME_NONNULL_END