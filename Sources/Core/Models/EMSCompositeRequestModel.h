//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSRequestModel.h"


@interface EMSCompositeRequestModel : EMSRequestModel

@property(nonatomic, strong) NSArray<EMSRequestModel *> *originalRequests;

@end