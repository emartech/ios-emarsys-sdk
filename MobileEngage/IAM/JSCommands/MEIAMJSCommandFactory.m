//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MEIAMJSCommandFactory.h"
#import "MEIAMRequestPushPermission.h"
#import "MEIAMOpenExternalLink.h"
#import "MEIAMClose.h"
#import "MEIAMTriggerAppEvent.h"
#import "MEIAMButtonClicked.h"
#import "MobileEngage.h"
#import "MobileEngage+Private.h"
#import "MEIAMTriggerMEEvent.h"

@implementation MEIAMJSCommandFactory

- (instancetype)initWithMEIAM:(id <MEIAMProtocol>)meiam {
    if (self = [super init]) {
        _meiam = meiam;
    }
    return self;
}

- (id <MEIAMJSCommandProtocol>)commandByName:(NSString *)name {
    id <MEIAMJSCommandProtocol> command;
    if ([name isEqualToString:MEIAMRequestPushPermission.commandName]) {
        command = [MEIAMRequestPushPermission new];
    } else if ([name isEqualToString:MEIAMOpenExternalLink.commandName]) {
        command = [MEIAMOpenExternalLink new];
    } else if ([name isEqualToString:MEIAMClose.commandName]) {
        command = [[MEIAMClose alloc] initWithMEIAM:self.meiam];
    } else if ([name isEqualToString:MEIAMTriggerAppEvent.commandName]) {
        command = [[MEIAMTriggerAppEvent alloc] initWithInAppMessageHandler:[self.meiam eventHandler]];
    } else if ([name isEqualToString:MEIAMButtonClicked.commandName]) {
        command = [[MEIAMButtonClicked alloc] initWithCampaignId:[self.meiam currentCampaignId]
                                                      repository:[[MEButtonClickRepository alloc] initWithDbHelper:[MobileEngage dbHelper]]
                                                    inAppTracker:self.meiam.inAppTracker];
    } else if ([name isEqualToString:MEIAMTriggerMEEvent.commandName]) {
        command = [MEIAMTriggerMEEvent new];
    }
    return command;
}

@end