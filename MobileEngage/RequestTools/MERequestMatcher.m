//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MERequestMatcher.h"


@implementation MERequestMatcher

+ (BOOL)isV3CustomEventUrl:(NSString *)url {
    if (url) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^https://mobile-events.eservice.emarsys.net/v3/devices/\\w+/events$"]
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        return [regex numberOfMatchesInString:url
                                      options:0
                                        range:NSMakeRange(0, [url length])] > 0;
    } else {
        return NO;
    }

}

@end