//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import "EMSNotificationInformation.h"

@implementation EMSNotificationInformation

- (instancetype)initWithCampaignId:(NSString *)campaignId {
    if (self = [super init]) {
        _campaignId = campaignId;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToInformation:other];
}

- (BOOL)isEqualToInformation:(EMSNotificationInformation *)information {
    if (self == information)
        return YES;
    if (information == nil)
        return NO;
    if (self.campaignId != information.campaignId && ![self.campaignId isEqualToString:information.campaignId])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.campaignId hash];
}

@end
