//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import "MEInAppMessage.h"

@implementation MEInAppMessage

- (instancetype)initWithResponse:(EMSResponseModel *)responseModel {
    if (self = [super init]) {
        id parsedBody = responseModel.parsedBody;
        _html = parsedBody[@"message"][@"html"];
        _campaignId = parsedBody[@"message"][@"id"];
        _response = responseModel;
    }
    return self;
}

- (instancetype)initWithCampaignId:(NSString *)campaignId html:(NSString *)html {
    self = [super init];
    if (self) {
        _campaignId = campaignId;
        _html = html;
    }

    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToMessage:other];
}

- (BOOL)isEqualToMessage:(MEInAppMessage *)message {
    if (self == message)
        return YES;
    if (message == nil)
        return NO;
    if (self.campaignId != message.campaignId && ![self.campaignId isEqualToString:message.campaignId])
        return NO;
    if (self.html != message.html && ![self.html isEqualToString:message.html])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.campaignId hash];
    hash = hash * 31u + [self.html hash];
    return hash;
}


@end
