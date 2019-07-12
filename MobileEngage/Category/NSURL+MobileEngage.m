//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "NSURL+MobileEngage.h"
#import "MEEndpoints.h"

@implementation NSURL (MobileEngage)

- (BOOL)isV3 {
    return [self.absoluteString hasPrefix:CLIENT_SERVICE_URL] || [self.absoluteString hasPrefix:EVENT_SERVICE_URL];
}

@end