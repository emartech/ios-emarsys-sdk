//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSDeviceInfo+MEClientPayload.h"

@implementation EMSDeviceInfo (MEClientPayload)

- (NSDictionary<NSString *, NSString *> *)clientPayload {
    return @{
        @"platform": self.platform,
        @"applicationVersion": self.applicationVersion,
        @"deviceModel": self.deviceModel,
        @"osVersion": self.osVersion,
        @"sdkVersion": self.sdkVersion,
        @"language": self.languageCode,
        @"timezone": self.timeZone
    };
}


@end