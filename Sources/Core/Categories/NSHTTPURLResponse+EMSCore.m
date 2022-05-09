//
// Copyright (c) 2022 Emarsys. All rights reserved.
//

#import "NSHTTPURLResponse+EMSCore.h"


@implementation NSHTTPURLResponse (EMSCore)

- (BOOL)isSuccess {
    return self.statusCode >= 200 && self.statusCode <= 299;
}

@end