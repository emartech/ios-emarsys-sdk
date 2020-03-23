//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMSMessage : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong, nullable) NSNumber *multichannelId;
@property(nonatomic, strong, nullable) NSString *campaignId;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *body;
@property(nonatomic, strong, nullable) NSString *imageUrl;
@property(nonatomic, strong, nullable) NSString *action;
@property(nonatomic, strong) NSNumber *receivedAt;
@property(nonatomic, strong, nullable) NSNumber *updatedAt;
@property(nonatomic, strong, nullable) NSNumber *ttl;
@property(nonatomic, strong, nullable) NSArray<NSString *> *tags;
@property(nonatomic, strong) NSNumber *sourceId;
@property(nonatomic, strong, nullable) NSString *sourceRunId;
@property(nonatomic, strong) NSString *sourceType;

- (instancetype)initWithId:(NSString *)id
            multichannelId:(nullable NSNumber *)multichannelId
                campaignId:(nullable NSString *)campaignId
                     title:(NSString *)title
                      body:(NSString *)body
                  imageUrl:(nullable NSString *)imageUrl
                    action:(nullable NSString *)action
                receivedAt:(NSNumber *)receivedAt
                 updatedAt:(nullable NSNumber *)updatedAt
                       ttl:(nullable NSNumber *)ttl
                      tags:(nullable NSArray<NSString *> *)tags
                  sourceId:(NSNumber *)sourceId
               sourceRunId:(nullable NSString *)sourceRunId
                sourceType:(NSString *)sourceType;

@end

NS_ASSUME_NONNULL_END