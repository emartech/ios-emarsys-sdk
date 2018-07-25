//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSRequestModel;

NS_ASSUME_NONNULL_BEGIN
@interface NSURLRequest (EMSCore)

+ (NSURLRequest *)requestWithRequestModel:(EMSRequestModel *)requestModel
                        additionalHeaders:(nullable NSDictionary *)additionalHeaders;

+ (NSURLRequest *)requestWithRequestModel:(EMSRequestModel *)requestModel;

@end

NS_ASSUME_NONNULL_END