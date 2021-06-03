//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EMSActionModelProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface EMSMessage : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *campaignId;
@property(nonatomic, strong, nullable) NSString *collapseId;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *body;
@property(nonatomic, strong, nullable) NSString *imageUrl;
@property(nonatomic, strong) NSNumber *receivedAt;
@property(nonatomic, strong, nullable) NSNumber *updatedAt;
@property(nonatomic, strong, nullable) NSNumber *expiresAt;
@property(nonatomic, strong, nullable) NSArray<NSString *> *tags;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *properties;
@property(nonatomic, strong, nullable) NSArray<id<EMSActionModelProtocol>> *actions;

- (instancetype)initWithId:(NSString *)id
                campaignId:(NSString *)campaignId
                collapseId:(nullable NSString *)collapseId
                     title:(NSString *)title
                      body:(NSString *)body
                  imageUrl:(nullable NSString *)imageUrl
                receivedAt:(NSNumber *)receivedAt
                 updatedAt:(nullable NSNumber *)updatedAt
                 expiresAt:(nullable NSNumber *)expiresAt
                      tags:(nullable NSArray<NSString *> *)tags
                properties:(nullable NSDictionary<NSString *, NSString *> *)properties
                   actions:(nullable NSArray<id <EMSActionModelProtocol>> *)actions;

@end

NS_ASSUME_NONNULL_END