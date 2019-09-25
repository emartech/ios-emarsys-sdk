//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSAuthentication.h"
#import "MEDefaultHeaders.h"
#import "EmarsysSDKVersion.h"

@implementation MEDefaultHeaders

+ (NSDictionary *)additionalHeaders {
    return @{@"Content-Type": @"application/json",
            @"X-EMARSYS-SDK-VERSION": EMARSYS_SDK_VERSION,
#if DEBUG
            @"X-EMARSYS-SDK-MODE": @"debug"
#else
            @"X-EMARSYS-SDK-MODE" : @"production"
#endif
    };
}

@end
