//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface EMSDBTriggerType : NSObject <NSCopying>

+ (EMSDBTriggerType *)beforeType;

+ (EMSDBTriggerType *)afterType;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToType:(EMSDBTriggerType *)type;

- (NSUInteger)hash;

- (NSString *)description;

@end


@interface EMSDBTriggerEvent : NSObject <NSCopying>

+ (EMSDBTriggerEvent *)insertEvent;

+ (EMSDBTriggerEvent *)deleteEvent;

- (NSString *)eventName;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToEvent:(EMSDBTriggerEvent *)event;

- (NSUInteger)hash;

- (NSString *)description;

@end

@interface EMSDBTriggerAction : NSObject
typedef void(^EMSTriggerBlock)();
@property (nonatomic, readonly) EMSTriggerBlock triggerBlock;

- (instancetype)initWithTriggerActionBlock:(EMSTriggerBlock)triggerActionBlock;

- (void)run;

@end