//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSData+MobileEngine.h"


@implementation NSData (MobileEngine)

- (NSString *)deviceTokenString {
    NSMutableString *token = [NSMutableString new];
    const char *data = [self bytes];
    for (int i = 0; i < self.length; ++i) {
        [token appendFormat:@"%02.2hhx", data[i]];
    }
    return token;
}

@end