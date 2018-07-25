//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWMatcher.h"
#import "EMSRequestModel.h"


@interface EMSRequestModelMatcher : KWMatcher

- (void)beSimilarWithRequest:(EMSRequestModel *)model;

@end