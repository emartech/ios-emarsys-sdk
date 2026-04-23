////
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import "NSString+EMSCore.h"

@implementation NSString (EMSCore)

- (NSString *)percentEncode {
    NSMutableCharacterSet *allowedCharacters = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacters removeCharactersInString:@"!#$&'()*+,/:;=?@[]"];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

@end
