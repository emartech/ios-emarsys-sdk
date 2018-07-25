//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEButtonClick : NSObject

@property (nonatomic, strong) NSString *campaignId;
@property (nonatomic, strong) NSString *buttonId;
@property (nonatomic, strong) NSDate *timestamp;

- (instancetype)initWithCampaignId:(NSString *)campaignId
                          buttonId:(NSString *)buttonId
                         timestamp:(NSDate *)timestamp;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToClick:(MEButtonClick *)click;

- (NSUInteger)hash;

- (NSDictionary *)dictionaryRepresentation;

@end
