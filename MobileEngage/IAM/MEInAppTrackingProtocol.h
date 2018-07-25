//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MEInAppTrackingProtocol <NSObject>

- (void)trackInAppDisplay:(NSString *)campaignId;
- (void)trackInAppClick:(NSString *)campaignId buttonId:(NSString *)buttonId;

@end