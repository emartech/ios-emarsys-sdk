//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSResponseModel.h"

@interface MEInAppMessage : NSObject

@property (nonatomic, readonly) NSString *campaignId;
@property(nonatomic, readonly) NSString *sid;
@property(nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSString *html;
@property (nonatomic, readonly) EMSResponseModel *response;
@property(nonatomic, readonly) NSDate *responseTimestamp;

- (instancetype)initWithResponse:(EMSResponseModel *)responseModel;

- (instancetype)initWithCampaignId:(NSString *)campaignId
                               sid:(NSString *)sid
                               url:(NSString *)url
                              html:(NSString *)html
                 responseTimestamp:(NSDate *)responseTimestamp;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToMessage:(MEInAppMessage *)message;

- (NSUInteger)hash;

@end
