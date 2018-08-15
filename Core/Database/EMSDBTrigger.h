//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef void(^EMSTriggerBlock)();

@protocol EMSTriggerType <NSObject>
- (NSString *)type;
@end

@interface EMSDBTriggerType : NSObject <EMSTriggerType>

@property(nonatomic, readonly, class) id <EMSTriggerType> before;
@property(nonatomic, readonly, class) id <EMSTriggerType> after;

@end


@protocol EMSTriggerEvent <NSObject>
- (NSString *)eventName;
@end

@interface EMSDBTriggerEvent : NSObject <EMSTriggerEvent>

@property(nonatomic, readonly, class) id <EMSTriggerType> insert;
@property(nonatomic, readonly, class) id <EMSTriggerType> delete;

@end