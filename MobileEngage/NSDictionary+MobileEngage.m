//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "NSDictionary+MobileEngage.h"

#define MobileEngageSIDKey @"sid"
#define PushwooshMessageCustomDataKey @"u"

@implementation NSDictionary (MobileEngage)

- (NSString *)messageId {
    return [self customData][MobileEngageSIDKey];
}

- (NSDictionary *)customData {
    id customData = self[PushwooshMessageCustomDataKey];
    NSDictionary<NSString *, id> *customDataDict;

    if ([customData isKindOfClass:[NSString class]]) {
        NSData *data = [customData dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            customDataDict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];
        }
    } else if ([customData isKindOfClass:[NSDictionary class]]) {
        customDataDict = customData;
    }

    return customDataDict;
}

@end