//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MEInAppMessage;

@protocol MEInAppTrackingProtocol <NSObject>

- (void)trackInAppDisplay:(MEInAppMessage *)inAppMessage;

- (void)trackInAppClick:(MEInAppMessage *)inAppMessage
               buttonId:(NSString *)buttonId;

@end