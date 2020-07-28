//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMSNotificationInformation : NSObject

@property(nonatomic, readonly) NSString *campaignId;

- (instancetype)initWithCampaignId:(NSString *)campaignId;

@end

NS_ASSUME_NONNULL_END
