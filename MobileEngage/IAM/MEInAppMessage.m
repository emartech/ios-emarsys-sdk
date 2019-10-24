//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import "MEInAppMessage.h"

@implementation MEInAppMessage

- (instancetype)initWithResponse:(EMSResponseModel *)responseModel {
    NSParameterAssert(responseModel);
    if (self = [super init]) {
        id parsedBody = responseModel.parsedBody;
        _html = parsedBody[@"message"][@"html"];
        _campaignId = parsedBody[@"message"][@"campaignId"];
        _response = responseModel;
        _responseTimestamp = responseModel.timestamp;
    }
    return self;
}

- (instancetype)initWithCampaignId:(NSString *)campaignId
                               sid:(NSString *)sid
                               url:(NSString *)url
                              html:(NSString *)html
                 responseTimestamp:(NSDate *)responseTimestamp {
    NSParameterAssert(campaignId);
    NSParameterAssert(html);
    NSParameterAssert(responseTimestamp);
    if (self = [super init]) {
        _campaignId = campaignId;
        _sid = sid;
        _url = url;
        _html = html;
        _responseTimestamp = responseTimestamp;
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
    if (self.sid != message.sid && ![self.sid isEqualToString:message.sid])
        return NO;
    if (self.url != message.url && ![self.url isEqualToString:message.url])
        return NO;
    if (self.html != message.html && ![self.html isEqualToString:message.html])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.campaignId hash];
    hash = hash * 31u + [self.sid hash];
    hash = hash * 31u + [self.url hash];
    hash = hash * 31u + [self.html hash];
    return hash;
}

@end
