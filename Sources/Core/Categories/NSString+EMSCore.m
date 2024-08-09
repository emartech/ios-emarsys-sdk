////
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import "NSString+EMSCore.h"

@implementation NSString (EMSCore)

- (NSString *)percentEncode {
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"\"`;/?:^%#@&=$+{}<>,|\\ !'()*[]"] invertedSet];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

@end
