//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MEInAppMessage : NSObject

@property(nonatomic, readonly) NSString *campaignId;
@property(nonatomic, readonly, nullable) NSString *sid;
@property(nonatomic, readonly, nullable) NSString *url;
@property(nonatomic, readonly) NSString *html;
@property(nonatomic, readonly, nullable) EMSResponseModel *response;
@property(nonatomic, readonly) NSDate *responseTimestamp;

- (instancetype)initWithResponse:(EMSResponseModel *)responseModel;

- (instancetype)initWithCampaignId:(NSString *)campaignId
                               sid:(nullable NSString *)sid
                               url:(nullable NSString *)url
                              html:(NSString *)html
                 responseTimestamp:(NSDate *)responseTimestamp;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToMessage:(MEInAppMessage *)message;

- (NSUInteger)hash;

@end

NS_ASSUME_NONNULL_END
