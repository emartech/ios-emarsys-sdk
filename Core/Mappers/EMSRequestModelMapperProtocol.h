//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSRequestModel;

@protocol EMSRequestModelMapperProtocol <NSObject>

- (BOOL)shouldHandleWithRequestModel:(EMSRequestModel *)requestModel;

- (EMSRequestModel *)modelFromModel:(EMSRequestModel *)requestModel;

@end