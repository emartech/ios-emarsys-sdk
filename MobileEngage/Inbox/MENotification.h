//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MENotification : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *sid;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *body;
@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *customData;
@property(nonatomic, strong) NSDictionary<NSString *, id> *rootParams;
@property(nonatomic, strong) NSNumber *expirationTime;
@property(nonatomic, strong) NSNumber *receivedAtTimestamp;

- (instancetype)initWithUserinfo:(NSDictionary *)dictionary;
- (instancetype)initWithNotificationDictionary:(NSDictionary *)dictionary;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToNotification:(MENotification *)notification;

- (NSUInteger)hash;

@end