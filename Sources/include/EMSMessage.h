//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMSMessage : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *body;
@property(nonatomic, strong, nullable) NSString *imageUrl;
@property(nonatomic, strong) NSNumber *receivedAt;
@property(nonatomic, strong, nullable) NSNumber *updatedAt;
@property(nonatomic, strong, nullable) NSNumber *ttl;
@property(nonatomic, strong, nullable) NSArray<NSString *> *tags;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *properties;

- (instancetype)initWithId:(NSString *)id
                     title:(NSString *)title
                      body:(NSString *)body
                  imageUrl:(nullable NSString *)imageUrl
                receivedAt:(NSNumber *)receivedAt
                 updatedAt:(nullable NSNumber *)updatedAt
                       ttl:(nullable NSNumber *)ttl
                      tags:(nullable NSArray<NSString *> *)tags
                properties:(nullable NSDictionary<NSString *, NSString *> *)properties;

@end

NS_ASSUME_NONNULL_END