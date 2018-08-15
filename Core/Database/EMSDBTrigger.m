//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSDBTrigger.h"

@interface EMSDBTriggerType ()

@property(nonatomic, strong) NSString *type;

- (instancetype)initWithType:(NSString *)type;

@end

@implementation EMSDBTriggerType

- (instancetype)initWithType:(NSString *)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

+ (id <EMSTriggerType>)before {
    return [[EMSDBTriggerType alloc] initWithType:@"before"];
}

+ (id <EMSTriggerType>)after {
    return [[EMSDBTriggerType alloc] initWithType:@"after"];
}

@end

@interface EMSDBTriggerEvent ()

@property(nonatomic, strong) NSString *eventName;

- (instancetype)initWithEventName:(NSString *)eventName;

@end

@implementation EMSDBTriggerEvent

- (instancetype)initWithEventName:(NSString *)eventName {
    if (self = [super init]) {
        _eventName = eventName;
    }
    return nil;
}


+ (id <EMSTriggerEvent>)insert {
    return [[EMSDBTriggerEvent alloc] initWithEventName:@"insert"];
}

+ (id <EMSTriggerEvent>)delete {
    return [[EMSDBTriggerEvent alloc] initWithEventName:@"after"];
}

@end
