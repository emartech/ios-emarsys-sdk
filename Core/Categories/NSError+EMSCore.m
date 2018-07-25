//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSError+EMSCore.h"

@implementation NSError (EMSCore)

+ (NSError *)errorWithCode:(int)errorCode
      localizedDescription:(NSString *)localizedDescription {
    return [NSError errorWithDomain:@"com.emarsys.mobileengage"
                               code:errorCode
                           userInfo:@{
                               NSLocalizedDescriptionKey: localizedDescription
                           }];
}

@end