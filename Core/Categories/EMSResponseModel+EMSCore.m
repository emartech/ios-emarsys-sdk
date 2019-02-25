//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSResponseModel+EMSCore.h"

@implementation EMSResponseModel (EMSCore)

- (BOOL)isSuccess {
    return self.statusCode >= 200 && self.statusCode <= 299;;
}

@end